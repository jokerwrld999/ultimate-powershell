# Ultimate-powershell

Pretty PowerShell that looks good and functions almost as good as Linux terminal

## Installation

### Prerequisites

- [PowerShell](https://aka.ms/powershell) latest version or [Windows PowerShell 5.1](https://aka.ms/wmf5download)

PowerShell execution policy is required to be one of: `Unrestricted`, `RemoteSigned` or `ByPass` to execute the installer. For example:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## One Line Install (Elevated PowerShell Recommended)

```
irm "https://github.com/jokerwrld999/ultimate-powershell/raw/main/local.ps1" | iex
```
