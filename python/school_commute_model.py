"""
School Commute Fuzzy Logic Surrogate Model - Python Implementation

This module provides a hierarchical fuzzy logic surrogate model that predicts 
the probability of successfully getting children to school on time based on 
family morning routine parameters and environmental conditions.
"""

import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl
from typing import Dict, Tuple, Union
import warnings

class SchoolCommuteFuzzyModel:
    """
    Hierarchical fuzzy logic model for school commute success prediction.
    """
    
    def __init__(self):
        """Initialize the fuzzy logic model with all subsystems."""
        self.weather_map = {
            'clear': 1, 'cloudy': 2, 'light_rain': 3, 
            'heavy_rain': 4, 'snow': 5
        }
        
    def predict(self, weather: str, day_type: str, 
                parent_a_wake: float, parent_b_wake: float) -> Tuple[float, Dict]:
        """
        Predict school commute success probability.
        
        Parameters:
        -----------
        weather : str
            Weather condition ('clear', 'cloudy', 'light_rain', 'heavy_rain', 'snow')
        day_type : str
            Day type ('weekday', 'weekend')
        parent_a_wake : float
            Parent A wake time in decimal hours (5.5-8.5)
        parent_b_wake : float
            Parent B wake time in decimal hours (5.5-8.5)
            
        Returns:
        --------
        tuple
            (success_probability, intermediate_outputs)
        """
        
        # Convert inputs
        weather_num = self.weather_map[weather]
        day_type_num = 1 if day_type == 'weekday' else 0
        
        # Initialize outputs dictionary
        intermediate = {}
        
        # LEVEL 1: Primary Decision Nodes
        run_duration = self._compute_run_decision(parent_b_wake, weather_num, day_type_num)
        base_availability = self._compute_base_parent_availability(parent_a_wake, parent_b_wake)
        
        intermediate['run_duration'] = run_duration
        intermediate['base_availability'] = base_availability
        
        # LEVEL 2: Adjusted Availability Assessment
        final_availability = self._compute_final_parent_availability(base_availability, run_duration)
        weather_travel_multiplier = self._compute_weather_travel_impact(weather_num)
        
        intermediate['final_availability'] = final_availability
        intermediate['weather_travel_multiplier'] = weather_travel_multiplier
        
        # LEVEL 3: Morning Routine Efficiency
        breakfast_time = self._compute_breakfast_efficiency(final_availability)
        dressing_time = self._compute_dressing_efficiency(final_availability)
        transport_efficiency = self._compute_transportation_logistics(final_availability, day_type_num)
        
        intermediate['breakfast_time'] = breakfast_time
        intermediate['dressing_time'] = dressing_time
        intermediate['transport_efficiency'] = transport_efficiency
        
        # LEVEL 4: Consolidated Assessments
        routine_efficiency = self._compute_morning_routine_efficiency(breakfast_time, dressing_time)
        
        intermediate['routine_efficiency'] = routine_efficiency
        
        # LEVEL 5: Final Assessment
        success_prob = self._compute_school_arrival_probability(
            routine_efficiency, transport_efficiency, weather_travel_multiplier,
            parent_a_wake, parent_b_wake, weather_num, run_duration
        )
        
        return success_prob, intermediate
    
    def _compute_run_decision(self, parent_b_wake: float, weather_num: int, day_type_num: int) -> float:
        """Compute Parent B's running decision based on inputs."""
        
        # Create fuzzy variables
        parent_b_wake_range = np.arange(5.5, 8.51, 0.01)
        weather_range = np.arange(1, 5.01, 0.01)
        day_type_range = np.arange(0, 1.01, 0.01)
        run_duration_range = np.arange(0, 120.01, 0.1)
        
        # Parent B Wake Time membership functions
        pb_very_early = fuzz.trapmf(parent_b_wake_range, [5.5, 5.5, 6.0, 6.25])
        pb_early = fuzz.trimf(parent_b_wake_range, [6.0, 6.5, 7.0])
        pb_normal = fuzz.trimf(parent_b_wake_range, [6.5, 7.0, 7.5])
        pb_late = fuzz.trapmf(parent_b_wake_range, [7.0, 7.5, 8.5, 8.5])
        
        # Weather membership functions
        weather_good = fuzz.trapmf(weather_range, [1, 1, 2, 2.5])
        weather_poor = fuzz.trimf(weather_range, [2.5, 3, 3.5])
        weather_bad = fuzz.trapmf(weather_range, [3.5, 4, 5, 5])
        
        # Day type membership functions
        day_weekend = fuzz.trimf(day_type_range, [-0.5, 0, 0.5])
        day_weekday = fuzz.trimf(day_type_range, [0.5, 1, 1.5])
        
        # Run duration membership functions
        run_none = fuzz.trapmf(run_duration_range, [0, 0, 5, 10])
        run_short = fuzz.trimf(run_duration_range, [10, 20, 30])
        run_medium = fuzz.trimf(run_duration_range, [25, 37.5, 50])
        run_long = fuzz.trimf(run_duration_range, [45, 67.5, 90])
        run_very_long = fuzz.trapmf(run_duration_range, [80, 100, 120, 120])
        
        # Compute membership values
        pb_wake_memberships = {
            'very_early': fuzz.interp_membership(parent_b_wake_range, pb_very_early, parent_b_wake),
            'early': fuzz.interp_membership(parent_b_wake_range, pb_early, parent_b_wake),
            'normal': fuzz.interp_membership(parent_b_wake_range, pb_normal, parent_b_wake),
            'late': fuzz.interp_membership(parent_b_wake_range, pb_late, parent_b_wake)
        }
        
        weather_memberships = {
            'good': fuzz.interp_membership(weather_range, weather_good, weather_num),
            'poor': fuzz.interp_membership(weather_range, weather_poor, weather_num),
            'bad': fuzz.interp_membership(weather_range, weather_bad, weather_num)
        }
        
        day_memberships = {
            'weekend': fuzz.interp_membership(day_type_range, day_weekend, day_type_num),
            'weekday': fuzz.interp_membership(day_type_range, day_weekday, day_type_num)
        }
        
        # Apply fuzzy rules
        rules_output = np.zeros_like(run_duration_range)
        
        # Bad weather overrides everything - no running
        bad_weather_activation = weather_memberships['bad']
        rules_output = np.fmax(rules_output, bad_weather_activation * run_none)
        
        # Very early wake time rules
        if pb_wake_memberships['very_early'] > 0:
            # VeryEarly AND Good AND Weekend -> VeryLong
            activation = np.fmin(pb_wake_memberships['very_early'], 
                               np.fmin(weather_memberships['good'], day_memberships['weekend']))
            rules_output = np.fmax(rules_output, activation * run_very_long)
            
            # VeryEarly AND Good AND Weekday -> Long
            activation = np.fmin(pb_wake_memberships['very_early'], 
                               np.fmin(weather_memberships['good'], day_memberships['weekday']))
            rules_output = np.fmax(rules_output, activation * run_long)
            
            # VeryEarly AND Poor AND Weekend -> Medium
            activation = np.fmin(pb_wake_memberships['very_early'], 
                               np.fmin(weather_memberships['poor'], day_memberships['weekend']))
            rules_output = np.fmax(rules_output, activation * run_medium)
            
            # VeryEarly AND Poor AND Weekday -> Short
            activation = np.fmin(pb_wake_memberships['very_early'], 
                               np.fmin(weather_memberships['poor'], day_memberships['weekday']))
            rules_output = np.fmax(rules_output, activation * run_short)
        
        # Early wake time rules
        if pb_wake_memberships['early'] > 0:
            # Early AND Good AND Weekend -> Long
            activation = np.fmin(pb_wake_memberships['early'], 
                               np.fmin(weather_memberships['good'], day_memberships['weekend']))
            rules_output = np.fmax(rules_output, activation * run_long)
            
            # Early AND Good AND Weekday -> Medium
            activation = np.fmin(pb_wake_memberships['early'], 
                               np.fmin(weather_memberships['good'], day_memberships['weekday']))
            rules_output = np.fmax(rules_output, activation * run_medium)
            
            # Early AND Poor -> Short
            activation = np.fmin(pb_wake_memberships['early'], weather_memberships['poor'])
            rules_output = np.fmax(rules_output, activation * run_short)
        
        # Normal wake time rules
        if pb_wake_memberships['normal'] > 0:
            # Normal AND Good AND Weekend -> Medium
            activation = np.fmin(pb_wake_memberships['normal'], 
                               np.fmin(weather_memberships['good'], day_memberships['weekend']))
            rules_output = np.fmax(rules_output, activation * run_medium)
            
            # Normal AND Good AND Weekday -> Short
            activation = np.fmin(pb_wake_memberships['normal'], 
                               np.fmin(weather_memberships['good'], day_memberships['weekday']))
            rules_output = np.fmax(rules_output, activation * run_short)
            
            # Normal AND Poor AND Weekend -> Short
            activation = np.fmin(pb_wake_memberships['normal'], 
                               np.fmin(weather_memberships['poor'], day_memberships['weekend']))
            rules_output = np.fmax(rules_output, activation * run_short)
            
            # Normal AND Poor AND Weekday -> None
            activation = np.fmin(pb_wake_memberships['normal'], 
                               np.fmin(weather_memberships['poor'], day_memberships['weekday']))
            rules_output = np.fmax(rules_output, activation * run_none)
        
        # Late wake time rules
        if pb_wake_memberships['late'] > 0:
            # Late AND Good AND Weekend -> Short
            activation = np.fmin(pb_wake_memberships['late'], 
                               np.fmin(weather_memberships['good'], day_memberships['weekend']))
            rules_output = np.fmax(rules_output, activation * run_short)
            
            # Late AND (Poor OR Bad OR Weekday) -> None
            activation = np.fmin(pb_wake_memberships['late'], 
                               np.fmax(weather_memberships['poor'], 
                                      np.fmax(weather_memberships['bad'], day_memberships['weekday'])))
            rules_output = np.fmax(rules_output, activation * run_none)
        
        # Defuzzify using centroid method
        try:
            run_duration = fuzz.defuzz(run_duration_range, rules_output, 'centroid')
        except:
            # Fallback if no rules fired
            run_duration = 5.0  # Default to minimal run
        
        return np.clip(run_duration, 0, 120)
    
    def _compute_base_parent_availability(self, parent_a_wake: float, parent_b_wake: float) -> float:
        """Compute base parent availability from wake times."""
        
        # Simple implementation based on wake time coordination
        # Both early (< 6.5) -> high availability (8-10)
        # One early, one normal -> medium availability (5-7)
        # Both late (> 7.0) -> low availability (1-3)
        
        if parent_a_wake <= 6.5 and parent_b_wake <= 6.5:
            return 8.5 + (6.5 - max(parent_a_wake, parent_b_wake)) * 1.0
        elif parent_a_wake <= 6.5 or parent_b_wake <= 6.5:
            return 6.0 + (6.5 - min(parent_a_wake, parent_b_wake)) * 0.5
        else:
            return max(1.0, 5.0 - (max(parent_a_wake, parent_b_wake) - 7.0) * 2.0)
    
    def _compute_final_parent_availability(self, base_availability: float, run_duration: float) -> float:
        """Adjust base availability for time lost to running."""
        
        # Reduce availability based on run duration
        if run_duration < 10:
            reduction = 0
        elif run_duration < 30:
            reduction = 0.75
        elif run_duration < 60:
            reduction = 1.75
        elif run_duration < 90:
            reduction = 2.75
        else:
            reduction = 3.5
        
        return np.clip(base_availability - reduction, 0, 10)
    
    def _compute_weather_travel_impact(self, weather_num: int) -> float:
        """Compute weather impact on travel time."""
        
        weather_impacts = {
            1: 1.0,   # clear
            2: 1.0,   # cloudy
            3: 1.2,   # light_rain
            4: 1.6,   # heavy_rain
            5: 2.2    # snow
        }
        
        return weather_impacts.get(weather_num, 1.0)
    
    def _compute_breakfast_efficiency(self, final_availability: float) -> float:
        """Compute breakfast completion time."""
        
        if final_availability >= 7:
            return 15.0  # Quick breakfast
        elif final_availability >= 4:
            return 27.5  # Normal breakfast
        else:
            return 40.0  # Slow breakfast
    
    def _compute_dressing_efficiency(self, final_availability: float) -> float:
        """Compute dressing completion time."""
        
        if final_availability >= 7:
            return 13.0  # Quick dressing
        elif final_availability >= 4:
            return 25.0  # Normal dressing
        else:
            return 36.0  # Slow dressing
    
    def _compute_transportation_logistics(self, final_availability: float, day_type_num: int) -> float:
        """Compute transportation efficiency."""
        
        base_score = final_availability
        
        # Weekdays are more challenging
        if day_type_num == 1:  # weekday
            base_score *= 0.9
        
        return np.clip(base_score, 0, 10)
    
    def _compute_morning_routine_efficiency(self, breakfast_time: float, dressing_time: float) -> float:
        """Consolidate breakfast and dressing times into routine efficiency."""
        
        total_time = breakfast_time + dressing_time
        
        # Convert total time to efficiency score (lower time = higher efficiency)
        if total_time <= 30:
            return 9.0  # Excellent
        elif total_time <= 50:
            return 6.0  # Moderate
        else:
            return 2.0  # Poor
    
    def _compute_school_arrival_probability(self, routine_efficiency: float, 
                                          transport_efficiency: float, 
                                          weather_travel_multiplier: float,
                                          parent_a_wake: float = None,
                                          parent_b_wake: float = None,
                                          weather_num: int = None,
                                          run_duration: float = None) -> float:
        """Compute final school arrival probability."""
        
        # Base calculation using fuzzy logic approach
        if routine_efficiency >= 7 and transport_efficiency >= 7 and weather_travel_multiplier <= 1.3:
            success_prob = 92.0  # Very high
        elif routine_efficiency >= 7 and transport_efficiency >= 4 and weather_travel_multiplier <= 1.3:
            success_prob = 85.0  # High
        elif routine_efficiency >= 4 and transport_efficiency >= 7 and weather_travel_multiplier <= 1.3:
            success_prob = 85.0  # High
        elif routine_efficiency >= 4 and transport_efficiency >= 4 and weather_travel_multiplier <= 1.3:
            success_prob = 60.0  # Medium
        elif weather_travel_multiplier > 2.0:
            success_prob = max(10.0, 60.0 - (weather_travel_multiplier - 1.0) * 30)  # Weather impact
        else:
            success_prob = 30.0  # Base case
        
        # Apply special rules if parameters provided
        if all(param is not None for param in [parent_a_wake, parent_b_wake, weather_num, run_duration]):
            # Special rule 1: Very early wake + clear weather + short/no run
            if (parent_a_wake <= 6.0 and parent_b_wake <= 6.0 and 
                weather_num <= 2 and run_duration < 30):
                success_prob = max(success_prob, 90.0)
            
            # Special rule 2: Very early wake + clear weather (general boost)
            if (parent_a_wake <= 6.0 and parent_b_wake <= 6.0 and weather_num == 1):
                success_prob = max(success_prob, 85.0)
        
        return np.clip(success_prob, 0, 100)


if __name__ == "__main__":
    # Example usage
    model = SchoolCommuteFuzzyModel()
    
    # Test case: Ideal conditions
    success_prob, intermediate = model.predict('clear', 'weekday', 6.0, 6.0)
    
    print("School Commute Fuzzy Logic Model - Test Results")
    print("=" * 50)
    print(f"Weather: clear, Day: weekday, Parent A: 6:00, Parent B: 6:00")
    print(f"Success Probability: {success_prob:.1f}%")
    print("\nIntermediate outputs:")
    for key, value in intermediate.items():
        print(f"  {key}: {value:.2f}")