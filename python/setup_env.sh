#!/bin/bash

# Setup script for Python fuzzy logic environment (Unix/Linux/macOS)

echo "Setting up Python environment for School Commute Fuzzy Logic Model..."

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv fuzzy_env

# Activate virtual environment
echo "Activating virtual environment..."
source fuzzy_env/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing required packages..."
pip install -r requirements.txt

echo ""
echo "Setup complete!"
echo ""
echo "To activate the environment in the future, run:"
echo "  source fuzzy_env/bin/activate"
echo ""
echo "To deactivate the environment, run:"
echo "  deactivate"
echo ""
echo "To run the main model, use:"
echo "  python school_commute_model.py"