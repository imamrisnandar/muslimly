@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo      Starting AAB Release Build
echo ==========================================
echo.

:: Step 1: Clean
echo [1/4] Cleaning project...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    goto :error
)
echo.

:: Step 2: Get Dependencies
echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    goto :error
)
echo.

:: Step 3: Build AAB
echo [3/4] Building Android App Bundle (AAB)...
echo This may take several minutes...
call flutter build appbundle --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo ERROR: AAB build failed
    goto :error
)
echo.

:: Step 4: Verify output
echo [4/4] Verifying build output...
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo.
    echo ==========================================
    echo Build Completed Successfully!
    echo AAB Location: build\app\outputs\bundle\release\app-release.aab
    echo ==========================================
    echo.
    
    :: Open output folder
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
pause
exit /b 1

:success
echo.
pause
exit /b 0
