<#
Steam Deck Windows Optimizer - Partial Rollback
Version: 2.0

This script restores the most common UI, service and gaming settings changed by the optimizer.
It does not reinstall removed Appx packages.
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Continue"

function Set-RegValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [ValidateSet("String","ExpandString","Binary","DWord","QWord","MultiString")]
        [string]$Type = "DWord"
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

Write-Host "Running partial rollback..."

Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" "ToastEnabled" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GLOBAL_SETTING_TOASTS_ENABLED" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowRecent" 1
Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowFrequent" 1

Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 1
Set-RegValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 1
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 1

try {
    bcdedit /set hypervisorlaunchtype auto | Out-Null
} catch {}

Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name "WSearch" -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name "DiagTrack" -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name "TabletInputService" -StartupType Manual -ErrorAction SilentlyContinue

try {
    powercfg -h on | Out-Null
} catch {}

try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer.exe
} catch {}

Write-Host "Partial rollback completed. A reboot is recommended."
Write-Host "Removed apps are not automatically reinstalled."
