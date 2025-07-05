@echo off

REM Setup script for Python fuzzy logic environment (Windows)

echo Setting up Python environment for School Commute Fuzzy Logic Model...

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH. Please install Python 3.8 or higher.
    pause
    exit /b 1
)

REM Create virtual environment
echo Creating virtual environment...
python -m venv fuzzy_env

REM Activate virtual environment
echo Activating virtual environment...
call fuzzy_env\Scripts\activate.bat

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

REM Install requirements
echo Installing required packages...
pip install -r requirements.txt

echo.
echo Setup complete!
echo.
echo To activate the environment in the future, run:
echo   fuzzy_env\Scripts\activate.bat
echo.
echo To deactivate the environment, run:
echo   deactivate
echo.
echo To run the main model, use:
echo   python school_commute_model.py

pause