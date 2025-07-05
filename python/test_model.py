"""
Test suite for the School Commute Fuzzy Logic Model - Python Implementation
"""

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from school_commute_model import SchoolCommuteFuzzyModel
import pandas as pd

def run_test_cases():
    """Run comprehensive test cases for the fuzzy logic model."""
    
    model = SchoolCommuteFuzzyModel()
    
    print("School Commute Fuzzy Logic Model - Test Results")
    print("=" * 60)
    print()
    
    # Test Case 1: Ideal conditions
    print("Test Case 1: Ideal Conditions")
    print("Weather: clear, Day: weekday, Parent A: 6:00, Parent B: 6:00")
    prob1, inter1 = model.predict('clear', 'weekday', 6.0, 6.0)
    print(f"Success Probability: {prob1:.1f}%")
    print("Intermediate outputs:")
    for key, value in inter1.items():
        print(f"  {key}: {value:.2f}")
    print()
    
    # Test Case 2: Bad weather
    print("Test Case 2: Bad Weather (Heavy Rain)")
    print("Weather: heavy_rain, Day: weekday, Parent A: 6:30, Parent B: 6:30")
    prob2, inter2 = model.predict('heavy_rain', 'weekday', 6.5, 6.5)
    print(f"Success Probability: {prob2:.1f}%")
    print(f"Run Duration: {inter2['run_duration']:.1f} minutes")
    print(f"Weather Travel Multiplier: {inter2['weather_travel_multiplier']:.2f}")
    print()
    
    # Test Case 3: Late wake times
    print("Test Case 3: Late Wake Times")
    print("Weather: clear, Day: weekday, Parent A: 7:30, Parent B: 7:30")
    prob3, inter3 = model.predict('clear', 'weekday', 7.5, 7.5)
    print(f"Success Probability: {prob3:.1f}%")
    print(f"Base Availability: {inter3['base_availability']:.1f}")
    print(f"Final Availability: {inter3['final_availability']:.1f}")
    print()
    
    # Test Case 4: Weekend early wake
    print("Test Case 4: Weekend Early Wake (Long Run)")
    print("Weather: clear, Day: weekend, Parent A: 6:30, Parent B: 5:45")
    prob4, inter4 = model.predict('clear', 'weekend', 6.5, 5.75)
    print(f"Success Probability: {prob4:.1f}%")
    print(f"Run Duration: {inter4['run_duration']:.1f} minutes")
    print(f"Base Availability: {inter4['base_availability']:.1f}")
    print(f"Final Availability: {inter4['final_availability']:.1f}")
    print()
    
    # Test Case 5: Snow conditions
    print("Test Case 5: Snow Conditions")
    print("Weather: snow, Day: weekday, Parent A: 6:00, Parent B: 6:00")
    prob5, inter5 = model.predict('snow', 'weekday', 6.0, 6.0)
    print(f"Success Probability: {prob5:.1f}%")
    print(f"Weather Travel Multiplier: {inter5['weather_travel_multiplier']:.2f}")
    print()
    
    # Test Case 6: Very early wake (special rule test)
    print("Test Case 6: Very Early Wake, Clear Weather (Special Rule)")
    print("Weather: clear, Day: weekday, Parent A: 5:45, Parent B: 5:45")
    prob6, inter6 = model.predict('clear', 'weekday', 5.75, 5.75)
    print(f"Success Probability: {prob6:.1f}%")
    print(f"Run Duration: {inter6['run_duration']:.1f} minutes")
    print(f"Base Availability: {inter6['base_availability']:.1f}")
    print(f"Final Availability: {inter6['final_availability']:.1f}")
    print(f"Note: Special rule activates if both wake ≤ 6:00 and clear weather")
    print()

