@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Development Environment Setup (Lite)
echo Python + Pip + Pygame + Git
echo ========================================
echo.

REM ===== PYTHON SETUP =====

echo [1/8] Checking for Python...

REM Initialize PYTHON_PATH variable
set PYTHON_PATH=

REM Try common Python installation locations
set LOCATIONS[0]="C:\Program Files\Python313\python.exe"
set LOCATIONS[1]="C:\Program Files\Python312\python.exe"
set LOCATIONS[2]="C:\Program Files\Python311\python.exe"
set LOCATIONS[3]="C:\Program Files (x86)\Python313\python.exe"
set LOCATIONS[4]="C:\Python313\python.exe"
set LOCATIONS[5]="C:\Python312\python.exe"
set LOCATIONS[6]="%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
set LOCATIONS[7]=python

REM Check each location
for /L %%i in (0,1,7) do (
    if not defined PYTHON_PATH (
        if %%i==7 (
            python --version >nul 2>&1
            if !errorlevel! equ 0 (
                for /f "tokens=*" %%p in ('python -c "import sys; print(sys.executable)"') do set PYTHON_PATH=%%p
                echo Found: !PYTHON_PATH!
            )
        ) else (
            set CHECK_PATH=!LOCATIONS[%%i]!
            set CHECK_PATH=!CHECK_PATH:"=!
            if exist "!CHECK_PATH!" (
                set PYTHON_PATH=!CHECK_PATH!
                echo Found: !PYTHON_PATH!
            )
        )
    )
)

REM If not found, install Python
if not defined PYTHON_PATH (
    echo Installing Python 3.13...
    winget install -e --id Python.Python.3.13 --source winget >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo Python installed.
        timeout /t 3 /nobreak >nul
        for /L %%i in (0,1,6) do (
            if not defined PYTHON_PATH (
                set CHECK_PATH=!LOCATIONS[%%i]!
                set CHECK_PATH=!CHECK_PATH:"=!
                if exist "!CHECK_PATH!" (
                    set PYTHON_PATH=!CHECK_PATH!
                    echo Found: !PYTHON_PATH!
                )
            )
        )
    ) else (
        echo ERROR: Python installation failed!
        pause
        exit /b 1
    )
)

REM Verify Python
"%PYTHON_PATH%" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not working.
    pause
    exit /b 1
)

echo [2/8] Detecting Python directory...
for %%i in ("%PYTHON_PATH%") do set PYTHON_DIR=%%~dpi
set PYTHON_DIR=%PYTHON_DIR:~0,-1%

echo [3/8] Adding Python to PATH...
echo %PATH% | find /i "%PYTHON_DIR%" >nul
if %errorlevel% neq 0 (
    powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%PYTHON_DIR%', 'User')" >nul 2>&1
    set PATH=%PATH%;%PYTHON_DIR%
    echo Added to PATH.
) else (
    echo Already in PATH.
)

echo [4/8] Installing/Upgrading pip...
"%PYTHON_PATH%" -m ensurepip --upgrade >nul 2>&1
"%PYTHON_PATH%" -m pip install --upgrade pip >nul 2>&1
echo Pip ready.

echo [5/8] Detecting pip Scripts path...

REM Try to get user scripts location first
set USER_BASE=
for /f "tokens=*" %%i in ('"%PYTHON_PATH%" -c "import site; print(site.USER_BASE)" 2^>nul') do set USER_BASE=%%i

if defined USER_BASE (
    set PIP_SCRIPTS_PATH=%USER_BASE%\Scripts
    if exist "!PIP_SCRIPTS_PATH!" (
        echo Found user scripts path.
    ) else (
        set PIP_SCRIPTS_PATH=%PYTHON_DIR%\Scripts
    )
) else (
    REM Fallback to Python installation Scripts folder
    set PIP_SCRIPTS_PATH=%PYTHON_DIR%\Scripts
)

REM Check for network/roaming profile Scripts
set USERNAME_VAR=%USERNAME%
set YEAR_PREFIX=%USERNAME_VAR:~0,2%
set FULL_YEAR=20%YEAR_PREFIX%
set NETWORK_PIP_PATH=\\CFBS-SVR-FILE1\Students%FULL_YEAR%$\%USERNAME_VAR%\RedirectedProfileFolders\AppData\Python\Python313\Scripts

