@echo off
title Muslimly - Build APK
echo ==========================================
echo      Starting APK Release Build
echo ==========================================
echo.
echo [1/4] Cleaning project...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo Error during flutter clean.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/4] Getting dependencies...
if not exist "android\key.properties" (
    echo.
    echo ================================================================
    echo WARNING: android\key.properties not found!
    echo.
    echo Release build requires a signing configuration.
    echo If this fails, please create android\key.properties with:
    echo storePassword=...
    echo keyPassword=...
    echo keyAlias=...
    echo storeFile=... (path to .jks file)
    echo ================================================================
    echo.
    echo Press any key to continue build attempt...
    pause >nul
)
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo Error during flutter pub get.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/4] Building APK (Release Mode)...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo Error during build process.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [4/4] Opening Output Folder...
explorer build\app\outputs\flutter-apk\

echo.
echo ==========================================
echo Build Completed Successfully!
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo ==========================================
pause