def sensitivity_analysis():
    """Perform sensitivity analysis and create visualizations."""
    
    model = SchoolCommuteFuzzyModel()
    
    # Create parameter ranges
    wake_times = np.arange(5.5, 8.51, 0.25)
    weather_conditions = ['clear', 'cloudy', 'light_rain', 'heavy_rain', 'snow']
    
    # Setup the plotting
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    fig.suptitle('School Commute Model Sensitivity Analysis', fontsize=16)
    
    # Plot 1: Parent A wake time sensitivity
    probs_parentA = []
    for wake_time in wake_times:
        prob, _ = model.predict('clear', 'weekday', wake_time, 6.5)
        probs_parentA.append(prob)
    
    axes[0, 0].plot(wake_times, probs_parentA, 'b-', linewidth=2, marker='o')
    axes[0, 0].set_xlabel('Parent A Wake Time (hours)')
    axes[0, 0].set_ylabel('Success Probability (%)')
    axes[0, 0].set_title('Sensitivity to Parent A Wake Time')
    axes[0, 0].grid(True, alpha=0.3)
    
    # Plot 2: Parent B wake time sensitivity
    probs_parentB = []
    for wake_time in wake_times:
        prob, _ = model.predict('clear', 'weekday', 6.5, wake_time)
        probs_parentB.append(prob)
    
    axes[0, 1].plot(wake_times, probs_parentB, 'r-', linewidth=2, marker='o')
    axes[0, 1].set_xlabel('Parent B Wake Time (hours)')
    axes[0, 1].set_ylabel('Success Probability (%)')
    axes[0, 1].set_title('Sensitivity to Parent B Wake Time')
    axes[0, 1].grid(True, alpha=0.3)
    
    # Plot 3: Weather impact
    probs_weather = []
    for weather in weather_conditions:
        prob, _ = model.predict(weather, 'weekday', 6.5, 6.5)
        probs_weather.append(prob)
    
    bars = axes[1, 0].bar(weather_conditions, probs_weather, color=['skyblue', 'lightgray', 'lightblue', 'blue', 'darkblue'])
    axes[1, 0].set_ylabel('Success Probability (%)')
    axes[1, 0].set_title('Weather Impact on Success')
    axes[1, 0].tick_params(axis='x', rotation=45)
    
    # Add value labels on bars
    for bar, prob in zip(bars, probs_weather):
        axes[1, 0].text(bar.get_x() + bar.get_width()/2., bar.get_height() + 1,
                       f'{prob:.1f}%', ha='center', va='bottom')
    
    # Plot 4: Combined heat map
    X, Y = np.meshgrid(wake_times, wake_times)
    Z = np.zeros_like(X)
    
    for i, parent_a_time in enumerate(wake_times):
        for j, parent_b_time in enumerate(wake_times):
            prob, _ = model.predict('clear', 'weekday', parent_a_time, parent_b_time)
            Z[j, i] = prob  # Note: j, i for proper orientation
    
    im = axes[1, 1].contourf(X, Y, Z, levels=20, cmap='RdYlGn')
    axes[1, 1].set_xlabel('Parent A Wake Time (hours)')
    axes[1, 1].set_ylabel('Parent B Wake Time (hours)')
    axes[1, 1].set_title('Success Probability Heat Map')
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=axes[1, 1])
    cbar.set_label('Success Probability (%)')
    
    plt.tight_layout()
    plt.savefig('sensitivity_analysis.png', dpi=300, bbox_inches='tight')
    plt.show()

