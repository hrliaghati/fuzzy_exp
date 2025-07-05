function routine_efficiency = compute_morning_routine_efficiency(breakfast_time, dressing_time)
    % COMPUTE_MORNING_ROUTINE_EFFICIENCY Consolidate breakfast and dressing times into overall efficiency
    %
    % Inputs:
    %   breakfast_time - numeric: breakfast completion time in minutes (10-45)
    %   dressing_time - numeric: dressing completion time in minutes (10-40)
    %
    % Output:
    %   routine_efficiency - numeric: overall routine efficiency score (0-10)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'MorningRoutineEfficiency');
    
    % Add input variables
    fis = addInput(fis, [10 45], 'Name', 'BreakfastTime');
    fis = addInput(fis, [10 40], 'Name', 'DressingTime');
    
    % Add output variable
    fis = addOutput(fis, [0 10], 'Name', 'RoutineEfficiency');
    
    % Define membership functions for Breakfast Time
    fis = addMF(fis, 'BreakfastTime', 'trapmf', [10 10 15 20], 'Name', 'Quick');
    fis = addMF(fis, 'BreakfastTime', 'trimf', [18 27.5 37], 'Name', 'Normal');
    fis = addMF(fis, 'BreakfastTime', 'trapmf', [35 40 45 45], 'Name', 'Slow');
    
    % Define membership functions for Dressing Time
    fis = addMF(fis, 'DressingTime', 'trapmf', [10 10 15 18], 'Name', 'Quick');
    fis = addMF(fis, 'DressingTime', 'trimf', [16 25 34], 'Name', 'Normal');
    fis = addMF(fis, 'DressingTime', 'trapmf', [32 36 40 40], 'Name', 'Slow');
    
    % Define membership functions for Routine Efficiency
    fis = addMF(fis, 'RoutineEfficiency', 'trapmf', [0 0 2 3], 'Name', 'Poor');
    fis = addMF(fis, 'RoutineEfficiency', 'trimf', [2 5 8], 'Name', 'Moderate');
    fis = addMF(fis, 'RoutineEfficiency', 'trapmf', [7 8 10 10], 'Name', 'Excellent');
    
    % Define rules
    ruleList = [
        % Both quick → excellent efficiency
        1 1 3 1 1;  % IF Quick breakfast AND Quick dressing THEN Excellent
        
        % One quick, one normal → good efficiency
        1 2 3 0.8 1;  % IF Quick breakfast AND Normal dressing THEN Excellent (reduced)
        2 1 3 0.8 1;  % IF Normal breakfast AND Quick dressing THEN Excellent (reduced)
        
        % Both normal → moderate efficiency
        2 2 2 1 1;  % IF Normal breakfast AND Normal dressing THEN Moderate
        
        % One quick, one slow → moderate efficiency
        1 3 2 0.9 1;  % IF Quick breakfast AND Slow dressing THEN Moderate
        3 1 2 0.9 1;  % IF Slow breakfast AND Quick dressing THEN Moderate
        
        % One normal, one slow → poor-moderate efficiency
        2 3 2 0.5 1;  % IF Normal breakfast AND Slow dressing THEN Moderate (reduced)
        3 2 2 0.5 1;  % IF Slow breakfast AND Normal dressing THEN Moderate (reduced)
        2 3 1 0.5 1;  % IF Normal breakfast AND Slow dressing THEN Poor (partial)
        3 2 1 0.5 1;  % IF Slow breakfast AND Normal dressing THEN Poor (partial)
        
        % Both slow → poor efficiency
        3 3 1 1 1;  % IF Slow breakfast AND Slow dressing THEN Poor
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    routine_efficiency = evalfis(fis, [breakfast_time, dressing_time]);
    
    % Ensure output is within bounds
    routine_efficiency = max(0, min(10, routine_efficiency));
end