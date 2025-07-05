function [success_prob, intermediate_outputs] = school_commute_fuzzy_model(weather, day_type, parentA_wake, parentB_wake)
    % SCHOOL_COMMUTE_FUZZY_MODEL Hierarchical fuzzy logic model for school commute success
    %
    % Inputs:
    %   weather - string: 'clear', 'cloudy', 'light_rain', 'heavy_rain', 'snow'
    %   day_type - string: 'weekday', 'weekend'
    %   parentA_wake - numeric: wake time in decimal hours (5.5-8.5)
    %   parentB_wake - numeric: wake time in decimal hours (5.5-8.5)
    %
    % Outputs:
    %   success_prob - numeric: probability of successful school arrival (0-100%)
    %   intermediate_outputs - struct: contains all intermediate node outputs
    
    % Initialize intermediate outputs structure
    intermediate_outputs = struct();
    
    % Convert categorical inputs to numeric for fuzzy processing
    weather_num = convert_weather_to_numeric(weather);
    day_type_num = strcmp(day_type, 'weekday'); % 1 for weekday, 0 for weekend
    
    % LEVEL 1: Primary Decision Nodes
    run_duration = compute_run_decision(parentB_wake, weather_num, day_type_num);
    base_availability = compute_base_parent_availability(parentA_wake, parentB_wake);
    
    intermediate_outputs.run_duration = run_duration;
    intermediate_outputs.base_availability = base_availability;
    
    % LEVEL 2: Adjusted Availability Assessment
    final_availability = compute_final_parent_availability(base_availability, run_duration);
    weather_travel_multiplier = compute_weather_travel_impact(weather_num);
    
    intermediate_outputs.final_availability = final_availability;
    intermediate_outputs.weather_travel_multiplier = weather_travel_multiplier;
    
    % LEVEL 3: Morning Routine Efficiency
    breakfast_time = compute_breakfast_efficiency(final_availability);
    dressing_time = compute_dressing_efficiency(final_availability);
    transport_efficiency = compute_transportation_logistics(final_availability, day_type_num);
    
    intermediate_outputs.breakfast_time = breakfast_time;
    intermediate_outputs.dressing_time = dressing_time;
    intermediate_outputs.transport_efficiency = transport_efficiency;
    
    % LEVEL 4: Consolidated Assessments
    routine_efficiency = compute_morning_routine_efficiency(breakfast_time, dressing_time);
    
    intermediate_outputs.routine_efficiency = routine_efficiency;
    
    % LEVEL 5: Final Assessment
    % Pass additional context for special rules
    success_prob = compute_school_arrival_probability(routine_efficiency, ...
        transport_efficiency, weather_travel_multiplier, ...
        parentA_wake, parentB_wake, weather_num, run_duration);
    
end

function weather_num = convert_weather_to_numeric(weather)
    % Convert weather string to numeric value for fuzzy processing
    % clear=1, cloudy=2, light_rain=3, heavy_rain=4, snow=5
    
    weather_map = containers.Map({'clear', 'cloudy', 'light_rain', 'heavy_rain', 'snow'}, ...
                                 [1, 2, 3, 4, 5]);
    
    if isKey(weather_map, weather)
        weather_num = weather_map(weather);
    else
        error('Invalid weather condition: %s', weather);
    end
end