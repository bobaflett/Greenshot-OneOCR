[CmdletBinding()]
param(
    [string]$InstallPath = "C:\Tools\OneOCR"
)

$ErrorActionPreference = "Stop"

Write-Host "Greenshot-OneOCR installer"
Write-Host "--------------------------"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OneOCRExe = Join-Path $ScriptDir "oneocr.exe"
$Wrapper   = Join-Path $ScriptDir "GreenshotOCR.ps1"

if (-not (Test-Path -LiteralPath $OneOCRExe)) {
    throw "oneocr.exe was not found next to Install.ps1. Download it from https://github.com/deltqz/oneocr-cli and place it in this folder, then run the installer again."
}

if (-not (Test-Path -LiteralPath $Wrapper)) {
    throw "GreenshotOCR.ps1 was not found next to Install.ps1."
}

$Snip = Get-AppxPackage Microsoft.ScreenSketch |
    Sort-Object Version -Descending |
    Select-Object -First 1

if (-not $Snip) {
    throw "Microsoft Snipping Tool (Microsoft.ScreenSketch) was not found."
}

$Source = Join-Path $Snip.InstallLocation "SnippingTool"

$RequiredFiles = @(
    "oneocr.dll",
    "oneocr.onemodel",
    "onnxruntime.dll"
)

foreach ($File in $RequiredFiles) {
    $Path = Join-Path $Source $File
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required Snipping Tool component not found: $Path"
    }
}

Write-Host "Snipping Tool version: $($Snip.Version)"
Write-Host "Source: $Source"
Write-Host "Installing to: $InstallPath"

New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

foreach ($File in $RequiredFiles) {
    Copy-Item -LiteralPath (Join-Path $Source $File) -Destination $InstallPath -Force
}

Copy-Item -LiteralPath $OneOCRExe -Destination $InstallPath -Force
Copy-Item -LiteralPath $Wrapper   -Destination $InstallPath -Force

$InstalledWrapper = Join-Path $InstallPath "GreenshotOCR.ps1"

Write-Host ""
Write-Host "Installation complete."
Write-Host ""
Write-Host "Greenshot External Command settings:"
Write-Host "Name:      OneOCR -> Clipboard"
Write-Host "Command:   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
Write-Host ('Arguments: -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $InstalledWrapper + '" "{0}"')
