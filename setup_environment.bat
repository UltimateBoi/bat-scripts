@echo off
setlocal enabledelayedexpansion

call :ColorText Cyan "========================================"
echo.
call :ColorText Cyan "Development Environment Setup Script"
echo.
call :ColorText Cyan "Python + Pip + Pygame + Git"
echo.
call :ColorText Cyan "========================================"
echo.
echo.

REM ===== PYTHON SETUP =====

REM ===== Step 1: Check if Python is already installed =====
call :ColorText Yellow "[Step 1/8] Checking for existing Python installation..."
echo.

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
            REM Check if python is in PATH
            python --version >nul 2>&1
            if !errorlevel! equ 0 (
                for /f "tokens=*" %%p in ('python -c "import sys; print(sys.executable)"') do set PYTHON_PATH=%%p
                call :ColorText Green "Found Python in PATH: !PYTHON_PATH!"
                echo.
            )
        ) else (
            REM Check specific location
            set CHECK_PATH=!LOCATIONS[%%i]!
            set CHECK_PATH=!CHECK_PATH:"=!
            if exist "!CHECK_PATH!" (
                set PYTHON_PATH=!CHECK_PATH!
                call :ColorText Green "Found Python at: !PYTHON_PATH!"
                echo.
            )
        )
    )
)

REM If not found, install Python using winget
if not defined PYTHON_PATH (
    call :ColorText Yellow "Python not found. Installing Python 3.13..."
    echo.
    winget install -e --id Python.Python.3.13 --source winget
    
    if !errorlevel! equ 0 (
        call :ColorText Green "Python installation completed!"
        echo.
        
        REM Try to find Python again after installation
        timeout /t 3 /nobreak >nul
        for /L %%i in (0,1,6) do (
            if not defined PYTHON_PATH (
                set CHECK_PATH=!LOCATIONS[%%i]!
                set CHECK_PATH=!CHECK_PATH:"=!
                if exist "!CHECK_PATH!" (
                    set PYTHON_PATH=!CHECK_PATH!
                    call :ColorText Green "Found newly installed Python at: !PYTHON_PATH!"
                    echo.
                )
            )
        )
    ) else (
        call :ColorText Red "ERROR: Python installation failed!"
        echo.
        pause
        exit /b 1
    )
)

REM Verify Python executable works
"%PYTHON_PATH%" --version
if %errorlevel% neq 0 (
    call :ColorText Red "ERROR: Python found but not working correctly."
    echo.
    pause
    exit /b 1
)
echo.

REM ===== Step 2: Detect Python installation path =====
call :ColorText Yellow "[Step 2/8] Detecting Python installation directory..."
echo.
for %%i in ("%PYTHON_PATH%") do set PYTHON_DIR=%%~dpi
set PYTHON_DIR=%PYTHON_DIR:~0,-1%
call :ColorText Cyan "Python directory: %PYTHON_DIR%"
echo.
echo.

REM ===== Step 3: Add Python to PATH if not already there =====
call :ColorText Yellow "[Step 3/8] Checking if Python is in PATH..."
echo.
echo %PATH% | find /i "%PYTHON_DIR%" >nul
if %errorlevel% neq 0 (
    call :ColorText Magenta "Adding Python to user PATH..."
    echo.
    powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%PYTHON_DIR%', 'User')"
    set PATH=%PATH%;%PYTHON_DIR%
    call :ColorText Green "Python directory added to PATH!"
    echo.
) else (
    call :ColorText Green "Python directory already in PATH."
    echo.
)
echo.

REM ===== Step 4: Install/Upgrade pip =====
call :ColorText Yellow "[Step 4/8] Installing/Upgrading pip..."
echo.
"%PYTHON_PATH%" -m ensurepip --upgrade
"%PYTHON_PATH%" -m pip install --upgrade pip
echo.

REM ===== Step 5: Detect pip Scripts path and add to PATH =====
call :ColorText Yellow "[Step 5/8] Detecting pip Scripts path..."
echo.

REM Try to get user scripts location first
for /f "tokens=*" %%i in ('"%PYTHON_PATH%" -c "import site; print(site.USER_BASE)"') do set USER_BASE=%%i
set PIP_SCRIPTS_PATH=%USER_BASE%\Scripts

call :ColorText Cyan "Checking user scripts path: %PIP_SCRIPTS_PATH%"
echo.

REM If user scripts don't exist, use Python installation Scripts folder
if not exist "%PIP_SCRIPTS_PATH%" (
    call :ColorText Yellow "User scripts path not found, using Python installation Scripts..."
    echo.
    set PIP_SCRIPTS_PATH=%PYTHON_DIR%\Scripts
    call :ColorText Cyan "Using: !PIP_SCRIPTS_PATH!"
    echo.
)

REM Also check for network/roaming profile Scripts location
set USERNAME_VAR=%USERNAME%
set YEAR_PREFIX=%USERNAME_VAR:~0,2%
set FULL_YEAR=20%YEAR_PREFIX%
set NETWORK_PIP_PATH=\\CFBS-SVR-FILE1\Students%FULL_YEAR%$\%USERNAME_VAR%\RedirectedProfileFolders\AppData\Python\Python313\Scripts

if exist "%NETWORK_PIP_PATH%" (
    call :ColorText Cyan "Also found network scripts path: %NETWORK_PIP_PATH%"
    echo.
    set PIP_SCRIPTS_PATH=%NETWORK_PIP_PATH%
)

