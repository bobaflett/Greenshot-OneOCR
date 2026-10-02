[CmdletBinding()]
param(
    [string]$InstallPath = "C:\Tools\OneOCR"
)

$ErrorActionPreference = "Stop"

Write-Host "Greenshot-OneOCR installer"
Write-Host "--------------------------"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Wrapper   = Join-Path $ScriptDir "GreenshotOCR.ps1"

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
Write-Host ""
Write-Host "Downloading latest oneocr-cli release..."

$ReleaseApi = "https://api.github.com/repos/deltqz/oneocr-cli/releases/latest"
$TempDir = Join-Path $env:TEMP ("Greenshot-OneOCR-" + [guid]::NewGuid().ToString("N"))
$ZipPath = Join-Path $TempDir "oneocr-cli.zip"
$ExtractPath = Join-Path $TempDir "oneocr-cli"

try {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

    $Release = Invoke-RestMethod -Uri $ReleaseApi -Headers @{ "User-Agent" = "Greenshot-OneOCR-Installer" }
    $Asset = $Release.assets |
        Where-Object { $_.name -eq "oneocr-cli-windows-x64.zip" } |
        Select-Object -First 1

    if (-not $Asset) {
        throw "Could not find oneocr-cli-windows-x64.zip in the latest oneocr-cli release."
    }

    Write-Host "oneocr-cli release: $($Release.tag_name)"
    Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $ZipPath -UseBasicParsing

    Expand-Archive -LiteralPath $ZipPath -DestinationPath $ExtractPath -Force

    $DownloadedExe = Get-ChildItem -Path $ExtractPath -Filter "oneocr.exe" -File -Recurse |
        Select-Object -First 1

    if (-not $DownloadedExe) {
        throw "oneocr.exe was not found in the downloaded oneocr-cli archive."
    }

    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

    foreach ($File in $RequiredFiles) {
        Copy-Item -LiteralPath (Join-Path $Source $File) -Destination $InstallPath -Force
    }

    Copy-Item -LiteralPath $DownloadedExe.FullName -Destination (Join-Path $InstallPath "oneocr.exe") -Force
    Copy-Item -LiteralPath $Wrapper -Destination $InstallPath -Force
}
finally {
    Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

$InstalledWrapper = Join-Path $InstallPath "GreenshotOCR.ps1"

Write-Host ""
Write-Host "Installation complete."
Write-Host ""
Write-Host "Greenshot External Command settings:"
Write-Host "Name:      OneOCR -> Clipboard"
Write-Host "Command:   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
Write-Host ('Arguments: -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $InstalledWrapper + '" "{0}"')
