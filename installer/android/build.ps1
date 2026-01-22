# Music Sharity - Share music across all platforms
# Copyright (C) 2026 Sikelio (Byte Roast)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$OutputDir = "$ProjectRoot\dist\android"

$ApkSourceDir = "$ProjectRoot\build\app\outputs\flutter-apk"
$AppBundleSourceDir = "$ProjectRoot\build\app\outputs\bundle\release"

$PubspecPath = "$ProjectRoot\pubspec.yaml"
$PubspecContent = Get-Content $PubspecPath -Raw

if ($PubspecContent -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
    $Version = $Matches[1]
    $BuildNumber = $Matches[2]
} elseif ($PubspecContent -match 'version:\s*(\d+\.\d+\.\d+)') {
    $Version = $Matches[1]
    $BuildNumber = "0"
} else {
    Write-Host "Error: Could not extract version from pubspec.yaml" -ForegroundColor Red
    exit 1
}

if (Test-Path $OutputDir) {
    Remove-Item -Recurse -Force $OutputDir
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$ApkLogFile = "$OutputDir\apk-build.log"
$AppBundleLogFile = "$OutputDir\appbundle-build.log"

Push-Location $ProjectRoot

Write-Host "=== Music Sharity Android Builder ===" -ForegroundColor Cyan
Write-Host "Version: $Version+$BuildNumber" -ForegroundColor Gray
Write-Host ""

Write-Host "[1/5] Cleaning project..." -ForegroundColor Yellow

& flutter clean

Write-Host ""
Write-Host "[2/5] Installing dependencies..." -ForegroundColor Yellow

& flutter pub get

Write-Host ""
Write-Host "[3/5] Building Android APK..." -ForegroundColor Yellow
Write-Host "Log file: $ApkLogFile" -ForegroundColor Gray

& flutter build apk --release --verbose *>&1 | Out-File -FilePath $ApkLogFile -Encoding UTF8

if (-not (Test-Path "$ApkSourceDir\app-release.apk")) {
    Write-Host "Error: Release APK build not found after build!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "[4/5] Building Android AppBundle..." -ForegroundColor Yellow
Write-Host "Log file: $AppBundleLogFile" -ForegroundColor Gray

& flutter build appbundle --release --verbose *>&1 | Out-File -FilePath $AppBundleLogFile -Encoding UTF8

if (-not (Test-Path "$AppBundleSourceDir\app-release.aab")) {
    Write-Host "Error: Release AppBundle build not found after build!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "[5/5] Moving build output files..." -ForegroundColor Yellow

$Name = "music-sharity-$Version+$BuildNumber"

Move-Item "$ApkSourceDir\app-release.apk" "$OutputDir\$Name.apk"
Move-Item "$ApkSourceDir\app-release.apk.sha1" "$OutputDir\$Name.apk.sha1"
Move-Item "$AppBundleSourceDir\app-release.aab" "$OutputDir\$Name.aab"

Pop-Location

Write-Host ""
Write-Host "=== Build completed successfully! ===" -ForegroundColor Green
Write-Host "Files:" -ForegroundColor Cyan
Write-Host "  - $OutputDir\$Name.apk" -ForegroundColor Cyan
Write-Host "  - $OutputDir\$Name.aab" -ForegroundColor Cyan
Write-Host ""
Write-Host "Checksums:" -ForegroundColor Gray
Write-Host "  - $OutputDir\$Name.apk.sha1" -ForegroundColor Gray
Write-Host ""

$ApkSize = (Get-Item "$OutputDir\$Name.apk").Length / 1MB
$ApkSha1 = (Get-Content "$OutputDir\$Name.apk.sha1").Split(' ')[0]
$AppBundleSize = (Get-Item "$OutputDir\$Name.aab").Length / 1MB

Write-Host ".apk package:" -ForegroundColor Gray
Write-Host "  Size: $([math]::Round($ApkSize, 2)) MB"
Write-Host "  SHA-1: $ApkSha1"
Write-Host ""
Write-Host ".aab package:" -ForegroundColor Gray
Write-Host "  Size: $([math]::Round($AppBundleSize, 2)) MB"
