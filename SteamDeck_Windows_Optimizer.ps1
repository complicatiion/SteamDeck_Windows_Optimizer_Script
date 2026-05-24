<#
Steam Deck Windows Optimizer Script
Version: 2.0

This script applies Windows 11 cleanup, privacy, UI and gaming optimizations for a Steam Deck
or a similar handheld gaming PC.

Run it from the included batch launcher for the easiest experience:
  Start_SteamDeck_Windows_Optimizer.cmd
#>

#Requires -RunAsAdministrator

param(
    [ValidateSet("Safe","Balanced","UltimateGaming","DebloatApps","FullNuclear")]
    [string]$Profile = "Balanced",
    [switch]$NoRestorePoint
)

$ErrorActionPreference = "Continue"
$ScriptName = "Steam Deck Windows Optimizer Script"
$Version = "2.0"
$LogDir = "$env:SystemDrive\SteamDeck_Windows_Optimizer"
$LogFile = Join-Path $LogDir "optimizer.log"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR","OK")]
        [string]$Level = "INFO"
    )
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Set-RegValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [ValidateSet("String","ExpandString","Binary","DWord","QWord","MultiString")]
        [string]$Type = "DWord"
    )
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        Write-Log "Set $Path\$Name = $Value" "OK"
    } catch {
        Write-Log "Could not set $Path\$Name: $($_.Exception.Message)" "WARN"
    }
}

function Disable-ServiceSafe {
    param([string]$Name)
    try {
        $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Log "Disabled service: $Name" "OK"
        } else {
            Write-Log "Service not found: $Name"
        }
    } catch {
        Write-Log "Could not disable service $Name: $($_.Exception.Message)" "WARN"
    }
}

function Remove-AppxPattern {
    param([string]$Pattern)
    try {
        Get-AppxPackage -AllUsers -Name $Pattern -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Log "Removing installed package: $($_.Name)"
            Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        }

        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $Pattern } | ForEach-Object {
            Write-Log "Removing provisioned package: $($_.DisplayName)"
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
    } catch {
        Write-Log "Could not remove package pattern $Pattern: $($_.Exception.Message)" "WARN"
    }
}

function New-SafeRestorePoint {
    if ($NoRestorePoint) {
        Write-Log "Restore point skipped by parameter."
        return
    }

    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Before Steam Deck Windows Optimizer" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-Log "Restore point requested." "OK"
    } catch {
        Write-Log "Restore point could not be created. This is common when System Restore is disabled: $($_.Exception.Message)" "WARN"
    }
}

function Apply-SafeProfile {
    Write-Log "Applying SAFE profile..."

    try {
        powercfg -h off | Out-Null
        Write-Log "Disabled hibernation and Fast Startup." "OK"
    } catch {
        Write-Log "powercfg -h off failed: $($_.Exception.Message)" "WARN"
    }

    Set-RegValue "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1
    Set-RegValue "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 1
    Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0
    Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2
    Set-RegValue "HKCU:\System\GameConfigStore" "GameDVR_HonorUserFSEBehaviorMode" 1
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 0
    Set-RegValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 0
    Set-RegValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "AudioCaptureEnabled" 0
    Set-RegValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "CursorCaptureEnabled" 0

    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0

    Set-RegValue "HKCU:\Control Panel\Desktop" "Win8DpiScaling" 1
    Set-RegValue "HKCU:\Control Panel\Desktop" "LogPixels" 120

    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0
    Set-RegValue "HKCU:\Software\Microsoft\TabletTip\1.7" "TipbandDesiredVisibility" 1
    Set-RegValue "HKCU:\Software\Microsoft\TabletTip\1.7" "EnableDesktopModeAutoInvoke" 1

    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" "ToastEnabled" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GLOBAL_SETTING_TOASTS_ENABLED" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GLOBAL_SETTING_BADGE_ENABLED" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" 0

    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowRecent" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowFrequent" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1

    $cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-RegValue $cdm "ContentDeliveryAllowed" 0
    Set-RegValue $cdm "FeatureManagementEnabled" 0
    Set-RegValue $cdm "OemPreInstalledAppsEnabled" 0
    Set-RegValue $cdm "PreInstalledAppsEnabled" 0
    Set-RegValue $cdm "PreInstalledAppsEverEnabled" 0
    Set-RegValue $cdm "RotatingLockScreenEnabled" 0
    Set-RegValue $cdm "RotatingLockScreenOverlayEnabled" 0
    Set-RegValue $cdm "SilentInstalledAppsEnabled" 0
    Set-RegValue $cdm "SoftLandingEnabled" 0
    Set-RegValue $cdm "SubscribedContentEnabled" 0
    Set-RegValue $cdm "SystemPaneSuggestionsEnabled" 0
    Set-RegValue $cdm "SubscribedContent-310093Enabled" 0
    Set-RegValue $cdm "SubscribedContent-338387Enabled" 0
    Set-RegValue $cdm "SubscribedContent-338388Enabled" 0
    Set-RegValue $cdm "SubscribedContent-338389Enabled" 0
    Set-RegValue $cdm "SubscribedContent-338393Enabled" 0
    Set-RegValue $cdm "SubscribedContent-353694Enabled" 0
    Set-RegValue $cdm "SubscribedContent-353696Enabled" 0
    Set-RegValue $cdm "SubscribedContent-353698Enabled" 0

    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableSoftLanding" 1
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableConsumerAccountStateContent" 1
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableCloudOptimizedContent" 1
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1
    Set-RegValue "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1

    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" "ScoobeSystemSettingEnabled" 0
    Set-RegValue "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0
    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" 0
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1

    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 0
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" 0
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" 0
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0

    Set-RegValue "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
    Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
}

