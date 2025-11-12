@echo off
setlocal

:: --- Change directory ---
:: This forces the script to run from its own location.
:: This is CRUCIAL for 'Run as administrator' and for relative paths.
cd /d "%~dp0"

:: --- Administrator Check ---
:: This attempts to check for Admin privileges.
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    echo ==========================================================
    echo ERROR: Administrator privileges are required.
    echo Please right-click this .bat file and select 'Run as administrator'.
    echo ==========================================================
    echo.
    goto :error_pause
)

:: --- Python Script Check ---
:: We no longer need %~dp0 because we already CD'd to the script's directory.
if not exist "create_links.py" (
    echo.
    echo ERROR: Could not find 'create_links.py' in the same directory as this script.
    echo Please make sure both scripts are in the same folder.
    echo.
    goto :error_pause
)


:: ####################################################################
:: --- Hardcoded Paths ---
:: EDIT THE VARIABLES BELOW AS NEEDED
:: ####################################################################

@REM set "MOD_NAME=purpIe-Artificer_Indicator"
@REM set "PROFILE_NAME=h2-dev"

:: ####################################################################
:: --- Dynamic & Hardcoded Paths ---
:: ####################################################################

:: --- Dynamically get MOD_NAME from thunderstore.toml ---
:: Check for thunderstore.toml first (assuming it's one directory up)
if not exist "..\thunderstore.toml" (
    echo.
    echo ERROR: Could not find 'thunderstore.toml' in the parent directory.
    echo This file is required to automatically determine the mod name.
    echo.
    goto :error_pause
)

echo.
echo --- Reading mod name from ..\thunderstore.toml ---

:: Find the namespace line, split by " = ", get the 2nd token, and remove quotes
FOR /F "tokens=2 delims== " %%i IN ('findstr /B /C:"namespace =" "..\thunderstore.toml"') DO (
    SET "TS_NAMESPACE=%%~i"
)

:: Find the name line, split by " = ", get the 2nd token, and remove quotes
FOR /F "tokens=2 delims== " %%i IN ('findstr /B /C:"name =" "..\thunderstore.toml"') DO (
    SET "TS_NAME=%%~i"
)

:: Error checking
if not defined TS_NAMESPACE (
    echo ERROR: Could not find 'namespace' in ..\thunderstore.toml.
    goto :error_pause
)
if not defined TS_NAME (
    echo ERROR: Could not find 'name' in ..\thunderstore.toml.
    goto :error_pause
)

:: Construct the final MOD_NAME variable
set "MOD_NAME=%TS_NAMESPACE%-%TS_NAME%"
echo Found Mod: %MOD_NAME%
echo.

:: --- Set other paths ---
set "PROFILE_NAME=h2-dev"

set "PROFILE_PATH=%APPDATA%\r2modmanPlus-local\HadesII\profiles\%PROFILE_NAME%\ReturnOfModding"

set "LINK1=%BASE_PATH%\plugins\%MOD_NAME%"
set "LINK2=%BASE_PATH%\plugins_data\%MOD_NAME%"

set "FOLDER1=..\src"
set "FOLDER2=..\data"

set "LINK1=%PROFILE_PATH%\plugins\%MOD_NAME%"
set "LINK2=%PROFILE_PATH%\plugins_data\%MOD_NAME%"

:: ####################################################################


echo.
echo --- Calling Python Script with hardcoded paths ---
echo   Target 1: %FOLDER1%
echo   Link 1:   %LINK1%
echo   Target 2: %FOLDER2%
echo   Link 2:   %LINK2%
echo.

:: --- Execute Script ---
:: The quotes around the variables are crucial to handle paths with spaces.
python "create_links.py" "%FOLDER1%" "%FOLDER2%" "%LINK1%" "%LINK2%"

echo.
echo --- Script finished. ---
echo.

:: Pause to keep the window open after a successful run.
pause
goto :eof

:error_pause
pause
goto :eof