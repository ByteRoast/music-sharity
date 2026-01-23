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
param(
    [ValidateSet("release", "debug")]
    [string]$Target = "release",

    [ValidateSet("true", "false")]
    [string]$Clean = "true",

    [switch]$Help
)

function Show-Help {
    Write-Host "Usage: build.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Target <release|debug>   Build target (default: release)"
    Write-Host "  -Clean <true|false>       Run flutter clean before build (default: true)"
    Write-Host "  -Help                     Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build.ps1                           # Release build with clean"
    Write-Host "  .\build.ps1 -Target debug             # Debug build with clean"
    Write-Host "  .\build.ps1 -Target release -Clean false  # Release build without clean"
}

if ($Help) {
    Show-Help
    exit 0
}

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
Write-Host "Target: $Target | Clean: $Clean" -ForegroundColor Gray
Write-Host ""

$Step = 1

if ($Clean -eq "true") {
    if ($Target -eq "release") {
        $TotalSteps = 5
    } else {
        $TotalSteps = 4
    }

    Write-Host "[$Step/$TotalSteps] Cleaning project..." -ForegroundColor Yellow

    & flutter clean

    Write-Host ""

    $Step++
} else {
    if ($Target -eq "release") {
        $TotalSteps = 4
    } else {
        $TotalSteps = 3
    }
}

Write-Host "[$Step/$TotalSteps] Installing dependencies..." -ForegroundColor Yellow

& flutter pub get

Write-Host ""

$Step++

Write-Host "[$Step/$TotalSteps] Building Android APK ($Target)..." -ForegroundColor Yellow
Write-Host "Log file: $ApkLogFile" -ForegroundColor Gray

if ($Target -eq "release") {
    & flutter build apk --release --verbose *>&1 | Out-File -FilePath $ApkLogFile -Encoding UTF8

    $ApkFile = "app-release.apk"
} else {
    & flutter build apk --debug --verbose *>&1 | Out-File -FilePath $ApkLogFile -Encoding UTF8

    $ApkFile = "app-debug.apk"
}

if (-not (Test-Path "$ApkSourceDir\$ApkFile")) {
    Write-Host "Error: APK build not found after build!" -ForegroundColor Red

    Pop-Location

    exit 1
}

Write-Host ""

$Step++

if ($Target -eq "release") {
    Write-Host "[$Step/$TotalSteps] Building Android AppBundle..." -ForegroundColor Yellow
    Write-Host "Log file: $AppBundleLogFile" -ForegroundColor Gray

    & flutter build appbundle --release --verbose *>&1 | Out-File -FilePath $AppBundleLogFile -Encoding UTF8

    if (-not (Test-Path "$AppBundleSourceDir\app-release.aab")) {
        Write-Host "Error: Release AppBundle build not found after build!" -ForegroundColor Red

        Pop-Location

        exit 1
    }

    Write-Host ""

    $Step++
}

Write-Host "[$Step/$TotalSteps] Moving build output files..." -ForegroundColor Yellow

$Name = "music-sharity-$Version+$BuildNumber"

if ($Target -eq "release") {
    Move-Item "$ApkSourceDir\app-release.apk" "$OutputDir\$Name.apk"
    Move-Item "$ApkSourceDir\app-release.apk.sha1" "$OutputDir\$Name.apk.sha1"
    Move-Item "$AppBundleSourceDir\app-release.aab" "$OutputDir\$Name.aab"
} else {
    Move-Item "$ApkSourceDir\app-debug.apk" "$OutputDir\$Name-debug.apk"
}

Pop-Location

Write-Host ""
Write-Host "=== Build completed successfully! ===" -ForegroundColor Green
Write-Host "Files:" -ForegroundColor Cyan

if ($Target -eq "release") {
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
} else {
    Write-Host "  - $OutputDir\$Name-debug.apk" -ForegroundColor Cyan
    Write-Host ""

    $ApkSize = (Get-Item "$OutputDir\$Name-debug.apk").Length / 1MB

    Write-Host ".apk package (debug):" -ForegroundColor Gray
    Write-Host "  Size: $([math]::Round($ApkSize, 2)) MB"
}
