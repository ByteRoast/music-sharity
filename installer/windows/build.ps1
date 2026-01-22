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
    Write-Host ""
    Write-Host "Note: Debug builds only create the Flutter bundle, not the MSI installer."
}

if ($Help) {
    Show-Help
    exit 0
}

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$SourceDir = "$ProjectRoot\build\windows\x64\runner\Release"
$DebugSourceDir = "$ProjectRoot\build\windows\x64\runner\Debug"
$InstallerDir = $PSScriptRoot
$OutputDir = "$ProjectRoot\dist\windows\x64"

$PubspecPath = "$ProjectRoot\pubspec.yaml"
$PubspecContent = Get-Content $PubspecPath -Raw

if ($PubspecContent -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
    $Version = $Matches[1]
    $BuildNumber = $Matches[2]
    $FullVersion = "$Version+$BuildNumber"
} elseif ($PubspecContent -match 'version:\s*(\d+\.\d+\.\d+)') {
    $Version = $Matches[1]
    $BuildNumber = "0"
    $FullVersion = "$Version+$BuildNumber"
} else {
    Write-Host "Error: Could not extract version from pubspec.yaml" -ForegroundColor Red
    exit 1
}

Write-Host "=== Music Sharity Windows Builder ===" -ForegroundColor Cyan
Write-Host "Version: $FullVersion" -ForegroundColor Gray
Write-Host "Target: $Target | Clean: $Clean" -ForegroundColor Gray
Write-Host ""

if (Test-Path $OutputDir) {
    Remove-Item -Recurse -Force $OutputDir
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$LogFile = "$OutputDir\build.log"

if ($Target -eq "release") {
    if ($Clean -eq "true") {
        $TotalSteps = 6
    } else {
        $TotalSteps = 5
    }
} else {
    if ($Clean -eq "true") {
        $TotalSteps = 2
    } else {
        $TotalSteps = 1
    }
}

$Step = 1

Push-Location $ProjectRoot

if ($Clean -eq "true") {
    Write-Host "[$Step/$TotalSteps] Cleaning project..." -ForegroundColor Yellow

    & flutter clean

    Write-Host ""

    $Step++
}

Write-Host "[$Step/$TotalSteps] Building Flutter Windows app ($Target)..." -ForegroundColor Yellow
Write-Host "Log file: $LogFile" -ForegroundColor Gray

& flutter pub get

if ($Target -eq "release") {
    & flutter build windows --release --verbose *>&1 | Out-File -FilePath $LogFile -Encoding UTF8
    $BuildSourceDir = $SourceDir
} else {
    & flutter build windows --debug --verbose *>&1 | Out-File -FilePath $LogFile -Encoding UTF8
    $BuildSourceDir = $DebugSourceDir
}

$BuildExitCode = $LASTEXITCODE

Pop-Location

Write-Host ""

if ($BuildExitCode -ne 0) {
    Write-Host "Error: Flutter build failed" -ForegroundColor Red
    Write-Host "Check log file for details: $LogFile" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "$BuildSourceDir\music_sharity.exe")) {
    Write-Host "Error: Build not found after build!" -ForegroundColor Red
    exit 1
}

if ($Target -eq "debug") {
    Write-Host ""
    Write-Host "=== Debug build completed successfully! ===" -ForegroundColor Green
    Write-Host "Bundle location:" -ForegroundColor Cyan
    Write-Host "  - $BuildSourceDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Note: Debug builds don't create MSI installers." -ForegroundColor Gray
    exit 0
}

$Step++

Write-Host "[$Step/$TotalSteps] Collecting files with heat..." -ForegroundColor Yellow

& heat.exe dir $SourceDir `
    -cg ProductComponents `
    -dr INSTALLFOLDER `
    -scom -sreg -srd -gg -sfrag `
    -var "var.SourceDir" `
    -out "$OutputDir\files.wxi"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: heat.exe failed" -ForegroundColor Red
    exit 1
}

$Step++

Write-Host "[$Step/$TotalSteps] Compiling with candle..." -ForegroundColor Yellow

& candle.exe `
    -dSourceDir="$SourceDir" `
    -dProjectDir="$ProjectRoot" `
    -dVersion="$Version.0" `
    -out "$OutputDir\" `
    "$InstallerDir\music_sharity.wxs" `
    "$OutputDir\files.wxi"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: candle.exe failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

$Step++

Write-Host "[$Step/$TotalSteps] Creating MSI..." -ForegroundColor Yellow

$MsiName = "music-sharity-$FullVersion-windows-x64.msi"

& light.exe `
    -ext WixUIExtension `
    -spdb `
    -out "$OutputDir\$MsiName" `
    "$OutputDir\music_sharity.wixobj" `
    "$OutputDir\files.wixobj"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: light.exe failed" -ForegroundColor Red
    exit 1
}

Remove-Item "$OutputDir\*.wixobj" -ErrorAction SilentlyContinue
Remove-Item "$OutputDir\*.wxi" -ErrorAction SilentlyContinue

Write-Host ""

$Step++

Write-Host "[$Step/$TotalSteps] Generating SHA-1 checksum..." -ForegroundColor Yellow

$MsiPath = "$OutputDir\$MsiName"
$Hash = (Get-FileHash -Path $MsiPath -Algorithm SHA1).Hash.ToLower()
$ChecksumFile = "$OutputDir\$MsiName.sha1"

"$Hash  $MsiName" | Out-File -FilePath $ChecksumFile -Encoding ASCII -NoNewline

Write-Host ""
Write-Host "=== MSI created successfully! ===" -ForegroundColor Green
Write-Host "File: $MsiPath" -ForegroundColor Cyan
Write-Host "Checksum: $ChecksumFile" -ForegroundColor Cyan
Write-Host ""

$Size = (Get-Item "$MsiPath").Length / 1MB

Write-Host "Size: $([math]::Round($Size, 2)) MB" -ForegroundColor Gray
Write-Host "SHA-1: $Hash" -ForegroundColor Gray
