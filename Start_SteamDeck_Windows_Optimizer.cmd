@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Steam Deck Windows Optimizer Script
color 9F
mode con: cols=96 lines=36

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%SteamDeck_Windows_Optimizer.ps1"
set "RB_SCRIPT=%SCRIPT_DIR%SteamDeck_Windows_Optimizer_Rollback.ps1"

:menu
cls
echo.
echo   +------------------------------------------------------------------------------------------+
echo   ^|                                                                                          ^|
echo   ^|                      STEAM DECK WINDOWS OPTIMIZER SCRIPT                                  ^|
echo   ^|                                                                                          ^|
echo   ^|        Clean Windows 11 setup for Steam Deck / handheld gaming                            ^|
echo   ^|                                                                                          ^|
echo   +------------------------------------------------------------------------------------------+
echo.
echo   Select an optimization profile:
echo.
echo     [1] SAFE
echo         Basic gaming and privacy cleanup.
echo         Disables hibernation, Fast Startup, Game DVR, ads, suggestions, Spotlight,
echo         widgets/news, basic telemetry and notification noise.
echo.
echo     [2] BALANCED
echo         SAFE plus stronger UI cleanup and selected background service tweaks.
echo         Good default profile for most Steam Deck Windows installations.
echo.
echo     [3] ULTIMATE GAMING
echo         BALANCED plus VBS/Core Isolation/Memory Integrity off, stronger power,
echo         responsiveness and gaming-focused settings.
echo.
echo     [4] DEBLOAT APPS
echo         Removes common inbox, sponsored and consumer apps only.
echo         Keeps Microsoft Store, Settings, Calculator, Notepad, Photos and Terminal.
echo.
echo     [5] FULL NUCLEAR
echo         Applies ULTIMATE GAMING plus app debloat and aggressive cleanup.
echo         Best for a dedicated gaming-only Steam Deck Windows install.
echo.
echo     [6] ROLLBACK
echo         Runs the partial rollback script for common UI, service and gaming changes.
echo         Removed apps are not automatically reinstalled.
echo.
echo     [0] EXIT
echo.
echo   +------------------------------------------------------------------------------------------+
echo.

choice /c 1234560 /n /m "Choose an option: "
set "CHOICE=%ERRORLEVEL%"

if "%CHOICE%"=="1" goto safe
if "%CHOICE%"=="2" goto balanced
if "%CHOICE%"=="3" goto ultimate
if "%CHOICE%"=="4" goto debloat
if "%CHOICE%"=="5" goto nuclear
if "%CHOICE%"=="6" goto rollback
if "%CHOICE%"=="7" goto exit

goto menu

:runps
echo.
echo   Running selected profile...
echo   PowerShell ExecutionPolicy is bypassed for this process only.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %PS_ARGS%
echo.
echo   Done. Review the output above. A reboot is recommended.
echo.
pause
goto menu

:safe
set "PS_ARGS=-Profile Safe"
goto runps

:balanced
set "PS_ARGS=-Profile Balanced"
goto runps

:ultimate
set "PS_ARGS=-Profile UltimateGaming"
goto runps

:debloat
set "PS_ARGS=-Profile DebloatApps"
goto runps

:nuclear
set "PS_ARGS=-Profile FullNuclear"
goto runps

:rollback
echo.
echo   Running rollback...
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%RB_SCRIPT%"
echo.
echo   Done. A reboot is recommended.
echo.
pause
goto menu

:exit
endlocal
exit /b 0
