# Greenshot-OneOCR

Use Windows 11 Snipping Tool's OneOCR engine as a high-accuracy OCR destination in Greenshot.

Greenshot-OneOCR connects Greenshot's **External Command** destination to the OneOCR engine shipped with modern Windows 11 Snipping Tool. Capture a region, choose the OneOCR destination, and the recognized text is placed on your clipboard.

## Why?

Greenshot is a great screenshot tool, but common OCR integrations can struggle with identifiers such as model numbers and serial numbers, especially characters like `O` and `0`.

Windows 11 Snipping Tool's Text Actions use Microsoft's local OneOCR components and, in testing, produced much better results on this kind of text.

Example test data:

```text
21Q1S29X00
FZG2-1
12TD001UUS
Plain text
"Quotes"
A&B
C:\Program Files\Test
hello@example.com
$123.45
(TEST)
```

## Requirements

- Windows 11 with a recent version of Snipping Tool
- Greenshot with the External Command plugin
- PowerShell 5.1 or later
- [deltqz/oneocr-cli](https://github.com/deltqz/oneocr-cli)

> **Important:** This project does not include or redistribute Microsoft's OneOCR DLL or model files. `Install.ps1` copies them from your own installed copy of Snipping Tool.

## Quick setup

1. Download `oneocr.exe` from the [oneocr-cli project](https://github.com/deltqz/oneocr-cli) and place it next to `Install.ps1`.
2. Run PowerShell and execute:

```powershell
.\Install.ps1
```

3. In Greenshot, add an External Command destination using the settings printed by the installer.
4. Capture a region, choose **OneOCR -> Clipboard**, wait a moment, then paste.

By default the files are installed to:

```text
C:\Tools\OneOCR\
├── GreenshotOCR.ps1
├── oneocr.exe
├── oneocr.dll
├── oneocr.onemodel
└── onnxruntime.dll
```

## Greenshot configuration

**Command**

```text
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
```

**Arguments**

```text
-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Tools\OneOCR\GreenshotOCR.ps1" "{0}"
```

Suggested destination name: **OneOCR -> Clipboard**

## A weird but important detail

OneOCR needs to run with the directory containing `oneocr.exe`, `oneocr.dll`, `oneocr.onemodel`, and `onnxruntime.dll` as its working directory.

During testing, launching it from another working directory could return exit code `0` while producing no OCR text at all. `GreenshotOCR.ps1` deliberately uses `Push-Location` before launching OneOCR for this reason.

## Credits

This project provides the Greenshot integration and setup around [deltqz/oneocr-cli](https://github.com/deltqz/oneocr-cli), which provides the CLI wrapper used to interface with OneOCR.

OneOCR and the Snipping Tool components are Microsoft software and are **not** included in this repository.

## Compatibility

Initially tested with:

- Windows 11 25H2
- Snipping Tool 11.2607.23.0
- Greenshot External Command plugin

Because OneOCR is an internal/undocumented Snipping Tool component rather than a supported public API, future Snipping Tool updates may change compatibility.

## License

The Greenshot integration scripts in this repository are licensed under the MIT License. Third-party software and Microsoft components remain subject to their respective licenses.