function Apply-BalancedProfile {
    Apply-SafeProfile
    Write-Log "Applying BALANCED additions..."

    Set-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 2
    Set-RegValue "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "0" "String"
    Set-RegValue "HKCU:\Control Panel\Desktop" "UserPreferencesMask" ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) "Binary"

    $services = @("DiagTrack","dmwappushservice","SysMain","WSearch","MapsBroker","RetailDemo","Fax","WMPNetworkSvc")
    foreach ($service in $services) {
        Disable-ServiceSafe $service
    }

    try {
        Set-Service -Name "TabletInputService" -StartupType Manual -ErrorAction SilentlyContinue
        Write-Log "Touch keyboard service kept available." "OK"
    } catch {
        Write-Log "Could not configure touch keyboard service: $($_.Exception.Message)" "WARN"
    }

    try {
        powercfg /change monitor-timeout-ac 15 | Out-Null
        powercfg /change monitor-timeout-dc 10 | Out-Null
        powercfg /change standby-timeout-ac 0 | Out-Null
        powercfg /change standby-timeout-dc 30 | Out-Null
        Write-Log "Configured display and sleep timeouts." "OK"
    } catch {
        Write-Log "Could not configure power timeouts: $($_.Exception.Message)" "WARN"
    }
}

function Apply-UltimateGamingProfile {
    Apply-BalancedProfile
    Write-Log "Applying ULTIMATE GAMING additions..."

    Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "EnableVirtualizationBasedSecurity" 0
    Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "RequirePlatformSecurityFeatures" 0
    Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" "Enabled" 0

    try {
        bcdedit /set hypervisorlaunchtype off | Out-Null
        Write-Log "Disabled hypervisor launch for VBS-related overhead." "OK"
    } catch {
        Write-Log "Could not change hypervisor launch type: $($_.Exception.Message)" "WARN"
    }

    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff
    Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 0

    try {
        powercfg -setactive SCHEME_BALANCED | Out-Null
        Write-Log "Set active power plan to Balanced." "OK"
    } catch {
        Write-Log "Could not set Balanced power plan: $($_.Exception.Message)" "WARN"
    }
}

function Apply-DebloatApps {
    Write-Log "Applying APP DEBLOAT profile..."

    $appPatterns = @(
        "Microsoft.3DBuilder",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.Office.OneNote",
        "Microsoft.OutlookForWindows",
        "Microsoft.WindowsCommunicationsApps",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.MixedReality.Portal",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.Todos",
        "Microsoft.PowerAutomateDesktop",
        "Clipchamp.Clipchamp",
        "MicrosoftTeams",
        "MSTeams",
        "Microsoft.Copilot",
        "Microsoft.Windows.DevHome",
        "Microsoft.BingSearch"
    )

    foreach ($app in $appPatterns) {
        Remove-AppxPattern $app
    }

    Write-Log "App debloat completed. Store, Settings, Calculator, Notepad, Photos and Terminal were not targeted." "OK"
}

function Restart-ExplorerSafe {
    try {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Process explorer.exe
        Write-Log "Explorer restarted." "OK"
    } catch {
        Write-Log "Could not restart Explorer: $($_.Exception.Message)" "WARN"
    }
}

Write-Log "=== $ScriptName v$Version started ==="
Write-Log "Selected profile: $Profile"

New-SafeRestorePoint

switch ($Profile) {
    "Safe"           { Apply-SafeProfile }
    "Balanced"       { Apply-BalancedProfile }
    "UltimateGaming" { Apply-UltimateGamingProfile }
    "DebloatApps"    { Apply-DebloatApps }
    "FullNuclear"    { Apply-UltimateGamingProfile; Apply-DebloatApps }
}

Restart-ExplorerSafe

Write-Log "=== Optimization completed ===" "OK"
Write-Host ""
Write-Host "A reboot is recommended."
Write-Host "Some settings, especially DPI scaling and VBS/Core Isolation changes, require sign-out or reboot."
Write-Host "Log file: $LogFile"
