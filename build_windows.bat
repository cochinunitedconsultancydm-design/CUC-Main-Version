@echo off
echo =========================================
echo   Building Cochin United Windows App
echo =========================================
echo.

echo [1/4] Cleaning previous build files...
call flutter clean

echo.
echo [2/4] Fetching dependencies...
call flutter pub get

echo.
echo [3/4] Compiling Windows executable...
call flutter build windows --release

echo.
if %ERRORLEVEL% GEQ 1 (
    echo =========================================
    echo   BUILD FAILED
    echo =========================================

    exit /b 1
)

echo.
echo [4/4] Creating ZIP file for distribution...
powershell -Command "if (Test-Path 'Cochin_United_Windows_App.zip') { Remove-Item 'Cochin_United_Windows_App.zip' -Force }; Compress-Archive -Path 'build\windows\x64\runner\Release\*' -DestinationPath 'Cochin_United_Windows_App.zip' -Force"

echo =========================================
echo   BUILD AND ZIP SUCCESSFUL
echo =========================================
echo You can find your ready-to-share ZIP file here:
echo %CD%\Cochin_United_Windows_App.zip
echo.

