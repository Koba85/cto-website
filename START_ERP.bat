@echo off
chcp 1251 >nul
title ERP System - Start

echo.
echo ============================================
echo    ERP SISTEMA - ZAPUSK
echo ============================================
echo.

:: Check if erp-app folder exists
if not exist "%~dp0erp-app" (
    echo POMILKA: Papka erp-app ne znajdena!
    echo.
    echo Perekonajtes, sho vy rozpakuvaly VSI fajly z arhivu.
    echo Struktura maje buty:
    echo    cto-website/
    echo       erp-app/
    echo       ZAPUSTYTY_ERP.bat
    echo.
    pause
    exit /b 1
)

:: Check Node.js
echo [1/3] Perevirka Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Node.js NE ZNAJDENO!
    echo.
    echo Zavantajte ta vstanovit Node.js z:
    echo https://nodejs.org/
    echo.
    echo Pisla vstanovlennja zapustit cej fajl znovu.
    echo.
    start https://nodejs.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
echo      Node.js: %NODE_VER% - OK

:: Go to erp-app folder
echo.
echo [2/3] Perekhid do papky erp-app...
cd /d "%~dp0erp-app"
echo      Potochna papka: %cd%

:: Install dependencies
echo.
echo [3/3] Vstanovlennja zalezhnostej...
if not exist "node_modules" (
    echo      Vykonujetsa npm install (zachekajte)...
    call npm install
    if %errorlevel% neq 0 (
        echo      POMILKA npm install!
        pause
        exit /b 1
    )
) else (
    echo      Zalezhnosti vzhe vstanovleni - OK
)

:: Start server
echo.
echo ============================================
echo    SERVER ZAPUSKAJETSA...
echo.
echo    Vidkryjte u brauzeri:
echo    http://localhost:3000
echo.
echo    Dla zupynky natysnit Ctrl+C
echo ============================================
echo.

call npm run dev

pause
