param(
    [Parameter(Mandatory = $true)]
    [string]$ImagePath
)

$OCRDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$OneOCR   = Join-Path $OCRDir "oneocr.exe"
$TempFile = Join-Path $env:TEMP "GreenshotOCR_$PID.txt"

try {
    if (-not (Test-Path -LiteralPath $ImagePath)) {
        exit 2
    }

    if (-not (Test-Path -LiteralPath $OneOCR)) {
        exit 3
    }

    # OneOCR needs its DLL/model files available from its working directory.
    Push-Location $OCRDir

    try {
        # CMD handles OneOCR's stdout redirection reliably.
        & cmd.exe /d /c "`"$OneOCR`" `"$ImagePath`" > `"$TempFile`""

        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    }
    finally {
        Pop-Location
    }

    if (Test-Path -LiteralPath $TempFile) {
        $Text = Get-Content -LiteralPath $TempFile -Raw

        if (-not [string]::IsNullOrWhiteSpace($Text)) {
            Set-Clipboard -Value $Text
        }
    }
}
finally {
    Remove-Item -LiteralPath $TempFile -Force -ErrorAction SilentlyContinue
}
