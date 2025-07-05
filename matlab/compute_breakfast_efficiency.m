function breakfast_time = compute_breakfast_efficiency(final_availability)
    % COMPUTE_BREAKFAST_EFFICIENCY Calculate breakfast completion time based on parent availability
    %
    % Input:
    %   final_availability - numeric: final parent availability score (0-10)
    %
    % Output:
    %   breakfast_time - numeric: breakfast completion time in minutes (10-45)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'BreakfastEfficiency');
    
    % Add input variable
    fis = addInput(fis, [0 10], 'Name', 'ParentAvailability');
    
    % Add output variable
    fis = addOutput(fis, [10 45], 'Name', 'BreakfastTime');
    
    % Define membership functions for Parent Availability
    fis = addMF(fis, 'ParentAvailability', 'trapmf', [0 0 2 3], 'Name', 'Low');
    fis = addMF(fis, 'ParentAvailability', 'trimf', [2 5 8], 'Name', 'Medium');
    fis = addMF(fis, 'ParentAvailability', 'trapmf', [7 8 10 10], 'Name', 'High');
    
    % Define membership functions for Breakfast Time
    fis = addMF(fis, 'BreakfastTime', 'trapmf', [10 10 15 20], 'Name', 'Quick');
    fis = addMF(fis, 'BreakfastTime', 'trimf', [18 27.5 37], 'Name', 'Normal');
    fis = addMF(fis, 'BreakfastTime', 'trapmf', [35 40 45 45], 'Name', 'Slow');
    
    % Define rules
    ruleList = [
        3 1 1 1;  % IF High availability THEN Quick breakfast
        2 2 1 1;  % IF Medium availability THEN Normal breakfast
        1 3 1 1;  % IF Low availability THEN Slow breakfast
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    breakfast_time = evalfis(fis, final_availability);
    
    % Ensure output is within bounds
    breakfast_time = max(10, min(45, breakfast_time));
end