# Ultimate-powershell

Ultimate-powershell simplifies the process of setting up a new Windows environment. From system tweaks to software installations, it provides a comprehensive solution for automating initial configurations.

## Features

- **Running Tweaks:** Uninstall unwanted Microsoft packages, modify taskbar and lock screen explorer settings, disable telemetry, and utilize O&O ShutUp10++ for additional system customization.

- **Installing Scoop Packages:** Streamline your software management with Scoop, installing essential applications like Adobe Acrobat Reader, Autohotkey, Discord, Firefox, Google Chrome, GitHub CLI, and more.

- **Setting Up Oh-My-Posh:** Update PowerShell, install Oh-My-Posh, and add custom PowerShell modules, scripts, aliases, and functions for a personalized and efficient PowerShell profile.

- **Setting Up AutoHotkey:** Restore custom hotkeys for opening apps, moving windows, desktops, and implementing custom hotstrings for improved productivity.

- **Setting Up WSL2:** Automate the installation of Arch or Ubuntu distros with follow-up Ansible provisioning, creating a fully functional Linux environment.

## Installation

### Prerequisites

- [PowerShell](https://aka.ms/powershell) - Ensure you have the latest version or [Windows PowerShell 5.1](https://aka.ms/wmf5download).

- **PowerShell Execution Policy:** Set it to `Unrestricted`, `RemoteSigned`, or `ByPass` to execute the installer. Use the following command as an example:

  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### One Line Install (Run as Administrator Recommended)

```powershell
irm "https://github.com/jokerwrld999/ultimate-powershell/raw/main/local.ps1" | iex
```

For detailed instructions and customization options, refer to the [documentation article](https://docs.jokerwrld.win/posts/ultimate-powershell).

Feel free to enhance your PowerShell environment effortlessly, combining the best of both worlds.