if exist "%NETWORK_PIP_PATH%" (
    set PIP_SCRIPTS_PATH=%NETWORK_PIP_PATH%
)

REM Check for LocalAppData Scripts
set LOCALAPPDATA_SCRIPTS=%LOCALAPPDATA%\Programs\Python\Python313\Scripts
if exist "%LOCALAPPDATA_SCRIPTS%" (
    echo %PATH% | find /i "%LOCALAPPDATA_SCRIPTS%" >nul
    if !errorlevel! neq 0 (
        powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%LOCALAPPDATA_SCRIPTS%', 'User')" >nul 2>&1
        set PATH=%PATH%;%LOCALAPPDATA_SCRIPTS%
        echo LocalAppData Scripts added.
    )
)

if exist "%PIP_SCRIPTS_PATH%" (
    echo %PATH% | find /i "%PIP_SCRIPTS_PATH%" >nul
    if !errorlevel! neq 0 (
        powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%PIP_SCRIPTS_PATH%', 'User')" >nul 2>&1
        set PATH=%PATH%;%PIP_SCRIPTS_PATH%
        echo Scripts added to PATH.
    ) else (
        echo Scripts already in PATH.
    )
)

echo [6/8] Installing pygame...
"%PYTHON_PATH%" -m pip install pygame >nul 2>&1
"%PYTHON_PATH%" -c "import pygame" >nul 2>&1
if %errorlevel% equ 0 (
    echo Pygame installed.
) else (
    echo WARNING: Pygame verification failed!
)

REM ===== GIT SETUP =====

echo [7/8] Checking for Git...

set GIT_PATH=

REM Common Git installation paths
set GIT_LOCATIONS[0]="%LOCALAPPDATA%\Programs\Git\cmd"
set GIT_LOCATIONS[1]="%LOCALAPPDATA%\Programs\Git\bin"
set GIT_LOCATIONS[2]="C:\Program Files\Git\cmd"
set GIT_LOCATIONS[3]="C:\Program Files (x86)\Git\cmd"
set GIT_LOCATIONS[4]="C:\Git\cmd"
set GIT_LOCATIONS[5]="C:\Program Files\Git\bin"
set GIT_LOCATIONS[6]="C:\Program Files (x86)\Git\bin"

REM Check each location
for /L %%i in (0,1,6) do (
    if not defined GIT_PATH (
        set CHECK_GIT=!GIT_LOCATIONS[%%i]!
        set CHECK_GIT=!CHECK_GIT:"=!
        if exist "!CHECK_GIT!\git.exe" (
            set GIT_PATH=!CHECK_GIT!
            echo Found: !GIT_PATH!
        )
    )
)

REM If not found, install Git
if not defined GIT_PATH (
    echo Installing Git...
    winget install --id Git.Git -e --source winget >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo Git installed.
        timeout /t 3 /nobreak >nul
        for /L %%i in (0,1,6) do (
            if not defined GIT_PATH (
                set CHECK_GIT=!GIT_LOCATIONS[%%i]!
                set CHECK_GIT=!CHECK_GIT:"=!
                if exist "!CHECK_GIT!\git.exe" (
                    set GIT_PATH=!CHECK_GIT!
                    echo Found: !GIT_PATH!
                )
            )
        )
    ) else (
        echo WARNING: Git installation failed!
    )
)

echo [8/8] Adding Git to PATH...
if defined GIT_PATH (
    echo %PATH% | find /i "%GIT_PATH%" >nul
    if !errorlevel! neq 0 (
        powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%GIT_PATH%', 'User')" >nul 2>&1
        set PATH=%PATH%;%GIT_PATH%
        echo Git added to PATH.
    ) else (
        echo Git already in PATH.
    )
) else (
    echo Git setup skipped.
)

REM ===== SUMMARY =====
echo.
echo ========================================
echo Setup complete!
echo ========================================
echo.
echo Python: %PYTHON_PATH%
echo Scripts (pip): %PIP_SCRIPTS_PATH%
if defined GIT_PATH echo Git: %GIT_PATH%
echo.
echo IMPORTANT: Restart terminal for PATH changes.
echo.
echo Test commands:
echo   python --version
echo   pip --version
if defined GIT_PATH echo   git --version
echo.
echo Run app: python __main__.py
echo.

pause
exit /b
