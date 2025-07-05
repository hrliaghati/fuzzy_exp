# School Commute Fuzzy Logic Model - Python Implementation

This directory contains a Python implementation of the hierarchical fuzzy logic surrogate model for predicting school commute success probability.

## Setup Instructions

### Prerequisites
- Python 3.8 or higher
- pip (Python package installer)

### Environment Setup

#### For Unix/Linux/macOS:
```bash
./setup_env.sh
```

#### For Windows:
```cmd
setup_env.bat
```

These scripts will:
1. Create a virtual environment named `fuzzy_env`
2. Activate the environment
3. Install all required packages from `requirements.txt`

### Manual Setup (Alternative)
If the scripts don't work, you can set up manually:

```bash
# Create virtual environment
python -m venv fuzzy_env

# Activate environment (Unix/Linux/macOS)
source fuzzy_env/bin/activate

# Activate environment (Windows)
fuzzy_env\Scripts\activate

# Install requirements
pip install -r requirements.txt
```

## Usage

### Basic Model Usage

```python
from school_commute_model import SchoolCommuteFuzzyModel

# Create model instance
model = SchoolCommuteFuzzyModel()

# Make prediction
success_prob, intermediate_outputs = model.predict(
    weather='clear', 
    day_type='weekday', 
    parent_a_wake=6.0, 
    parent_b_wake=6.0
)

print(f"Success Probability: {success_prob:.1f}%")
```

### Running Tests

```python
# Run comprehensive test suite
python test_model.py

# This will:
# - Run all test cases
# - Generate sensitivity analysis plots
# - Test special rules
# - Create visualization files
```

### Creating Visualizations

```python
# Generate system visualizations
python visualize_system.py

# This creates:
# - Membership function plots
# - System response analysis
# - Architecture diagrams
```

## Files Description

### Core Implementation
- **`school_commute_model.py`**: Main model class with all fuzzy logic implementation
- **`test_model.py`**: Comprehensive test suite with sensitivity analysis
- **`visualize_system.py`**: Visualization tools for model analysis

### Setup Files
- **`requirements.txt`**: Python package dependencies
- **`setup_env.sh`**: Unix/Linux/macOS setup script
- **`setup_env.bat`**: Windows setup script
- **`README.md`**: This documentation file

## Dependencies

The model requires the following Python packages:
- `numpy>=1.21.0`: Numerical computations
- `scipy>=1.7.0`: Scientific computing
- `scikit-fuzzy>=0.4.2`: Fuzzy logic implementation
- `matplotlib>=3.5.0`: Plotting and visualization
- `pandas>=1.3.0`: Data manipulation (for testing)
- `seaborn>=0.11.0`: Statistical visualization
- `jupyter>=1.0.0`: Interactive notebooks (optional)

## Model Features

### Hierarchical Architecture
The Python implementation maintains the same 5-level hierarchy as the MATLAB version:

1. **Level 0**: Independent variables (weather, day type, wake times)
2. **Level 1**: Primary decisions (run decision, base availability)
3. **Level 2**: Adjusted assessments (final availability, weather impact)
4. **Level 3**: Routine efficiency (breakfast, dressing, transportation)
5. **Level 4**: Consolidation (morning routine efficiency)
6. **Level 5**: Final assessment (success probability)

### Special Rules
- Very early wake (≤6:00) + clear weather → minimum 85% success
- Very early wake + clear weather + short run → minimum 90% success

### Weather Impact Modeling
- Clear/Cloudy: 1.0x travel time
- Light Rain: 1.2x travel time
- Heavy Rain: 1.6x travel time
- Snow: 2.2x travel time

## Key Differences from MATLAB Version

1. **Fuzzy Logic Library**: Uses `scikit-fuzzy` instead of MATLAB Fuzzy Logic Toolbox
2. **Implementation Style**: Object-oriented design with class-based architecture
3. **Visualization**: Uses `matplotlib` and `seaborn` for plotting
4. **Performance**: Optimized for batch processing and analysis

## Example Output

```
Success Probability: 85.0%
Intermediate outputs:
  run_duration: 67.50
  base_availability: 8.50
  final_availability: 6.75
  weather_travel_multiplier: 1.00
  breakfast_time: 15.00
  dressing_time: 13.00
  transport_efficiency: 6.08
  routine_efficiency: 9.00
```

## Generated Visualizations

Running the test and visualization scripts will create:
- `sensitivity_analysis.png`: Parameter sensitivity plots
- `run_duration_analysis.png`: Run duration and availability analysis
- `membership_functions.png`: Fuzzy membership function plots
- `system_responses.png`: System response analysis
- `architecture_diagram.png`: Visual system architecture

## Troubleshooting

### Common Issues

1. **Package Installation Errors**:
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt --no-cache-dir
   ```

2. **Virtual Environment Issues**:
   ```bash
   deactivate  # if already in an environment
   rm -rf fuzzy_env  # remove existing environment
   ./setup_env.sh  # run setup again
   ```

3. **Import Errors**:
   Make sure the virtual environment is activated:
   ```bash
   source fuzzy_env/bin/activate  # Unix/Linux/macOS
   fuzzy_env\Scripts\activate     # Windows
   ```

4. **Plotting Issues**:
   If running on a headless server, set the matplotlib backend:
   ```python
   import matplotlib
   matplotlib.use('Agg')  # Use before importing pyplot
   ```

## Performance Notes

- The Python implementation is optimized for analysis and research
- For production use, consider caching model instances
- Batch predictions are more efficient than individual calls
- Visualization generation may take a few seconds for complex plots

## Future Enhancements

- Add Jupyter notebook examples
- Implement parameter optimization tools
- Add model validation and cross-validation
- Create web API interface
- Add real-time prediction capabilities