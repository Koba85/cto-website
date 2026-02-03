@echo off
chcp 65001 >nul
title ERP Система - Встановлення

echo ╔════════════════════════════════════════════════════════════╗
echo ║         ERP СИСТЕМА - АВТОМАТИЧНЕ ВСТАНОВЛЕННЯ            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: Перевірка Node.js
echo [1/4] Перевірка Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo      Node.js НЕ ЗНАЙДЕНО!
    echo.
    echo      Завантажте та встановіть Node.js з:
    echo      https://nodejs.org/
    echo.
    echo      Після встановлення запустіть цей файл знову.
    echo.
    start https://nodejs.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo      Node.js знайдено: %NODE_VERSION%

:: Встановлення залежностей
echo.
echo [2/4] Встановлення залежностей (npm install)...
cd /d "%~dp0erp-app"
if not exist "node_modules" (
    call npm install
    if %errorlevel% neq 0 (
        echo      ПОМИЛКА при встановленні залежностей!
        pause
        exit /b 1
    )
) else (
    echo      Залежності вже встановлені
)

:: Запуск сервера
echo.
echo [3/4] Запуск сервера розробки...
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  Сервер запускається...                                   ║
echo ║                                                            ║
echo ║  Відкрийте у браузері: http://localhost:3000              ║
echo ║                                                            ║
echo ║  Для зупинки натисніть Ctrl+C                             ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

call npm run dev

pause
