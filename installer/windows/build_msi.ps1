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

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$SourceDir = "$ProjectRoot\build\windows\x64\runner\Release"
$InstallerDir = $PSScriptRoot
$OutputDir = "$ProjectRoot\dist\windows\x64"

$PubspecPath = "$ProjectRoot\pubspec.yaml"
$PubspecContent = Get-Content $PubspecPath -Raw

if ($PubspecContent -match 'version:\s*(\d+\.\d+\.\d+)') {
    $Version = $Matches[1]
} else {
    Write-Host "Error: Could not extract version from pubspec.yaml" -ForegroundColor Red
    exit 1
}

Write-Host "=== Music Sharity MSI Builder ===" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path "$SourceDir\music_sharity.exe")) {
    Write-Host "Error: Release build not found!" -ForegroundColor Red
    Write-Host "Run first: flutter build windows --release" -ForegroundColor Yellow
    exit 1
}

if (Test-Path $OutputDir) {
    Remove-Item -Recurse -Force $OutputDir
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host "[1/3] Collecting files with heat..." -ForegroundColor Yellow

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

Write-Host "[2/3] Compiling with candle..." -ForegroundColor Yellow

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

Write-Host "[3/4] Creating MSI..." -ForegroundColor Yellow

$MsiName = "music-sharity-$Version-windows-x64.msi"

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

Write-Host "[4/4] Generating SHA-1 checksum..." -ForegroundColor Yellow

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
