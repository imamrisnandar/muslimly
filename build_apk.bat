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
echo [4/4] Renaming output APK...
set "APK_DIR=build\app\outputs\flutter-apk"
set "APP_NAME=Muslimly"
set "APP_VERSION="
for /f "tokens=2" %%v in ('findstr /b /c:"version:" pubspec.yaml') do set "APP_VERSION=%%v"
set "RELEASE_NAME=%APP_NAME%-v%APP_VERSION%.apk"
if exist "%APK_DIR%\app-release.apk" (
    copy /y "%APK_DIR%\app-release.apk" "%APK_DIR%\%RELEASE_NAME%" >nul
)
explorer "%APK_DIR%\"

echo.
echo ==========================================
echo Build Completed Successfully!
echo APK Location: %APK_DIR%\%RELEASE_NAME%
echo ==========================================
pause