if exist "%PIP_SCRIPTS_PATH%" (
    call :ColorText Green "Pip Scripts path confirmed: %PIP_SCRIPTS_PATH%"
    echo.
    call :ColorText Magenta "Checking if Scripts path is in PATH..."
    echo.
    echo %PATH% | find /i "%PIP_SCRIPTS_PATH%" >nul
    if !errorlevel! neq 0 (
        call :ColorText Magenta "Adding pip Scripts to user PATH..."
        echo.
        powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%PIP_SCRIPTS_PATH%', 'User')"
        set PATH=%PATH%;%PIP_SCRIPTS_PATH%
        call :ColorText Green "Pip Scripts path added to PATH!"
        echo.
    ) else (
        call :ColorText Green "Pip Scripts path already in PATH."
        echo.
    )
) else (
    call :ColorText Red "WARNING: Could not find pip Scripts directory at: %PIP_SCRIPTS_PATH%"
    echo.
    call :ColorText Yellow "Pip will still work via: python -m pip"
    echo.
)
echo.

REM ===== Step 6: Install pygame and verify =====
call :ColorText Yellow "[Step 6/8] Installing pygame..."
echo.
"%PYTHON_PATH%" -m pip install pygame
echo.

call :ColorText Magenta "Verifying pygame installation..."
echo.
"%PYTHON_PATH%" -c "import pygame; print('Pygame version:', pygame.version.ver)"
if %errorlevel% equ 0 (
    call :ColorText Green "Pygame: Installed and verified!"
    echo.
) else (
    call :ColorText Red "WARNING: Pygame installation verification failed!"
    echo.
)
echo.

REM ===== GIT SETUP =====

REM ===== Step 7: Check if Git is already installed =====
call :ColorText Yellow "[Step 7/8] Checking for existing Git installation..."
echo.

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
            call :ColorText Green "Found Git at: !GIT_PATH!"
            echo.
        )
    )
)

REM If not found, install Git using winget
if not defined GIT_PATH (
    call :ColorText Yellow "Git not found. Installing Git..."
    echo.
    winget install --id Git.Git -e --source winget
    
    if !errorlevel! equ 0 (
        call :ColorText Green "Git installation completed!"
        echo.
        
        REM Try to find Git again after installation
        timeout /t 3 /nobreak >nul
        for /L %%i in (0,1,6) do (
            if not defined GIT_PATH (
                set CHECK_GIT=!GIT_LOCATIONS[%%i]!
                set CHECK_GIT=!CHECK_GIT:"=!
                if exist "!CHECK_GIT!\git.exe" (
                    set GIT_PATH=!CHECK_GIT!
                    call :ColorText Green "Found newly installed Git at: !GIT_PATH!"
                    echo.
                )
            )
        )
    ) else (
        call :ColorText Red "WARNING: Git installation failed or was cancelled!"
        echo.
        call :ColorText Yellow "You can install Git manually from: https://git-scm.com/download/win"
        echo.
    )
)

REM ===== Step 8: Add Git to PATH if not already there =====
if defined GIT_PATH (
    call :ColorText Yellow "[Step 8/8] Checking if Git is in PATH..."
    echo.
    echo %PATH% | find /i "%GIT_PATH%" >nul
    if !errorlevel! neq 0 (
        call :ColorText Magenta "Adding Git to user PATH..."
        echo.
        powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%GIT_PATH%', 'User')"
        set PATH=%PATH%;%GIT_PATH%
        call :ColorText Green "Git added to PATH!"
        echo.
    ) else (
        call :ColorText Green "Git is already in PATH."
        echo.
    )
) else (
    call :ColorText Yellow "[Step 8/8] Git setup skipped (not found/installed)"
    echo.
)
echo.

REM ===== SUMMARY =====
call :ColorText Green "========================================"
echo.
call :ColorText Green "SUCCESS! Environment setup complete!"
echo.
call :ColorText Green "========================================"
echo.
echo.
call :ColorText Cyan "=== Python Setup ==="
echo.
call :ColorText Cyan "Python executable: "
echo %PYTHON_PATH%
call :ColorText Cyan "Python directory: "
echo %PYTHON_DIR%
call :ColorText Cyan "Pip Scripts path: "
echo %PIP_SCRIPTS_PATH%
call :ColorText Green "Pygame: Installed"
echo.
echo.
if defined GIT_PATH (
    call :ColorText Cyan "=== Git Setup ==="
    echo.
    call :ColorText Cyan "Git location: "
    echo %GIT_PATH%
    call :ColorText Green "Git: Installed"
    echo.
    echo.
)
call :ColorText Yellow "IMPORTANT: Please restart your terminal/PowerShell for PATH changes to take effect."
echo.
call :ColorText Yellow "After restarting, you can use 'python', 'pip', and 'git' commands directly."
echo.
echo.
call :ColorText Cyan "Quick test commands:"
echo.
call :ColorText White "  python --version"
echo.
call :ColorText White "  pip --version"
echo.
if defined GIT_PATH (
    call :ColorText White "  git --version"
    echo.
)
echo.
call :ColorText Cyan "To run your application, use: "
call :ColorText White "python __main__.py"
echo.
echo.

pause
exit /b

:ColorText
powershell -Command "Write-Host '%~2' -ForegroundColor %~1"
exit /b

REM Color codes used:
REM Green = Success messages
REM Yellow = Step headers and warnings
REM Cyan = Information and paths
REM Magenta = Actions being performed
REM Red = Errors
REM Blue = URLs
REM White = Commands to run
