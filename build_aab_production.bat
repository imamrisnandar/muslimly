@echo off
setlocal enabledelayedexpansion

:: Configuration
set BUILD_TYPE=release
set OBFUSCATE=--obfuscate
set SPLIT_DEBUG_INFO=--split-debug-info=build/app/outputs/symbols

echo ==========================================
echo   Muslimly - AAB Production Build
echo ==========================================
echo.
echo Build Configuration:
echo - Type: %BUILD_TYPE%
echo - Obfuscation: Enabled
echo - Debug Symbols: Split (for crash reporting)
echo.

:: Verify keystore exists
if not exist "android\key.properties" (
    echo ERROR: key.properties not found!
    echo Please ensure your signing configuration is set up.
    goto :error
)

:: Step 1: Clean
echo [1/5] Cleaning project...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    goto :error
)
echo.

:: Step 2: Get Dependencies
echo [2/5] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    goto :error
)
echo.

:: Step 3: Analyze (optional but recommended)
echo [3/5] Running code analysis...
echo (This may show warnings but won't block the build)
call flutter analyze --no-fatal-infos
echo.

:: Step 4: Build AAB with production settings
echo [4/5] Building Android App Bundle (AAB)...
echo This may take several minutes...
echo.

:: Ensure symbols directory exists
if not exist "build\app\outputs\symbols" mkdir "build\app\outputs\symbols"

call flutter build appbundle ^
    --%BUILD_TYPE% ^
    %OBFUSCATE% ^
    %SPLIT_DEBUG_INFO% ^
    --no-tree-shake-icons
    
if %errorlevel% neq 0 (
    echo ERROR: AAB build failed
    goto :error
)
echo.

:: Step 5: Verify and report
echo [5/5] Verifying build output...
set AAB_PATH=build\app\outputs\bundle\release\app-release.aab
set SYMBOLS_PATH=build\app\outputs\symbols

if exist "%AAB_PATH%" (
    echo.
    echo ==========================================
    echo Build Completed Successfully!
    echo ==========================================
    echo.
    echo AAB File: %AAB_PATH%
    
    :: Get file size
    for %%A in ("%AAB_PATH%") do set AAB_SIZE=%%~zA
    set /a AAB_SIZE_MB=!AAB_SIZE! / 1048576
    echo File Size: !AAB_SIZE_MB! MB
    
    echo.
    echo Debug Symbols: %SYMBOLS_PATH%
    echo (Upload symbols to Play Console for crash reporting)
    echo.
    echo ==========================================
    echo Next Steps:
    echo 1. Upload app-release.aab to Google Play Console
    echo 2. Upload symbols folder for crash analytics
    echo 3. Fill in release notes
    echo 4. Submit for review
    echo ==========================================
    echo.
    
    :: Open output folders
    echo Opening output folder...
    start "" "build\app\outputs\bundle\release"
    
    goto :success
) else (
    echo ERROR: AAB file not found at expected location
    goto :error
)

:error
echo.
echo ==========================================
echo Build Failed!
echo ==========================================
echo.
echo Common issues:
echo - Missing key.properties file
echo - Invalid signing configuration
echo - Network issues during dependency download
echo - Code errors (check flutter analyze)
echo.
pause
exit /b 1

:success
echo.
pause
exit /b 0
