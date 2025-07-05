function dressing_time = compute_dressing_efficiency(final_availability)
    % COMPUTE_DRESSING_EFFICIENCY Calculate dressing completion time based on parent availability
    %
    % Input:
    %   final_availability - numeric: final parent availability score (0-10)
    %
    % Output:
    %   dressing_time - numeric: dressing completion time in minutes (10-40)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'DressingEfficiency');
    
    % Add input variable
    fis = addInput(fis, [0 10], 'Name', 'ParentAvailability');
    
    % Add output variable
    fis = addOutput(fis, [10 40], 'Name', 'DressingTime');
    
    % Define membership functions for Parent Availability
    fis = addMF(fis, 'ParentAvailability', 'trapmf', [0 0 2 3], 'Name', 'Low');
    fis = addMF(fis, 'ParentAvailability', 'trimf', [2 5 8], 'Name', 'Medium');
    fis = addMF(fis, 'ParentAvailability', 'trapmf', [7 8 10 10], 'Name', 'High');
    
    % Define membership functions for Dressing Time
    fis = addMF(fis, 'DressingTime', 'trapmf', [10 10 15 18], 'Name', 'Quick');
    fis = addMF(fis, 'DressingTime', 'trimf', [16 25 34], 'Name', 'Normal');
    fis = addMF(fis, 'DressingTime', 'trapmf', [32 36 40 40], 'Name', 'Slow');
    
    % Define rules
    ruleList = [
        3 1 1 1;  % IF High availability THEN Quick dressing
        2 2 1 1;  % IF Medium availability THEN Normal dressing
        1 3 1 1;  % IF Low availability THEN Slow dressing
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    dressing_time = evalfis(fis, final_availability);
    
    % Ensure output is within bounds
    dressing_time = max(10, min(40, dressing_time));
end