def run_duration_analysis():
    """Analyze run duration patterns."""
    
    model = SchoolCommuteFuzzyModel()
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Run Duration and Availability Analysis', fontsize=16)
    
    wake_times = np.arange(5.5, 8.51, 0.1)
    weather_for_run = ['clear', 'light_rain', 'heavy_rain']
    colors = ['blue', 'green', 'red']
    
    # Plot 1: Run duration vs Parent B wake time for different weather
    for weather, color in zip(weather_for_run, colors):
        run_durations = []
        for wake_time in wake_times:
            _, inter = model.predict(weather, 'weekday', 6.5, wake_time)
            run_durations.append(inter['run_duration'])
        
        axes[0, 0].plot(wake_times, run_durations, color=color, linewidth=2, 
                       label=weather.replace('_', ' ').title())
    
    axes[0, 0].set_xlabel('Parent B Wake Time (hours)')
    axes[0, 0].set_ylabel('Run Duration (minutes)')
    axes[0, 0].set_title('Run Duration by Wake Time and Weather')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)
    
    # Plot 2: Availability cascade
    base_avail = []
    final_avail = []
    for wake_time in wake_times:
        _, inter = model.predict('clear', 'weekday', 6.5, wake_time)
        base_avail.append(inter['base_availability'])
        final_avail.append(inter['final_availability'])
    
    axes[0, 1].plot(wake_times, base_avail, 'b-', linewidth=2, label='Base Availability')
    axes[0, 1].plot(wake_times, final_avail, 'r--', linewidth=2, label='Final Availability')
    axes[0, 1].set_xlabel('Parent B Wake Time (hours)')
    axes[0, 1].set_ylabel('Availability Score (0-10)')
    axes[0, 1].set_title('Base vs Final Availability')
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)
    
    # Plot 3: Weather travel impact
    weather_conditions = ['clear', 'cloudy', 'light_rain', 'heavy_rain', 'snow']
    weather_multipliers = []
    for weather in weather_conditions:
        _, inter = model.predict(weather, 'weekday', 6.5, 6.5)
        weather_multipliers.append(inter['weather_travel_multiplier'])
    
    bars = axes[1, 0].bar(weather_conditions, weather_multipliers, 
                         color=['gold', 'lightgray', 'lightblue', 'blue', 'darkblue'])
    axes[1, 0].set_ylabel('Travel Time Multiplier')
    axes[1, 0].set_title('Weather Impact on Travel Time')
    axes[1, 0].tick_params(axis='x', rotation=45)
    axes[1, 0].set_ylim(0.9, max(weather_multipliers) * 1.1)
    
    # Add value labels
    for bar, mult in zip(bars, weather_multipliers):
        axes[1, 0].text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.05,
                       f'{mult:.2f}', ha='center', va='bottom')
    
    # Plot 4: Routine efficiency components
    availability_levels = np.arange(0, 10.1, 1)
    breakfast_times = []
    dressing_times = []
    
    for avail in availability_levels:
        breakfast_times.append(model._compute_breakfast_efficiency(avail))
        dressing_times.append(model._compute_dressing_efficiency(avail))
    
    axes[1, 1].plot(availability_levels, breakfast_times, 'b-', linewidth=2, 
                   marker='o', label='Breakfast Time')
    axes[1, 1].plot(availability_levels, dressing_times, 'r-', linewidth=2, 
                   marker='s', label='Dressing Time')
    axes[1, 1].set_xlabel('Parent Availability Score')
    axes[1, 1].set_ylabel('Time (minutes)')
    axes[1, 1].set_title('Routine Task Times vs Availability')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('run_duration_analysis.png', dpi=300, bbox_inches='tight')
    plt.show()

def test_special_rules():
    """Test the special rules specifically."""
    
    model = SchoolCommuteFuzzyModel()
    
    print("\nTesting Special Rules in School Commute Model")
    print("=" * 50)
    print()
    
    test_cases = [
        ("Very Early Wake (5:45), Clear Weather", 'clear', 'weekday', 5.75, 5.75),
        ("Early Wake (6:15), Clear Weather", 'clear', 'weekday', 6.25, 6.25),
        ("Very Early Wake (5:45), Heavy Rain", 'heavy_rain', 'weekday', 5.75, 5.75),
        ("Mixed Wake Times (5:45 & 6:30), Clear Weather", 'clear', 'weekday', 5.75, 6.5),
        ("Very Early Wake (5:45), Cloudy Weather", 'cloudy', 'weekday', 5.75, 5.75),
    ]
    
    for i, (description, weather, day_type, pa_wake, pb_wake) in enumerate(test_cases, 1):
        print(f"Test Case {i}: {description}")
        prob, inter = model.predict(weather, day_type, pa_wake, pb_wake)
        print(f"Success Probability: {prob:.1f}%")
        print(f"Run Duration: {inter['run_duration']:.1f} minutes")
        
        if i == 1:
            print("Expected: Should get at least 85% due to special rule")
        elif i == 2:
            print("Expected: Normal processing, no special rule")
        elif i == 3:
            print("Expected: No special rule due to bad weather")
        elif i == 4:
            print("Expected: No special rule (Parent B not very early)")
        elif i == 5:
            print("Expected: Should trigger special rule for good weather")
        print()

if __name__ == "__main__":
    # Run all tests
    run_test_cases()
    test_special_rules()
    
    print("Generating visualizations...")
    sensitivity_analysis()
    run_duration_analysis()
    
    print("\nAll tests completed! Check the generated plots.")