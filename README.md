  ___ _____ ___   _   __  __ ___  ___ ___ _  __    ___  ___ _____ ___ __  __ ___ _______ ___    ___  ___ ___ ___ ___ _____ 
 / __|_   _| __| /_\ |  \/  |   \| __/ __| |/ /   / _ \| _ \_   _|_ _|  \/  |_ _|_  / __| _ \  / __|/ __| _ \_ _| _ \_   _|
 \__ \ | | | _| / _ \| |\/| | |) | _| (__| ' <   | (_) |  _/ | |  | || |\/| || | / /| _||   /  \__ \ (__|   /| ||  _/ | |  
 |___/ |_| |___/_/ \_\_|  |_|___/|___\___|_|\_\   \___/|_|   |_| |___|_|  |_|___/___|___|_|_\  |___/\___|_|_\___|_|   |_|  
                                                                                                                          
# Steam Deck Windows Optimizer Script

A small Windows 11 cleanup and optimization package for Steam Deck and similar handheld gaming PCs.

The goal is simple: make Windows on Steam Deck cleaner, quieter, easier to use on a handheld screen, and better suited for gaming.

## Included files

| File | Purpose |
|---|---|
| `Start_SteamDeck_Windows_Optimizer.cmd` | Main launcher with a menu and colored console output. |
| `SteamDeck_Windows_Optimizer.ps1` | Main PowerShell optimization script. |
| `SteamDeck_Windows_Optimizer_Rollback.ps1` | Partial rollback script for common UI, service and gaming changes. |
| `DOWNLOAD_SOURCES_INFO.txt` | Compact list of driver, tool and community download links. |
| `README.md` | This file. |

## How to run

1. Extract the ZIP file to Steam Deck / Handheld PC.
2. Right-click `Start_SteamDeck_Windows_Optimizer.cmd`.
3. Select **Run as administrator**.
4. Choose one of the menu profiles.

The batch launcher starts PowerShell with:

```powershell
-ExecutionPolicy Bypass
```

This bypass is only used for the current process. It does not permanently change the system-wide PowerShell execution policy.

## Profiles

### 1. SAFE

Basic cleanup for a clean handheld Windows setup.

Applies:

- Dark mode for Windows and apps
- 125% display scaling
- Taskbar widgets/news disabled
- Chat/consumer taskbar button disabled
- Search box hidden
- Touch keyboard tray icon enabled
- Transparency effects disabled
- Game DVR and background capture disabled
- Windows Spotlight disabled
- Suggestions, ads and consumer content disabled
- Notification popups disabled
- Activity history disabled
- Delivery Optimization disabled
- Basic telemetry reduction
- Hibernation and Fast Startup disabled

Recommended if you want a safer first pass.

### 2. BALANCED

SAFE plus stronger UI and service cleanup.

Adds:

- Reduced animations and visual effects
- Selected background services disabled:
  - `DiagTrack`
  - `dmwappushservice`
  - `SysMain`
  - `WSearch`
  - `MapsBroker`
  - `RetailDemo`
  - `Fax`
  - `WMPNetworkSvc`
- Handheld-friendly display and sleep timeouts
- Touch keyboard service remains available

Recommended default profile.

### 3. ULTIMATE GAMING

BALANCED plus stronger gaming-focused changes.

Adds:

- Core Isolation / Memory Integrity related registry settings disabled
- VBS-related hypervisor launch disabled through `bcdedit`
- Multimedia responsiveness tweaks
- Network throttling tweak
- Balanced power plan selected for safer handheld thermals

Recommended for a dedicated Steam Deck Windows gaming install.

### 4. DEBLOAT APPS

Removes common inbox, sponsored and consumer apps only.

Examples:

- News
- Weather
- Office Hub / Microsoft 365 Hub
- Outlook for Windows
- Mail and Calendar
- People
- Solitaire
- Feedback Hub
- Maps
- Mixed Reality Portal
- Phone Link
- Clipchamp
- Teams consumer packages
- Copilot package if present
- Dev Home if present

The script intentionally does **not** target:

- Microsoft Store
- Settings
- Calculator
- Notepad
- Photos
- Terminal

### 5. FULL NUCLEAR

Applies ULTIMATE GAMING plus app debloat.

This is the most aggressive profile and is intended for a clean, gaming-only Windows installation.

### 6. ROLLBACK

Runs the partial rollback script.

It restores common items such as:

- Light mode defaults
- Transparency
- Widgets/search/task view visibility
- Notifications
- Game DVR default-like behavior
- Hypervisor launch type
- Some services
- Hibernation

Important: removed apps are not automatically reinstalled.

## What this package does not do

This optimizer does not install Steam Deck drivers, Steam Deck Tools, Handheld Companion, ViGEmBus, RTSS or any other external dependency.

Use `DOWNLOAD_SOURCES_INFO.txt` for the relevant download links.

## Recommended install order

For a fresh Windows Steam Deck setup:

1. Install Windows 11.
2. Install the official Valve Windows drivers.
3. Install Microsoft Visual C++ Redistributable.
4. Install Steam Deck Tools or Handheld Companion.
5. Install ViGEmBus if your chosen tool requires it.
6. Install RTSS if you want overlay and FPS controls.
7. Run this optimizer.
8. Reboot.
9. Test controls, audio, Wi-Fi, sleep behavior and game performance.

## Notes and tradeoffs

Some tweaks improve performance or reduce background activity by disabling Windows features. This can reduce convenience or security.

Important tradeoffs:

- Disabling Memory Integrity / VBS can improve gaming performance but reduces security hardening.
- Disabling Windows Search makes Explorer search slower.
- Disabling notifications makes the system quieter but also hides app notifications.
- Disabling hibernation removes `hiberfil.sys` and Fast Startup.
- App debloat removes packages for all users where possible.

## Log file

The optimizer writes a log to:

```text
C:\SteamDeck_Windows_Optimizer\optimizer.log
```

## Reboot recommended

A reboot is recommended after every profile run.

Some changes, especially display scaling and VBS/Core Isolation related settings, require a sign-out or reboot before they fully apply.

## License Information

See MIT License:

```text
LICENSE.md
```

## Note

This is a personal hobby project and is provided completely "as is". 
No warranties or guarantees of any kind are provided regarding its functionality, reliability, or safety. 
Please read the full documentation to understand how it works and what to expect before using it.
Use it entirely at your own risk. 


### complicatiion aka sksdesign 24.05.2026