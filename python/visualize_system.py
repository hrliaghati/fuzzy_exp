"""
Visualization tools for the School Commute Fuzzy Logic Model
"""

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from school_commute_model import SchoolCommuteFuzzyModel
import skfuzzy as fuzz

def plot_membership_functions():
    """Plot membership functions for key fuzzy variables."""
    
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('Fuzzy Logic Membership Functions', fontsize=16)
    
    # Parent Wake Time MFs
    wake_range = np.arange(5.5, 8.51, 0.01)
    very_early = fuzz.trapmf(wake_range, [5.5, 5.5, 6.0, 6.25])
    early = fuzz.trimf(wake_range, [6.0, 6.5, 7.0])
    normal = fuzz.trimf(wake_range, [6.5, 7.0, 7.5])
    late = fuzz.trapmf(wake_range, [7.0, 7.5, 8.5, 8.5])
    
    axes[0, 0].plot(wake_range, very_early, 'b', linewidth=2, label='Very Early')
    axes[0, 0].plot(wake_range, early, 'g', linewidth=2, label='Early')
    axes[0, 0].plot(wake_range, normal, 'y', linewidth=2, label='Normal')
    axes[0, 0].plot(wake_range, late, 'r', linewidth=2, label='Late')
    axes[0, 0].set_title('Parent Wake Time MFs')
    axes[0, 0].set_xlabel('Wake Time (hours)')
    axes[0, 0].set_ylabel('Membership')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)
    
    # Weather Condition MFs
    weather_range = np.arange(1, 5.01, 0.01)
    good_weather = fuzz.trapmf(weather_range, [1, 1, 2, 2.5])
    poor_weather = fuzz.trimf(weather_range, [2.5, 3, 3.5])
    bad_weather = fuzz.trapmf(weather_range, [3.5, 4, 5, 5])
    
    axes[0, 1].plot(weather_range, good_weather, 'g', linewidth=2, label='Good')
    axes[0, 1].plot(weather_range, poor_weather, 'y', linewidth=2, label='Poor')
    axes[0, 1].plot(weather_range, bad_weather, 'r', linewidth=2, label='Bad')
    axes[0, 1].set_title('Weather Condition MFs')
    axes[0, 1].set_xlabel('Weather (1=clear to 5=snow)')
    axes[0, 1].set_ylabel('Membership')
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)
    
    # Run Duration MFs
    run_range = np.arange(0, 120.01, 0.1)
    run_none = fuzz.trapmf(run_range, [0, 0, 5, 10])
    run_short = fuzz.trimf(run_range, [10, 20, 30])
    run_medium = fuzz.trimf(run_range, [25, 37.5, 50])
    run_long = fuzz.trimf(run_range, [45, 67.5, 90])
    run_very_long = fuzz.trapmf(run_range, [80, 100, 120, 120])
    
    axes[0, 2].plot(run_range, run_none, 'b', linewidth=2, label='None')
    axes[0, 2].plot(run_range, run_short, 'g', linewidth=2, label='Short')
    axes[0, 2].plot(run_range, run_medium, 'y', linewidth=2, label='Medium')
    axes[0, 2].plot(run_range, run_long, 'orange', linewidth=2, label='Long')
    axes[0, 2].plot(run_range, run_very_long, 'r', linewidth=2, label='Very Long')
    axes[0, 2].set_title('Run Duration MFs')
    axes[0, 2].set_xlabel('Duration (minutes)')
    axes[0, 2].set_ylabel('Membership')
    axes[0, 2].legend()
    axes[0, 2].grid(True, alpha=0.3)
    
    # Availability MFs
    avail_range = np.arange(0, 10.01, 0.01)
    low_avail = fuzz.trapmf(avail_range, [0, 0, 2, 3])
    med_avail = fuzz.trimf(avail_range, [2, 5, 8])
    high_avail = fuzz.trapmf(avail_range, [7, 8, 10, 10])
    
    axes[1, 0].plot(avail_range, low_avail, 'r', linewidth=2, label='Low')
    axes[1, 0].plot(avail_range, med_avail, 'y', linewidth=2, label='Medium')
    axes[1, 0].plot(avail_range, high_avail, 'g', linewidth=2, label='High')
    axes[1, 0].set_title('Parent Availability MFs')
    axes[1, 0].set_xlabel('Availability Score')
    axes[1, 0].set_ylabel('Membership')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)
    
    # Travel Multiplier MFs
    travel_range = np.arange(1.0, 2.51, 0.01)
    normal_travel = fuzz.trapmf(travel_range, [1.0, 1.0, 1.1, 1.3])
    moderate_delay = fuzz.trimf(travel_range, [1.2, 1.4, 1.7])
    major_delay = fuzz.trapmf(travel_range, [1.5, 2.0, 2.5, 2.5])
    
    axes[1, 1].plot(travel_range, normal_travel, 'g', linewidth=2, label='Normal')
    axes[1, 1].plot(travel_range, moderate_delay, 'y', linewidth=2, label='Moderate Delay')
    axes[1, 1].plot(travel_range, major_delay, 'r', linewidth=2, label='Major Delay')
    axes[1, 1].set_title('Travel Multiplier MFs')
    axes[1, 1].set_xlabel('Multiplier')
    axes[1, 1].set_ylabel('Membership')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)
    
    # Success Probability MFs
    prob_range = np.arange(0, 100.01, 0.1)
    very_low = fuzz.trapmf(prob_range, [0, 0, 15, 25])
    low = fuzz.trimf(prob_range, [20, 35, 50])
    medium = fuzz.trimf(prob_range, [45, 60, 75])
    high = fuzz.trimf(prob_range, [70, 85, 95])
    very_high = fuzz.trapmf(prob_range, [80, 90, 100, 100])
    
    axes[1, 2].plot(prob_range, very_low, 'darkred', linewidth=2, label='Very Low')
    axes[1, 2].plot(prob_range, low, 'red', linewidth=2, label='Low')
    axes[1, 2].plot(prob_range, medium, 'y', linewidth=2, label='Medium')
    axes[1, 2].plot(prob_range, high, 'lightgreen', linewidth=2, label='High')
    axes[1, 2].plot(prob_range, very_high, 'darkgreen', linewidth=2, label='Very High')
    axes[1, 2].set_title('Success Probability MFs')
    axes[1, 2].set_xlabel('Probability (%)')
    axes[1, 2].set_ylabel('Membership')
    axes[1, 2].legend()
    axes[1, 2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('membership_functions.png', dpi=300, bbox_inches='tight')
    plt.show()

def plot_system_responses():
    """Plot system responses to various input combinations."""
    
    model = SchoolCommuteFuzzyModel()
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    fig.suptitle('System Response Analysis', fontsize=16)
    
    # Response surface: Parent wake times vs success probability
    wake_times = np.linspace(5.5, 8.5, 20)
    pa_mesh, pb_mesh = np.meshgrid(wake_times, wake_times)
    success_mesh = np.zeros_like(pa_mesh)
    
    for i in range(len(wake_times)):
        for j in range(len(wake_times)):
            prob, _ = model.predict('clear', 'weekday', wake_times[i], wake_times[j])
            success_mesh[j, i] = prob
    
    im1 = axes[0, 0].contourf(pa_mesh, pb_mesh, success_mesh, levels=15, cmap='RdYlGn')
    axes[0, 0].set_xlabel('Parent A Wake Time (hours)')
    axes[0, 0].set_ylabel('Parent B Wake Time (hours)')
    axes[0, 0].set_title('Success Probability (Clear Weather)')
    plt.colorbar(im1, ax=axes[0, 0], label='Success %')
    
    # Weather comparison
    weather_conditions = ['clear', 'cloudy', 'light_rain', 'heavy_rain', 'snow']
    wake_time_scenarios = [(6.0, 6.0), (6.5, 6.5), (7.0, 7.0), (7.5, 7.5)]
    scenario_labels = ['Both 6:00', 'Both 6:30', 'Both 7:00', 'Both 7:30']
    
    weather_data = []
    for scenario, label in zip(wake_time_scenarios, scenario_labels):
        probs = []
        for weather in weather_conditions:
            prob, _ = model.predict(weather, 'weekday', scenario[0], scenario[1])
            probs.append(prob)
        weather_data.append(probs)
    
    x_pos = np.arange(len(weather_conditions))
    width = 0.2
    
    for i, (probs, label) in enumerate(zip(weather_data, scenario_labels)):
        axes[0, 1].bar(x_pos + i*width, probs, width, label=label)
    
    axes[0, 1].set_xlabel('Weather Condition')
    axes[0, 1].set_ylabel('Success Probability (%)')
    axes[0, 1].set_title('Weather Impact by Wake Time Scenario')
    axes[0, 1].set_xticks(x_pos + width * 1.5)
    axes[0, 1].set_xticklabels([w.replace('_', ' ').title() for w in weather_conditions], rotation=45)
    axes[0, 1].legend()
    
    # Day type comparison
    day_scenarios = []
    for day_type in ['weekday', 'weekend']:
        probs = []
        for wake_time in wake_times[::2]:  # Sample every other point
            prob, _ = model.predict('clear', day_type, wake_time, wake_time)
            probs.append(prob)
        day_scenarios.append(probs)
    
    axes[1, 0].plot(wake_times[::2], day_scenarios[0], 'b-', linewidth=2, marker='o', label='Weekday')
    axes[1, 0].plot(wake_times[::2], day_scenarios[1], 'r-', linewidth=2, marker='s', label='Weekend')
    axes[1, 0].set_xlabel('Wake Time (hours)')
    axes[1, 0].set_ylabel('Success Probability (%)')
    axes[1, 0].set_title('Weekday vs Weekend Comparison')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)
    
    # Run duration impact
    parent_b_times = np.linspace(5.5, 8.0, 15)
    run_durations = []
    final_probs = []
    
    for pb_time in parent_b_times:
        prob, inter = model.predict('clear', 'weekday', 6.0, pb_time)
        run_durations.append(inter['run_duration'])
        final_probs.append(prob)
    
    ax2 = axes[1, 1].twinx()
    line1 = axes[1, 1].plot(parent_b_times, run_durations, 'b-', linewidth=2, marker='o', label='Run Duration')
    line2 = ax2.plot(parent_b_times, final_probs, 'r-', linewidth=2, marker='s', label='Success Probability')
    
    axes[1, 1].set_xlabel('Parent B Wake Time (hours)')
    axes[1, 1].set_ylabel('Run Duration (minutes)', color='b')
    ax2.set_ylabel('Success Probability (%)', color='r')
    axes[1, 1].set_title('Run Duration Impact on Success')
    
    # Combine legends
    lines1, labels1 = axes[1, 1].get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    axes[1, 1].legend(lines1 + lines2, labels1 + labels2, loc='center right')
    
    plt.tight_layout()
    plt.savefig('system_responses.png', dpi=300, bbox_inches='tight')
    plt.show()

