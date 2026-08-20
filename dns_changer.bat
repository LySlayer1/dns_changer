@echo off
setlocal EnableDelayedExpansion

:: Check for Administrator privileges and elevate if necessary
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto GotAdmin
)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B

:GotAdmin
title Network IP ^& DNS Manager - Asaed Dughman
color 0A

:MAINMENU
cls
echo ========================================================
echo      Windows IP and Regional DNS Configuration Tool
echo                Developed by Asaed Dughman
echo ========================================================
echo.

:: Show active network adapters
echo Available Network Interfaces:
echo --------------------------------------------------------
netsh interface show interface
echo --------------------------------------------------------
echo.

set /p ADAPTER="Enter Connection Name (e.g., Ethernet or Wi-Fi): "
if "%ADAPTER%"=="" (
    echo [!] Adapter name cannot be empty.
    timeout /t 2 >nul
    goto MAINMENU
)

:MODE_SELECT
echo.
echo Choose Configuration Mode:
echo --------------------------------------------------------
echo 1. Change DNS Only (Retain current IP setting)
echo 2. Change Both Static IP Address and DNS
echo 3. Reset Everything to Automatic (DHCP IP + DHCP DNS)
echo.

set /p MODE="Enter choice (1-3): "

if "%MODE%"=="1" goto CHOOSEDNS
if "%MODE%"=="2" goto SETIP
if "%MODE%"=="3" goto RESETALL

echo [!] Invalid selection. Try again.
goto MODE_SELECT

:SETIP
echo.
echo --- Static IP Configuration ---
set /p IP="Enter IP Address (e.g., 192.168.1.50): "
set /p MASK="Enter Subnet Mask (e.g., 255.255.255.0): "
set /p GATEWAY="Enter Default Gateway (e.g., 192.168.1.1): "

echo.
echo Applying IP address configuration to "%ADAPTER%"...
netsh interface ip set address name="%ADAPTER%" static %IP% %MASK% %GATEWAY% >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Failed to apply IP address. Verify adapter name and address format.
    pause
    goto MAINMENU
)
echo [+] Static IP Address updated successfully!

:CHOOSEDNS
echo.
echo ========================================================
echo Choose DNS Region / Provider:
echo --------------------------------------------------------
echo [LY] Libya (Local):
echo   1. GPTC / LTT Local  (102.68.132.82 / 41.208.73.31)
echo   2. Aljeel Aljadeed   (165.16.68.1 / 165.16.58.124)
echo.
echo [RU] Russia:
echo   3. Yandex DNS        (77.88.8.8 / 77.88.8.1)
echo   4. NSDI Russia       (195.208.4.1 / 195.208.5.1)
echo.
echo [EU] Europe:
echo   5. AdGuard DNS       (94.140.14.14 / 94.140.15.15)
echo   6. Cloudflare DNS    (1.1.1.1 / 1.0.0.1)
echo.
echo [US] United States:
echo   7. Google DNS        (8.8.8.8 / 8.8.4.4)
echo   8. OpenDNS / Cisco   (208.67.222.222 / 208.67.220.220)
echo.
echo [General]
echo   9. Custom DNS (Manual Entry)
echo   10. Keep Existing / Skip DNS Change
echo.

set /p CHOICE="Enter choice (1-10): "

if "%CHOICE%"=="1" set PRIMARY=102.68.132.82& set SECONDARY=41.208.73.31& goto SETDNS
if "%CHOICE%"=="2" set PRIMARY=165.16.68.1& set SECONDARY=165.16.58.124& goto SETDNS
if "%CHOICE%"=="3" set PRIMARY=77.88.8.8& set SECONDARY=77.88.8.1& goto SETDNS
if "%CHOICE%"=="4" set PRIMARY=195.208.4.1& set SECONDARY=195.208.5.1& goto SETDNS
if "%CHOICE%"=="5" set PRIMARY=94.140.14.14& set SECONDARY=94.140.15.15& goto SETDNS
if "%CHOICE%"=="6" set PRIMARY=1.1.1.1& set SECONDARY=1.0.0.1& goto SETDNS
if "%CHOICE%"=="7" set PRIMARY=8.8.8.8& set SECONDARY=8.8.4.4& goto SETDNS
if "%CHOICE%"=="8" set PRIMARY=208.67.222.222& set SECONDARY=208.67.220.220& goto SETDNS
if "%CHOICE%"=="9" (
    echo.
    set /p PRIMARY="Enter Primary DNS IP: "
    set /p SECONDARY="Enter Secondary DNS IP: "
    goto SETDNS
)
if "%CHOICE%"=="10" goto END

echo [!] Invalid choice. Please try again.
goto CHOOSEDNS

:SETDNS
echo.
echo Configuring Primary DNS (%PRIMARY%) on "%ADAPTER%"...
netsh interface ip set dns name="%ADAPTER%" static %PRIMARY% primary >nul 2>&1

if not "%SECONDARY%"=="" (
    echo Configuring Secondary DNS (%SECONDARY%) on "%ADAPTER%"...
    netsh interface ip add dns name="%ADAPTER%" %SECONDARY% index=2 >nul 2>&1
)

echo [+] DNS successfully updated!
goto END

:RESETALL
echo.
echo Resetting IP address and DNS to automatic (DHCP) for "%ADAPTER%"...
netsh interface ip set address name="%ADAPTER%" dhcp >nul 2>&1
netsh interface ip set dns name="%ADAPTER%" dhcp >nul 2>&1
echo [+] Network adapter reset to DHCP successfully!
goto END

:END
echo.
echo Flushing local DNS cache...
ipconfig /flushdns >nul
echo [+] DNS cache flushed.
echo.
pause