def plot_architecture_diagram():
    """Create a visual representation of the system architecture."""
    
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Title
    ax.text(5, 11.5, 'Hierarchical Fuzzy Logic Model Architecture', 
            ha='center', va='center', fontsize=16, fontweight='bold')
    
    # Level boxes and text
    levels = [
        (1, 10.5, 8, 0.8, "Level 0: Independent Variables\n• Weather • Day Type • Parent A Wake • Parent B Wake"),
        (1, 9, 8, 0.8, "Level 1: Primary Decision Nodes\n• Run Decision • Base Parent Availability"),
        (1, 7.5, 8, 0.8, "Level 2: Adjusted Assessment\n• Final Parent Availability • Weather Travel Impact"),
        (1, 6, 8, 0.8, "Level 3: Morning Routine Efficiency\n• Breakfast • Dressing • Transportation Logistics"),
        (1, 4.5, 8, 0.8, "Level 4: Consolidated Assessments\n• Morning Routine Efficiency"),
        (1, 3, 8, 0.8, "Level 5: Final Assessment\n• School Arrival Probability")
    ]
    
    colors = ['lightblue', 'lightgreen', 'lightyellow', 'lightcoral', 'lightpink', 'lightgray']
    
    for i, (x, y, w, h, text) in enumerate(levels):
        # Draw box
        rect = plt.Rectangle((x, y-h/2), w, h, facecolor=colors[i], edgecolor='black', linewidth=1)
        ax.add_patch(rect)
        
        # Add text
        ax.text(x + w/2, y, text, ha='center', va='center', fontsize=10, 
                bbox=dict(boxstyle="round,pad=0.3", facecolor='white', alpha=0.8))
    
    # Draw arrows between levels
    arrow_props = dict(arrowstyle='->', lw=2, color='darkblue')
    
    for i in range(len(levels)-1):
        y_start = levels[i][1] - levels[i][3]/2
        y_end = levels[i+1][1] + levels[i+1][3]/2
        ax.annotate('', xy=(5, y_end), xytext=(5, y_start), arrowprops=arrow_props)
    
    # Add special rules arrows (dotted)
    special_arrow_props = dict(arrowstyle='->', lw=2, color='red', linestyle='--')
    ax.annotate('Special Rules', xy=(7.5, 3.5), xytext=(7.5, 10), 
                arrowprops=special_arrow_props, fontsize=9, color='red')
    
    # Add data flow description
    ax.text(0.5, 2, 'Data Flow:\n• Weather influences multiple pathways\n• Hierarchical processing with feedback\n• Special rules for optimal conditions', 
            fontsize=10, bbox=dict(boxstyle="round,pad=0.5", facecolor='lightyellow'))
    
    plt.savefig('architecture_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

if __name__ == "__main__":
    print("Generating fuzzy logic visualizations...")
    
    plot_membership_functions()
    plot_system_responses()
    plot_architecture_diagram()
    
    print("All visualizations generated successfully!")