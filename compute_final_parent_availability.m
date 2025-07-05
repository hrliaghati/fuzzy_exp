function final_availability = compute_final_parent_availability(base_availability, run_duration)
    % COMPUTE_FINAL_PARENT_AVAILABILITY Adjust base availability for time lost to running
    %
    % Inputs:
    %   base_availability - numeric: base availability score (0-10)
    %   run_duration - numeric: actual run duration in minutes (0-120)
    %
    % Output:
    %   final_availability - numeric: final availability score (0-10)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'FinalParentAvailability');
    
    % Add input variables
    fis = addInput(fis, [0 10], 'Name', 'BaseAvailability');
    fis = addInput(fis, [0 120], 'Name', 'RunDuration');
    
    % Add output variable
    fis = addOutput(fis, [0 10], 'Name', 'FinalAvailability');
    
    % Define membership functions for Base Availability
    fis = addMF(fis, 'BaseAvailability', 'trapmf', [0 0 2 3], 'Name', 'Low');
    fis = addMF(fis, 'BaseAvailability', 'trimf', [2 5 8], 'Name', 'Medium');
    fis = addMF(fis, 'BaseAvailability', 'trapmf', [7 8 10 10], 'Name', 'High');
    
    % Define membership functions for Run Duration
    fis = addMF(fis, 'RunDuration', 'trapmf', [0 0 5 10], 'Name', 'None');
    fis = addMF(fis, 'RunDuration', 'trimf', [5 20 35], 'Name', 'Short');
    fis = addMF(fis, 'RunDuration', 'trimf', [30 45 60], 'Name', 'Medium');
    fis = addMF(fis, 'RunDuration', 'trimf', [55 75 95], 'Name', 'Long');
    fis = addMF(fis, 'RunDuration', 'trapmf', [90 100 120 120], 'Name', 'VeryLong');
    
    % Define membership functions for Final Availability
    fis = addMF(fis, 'FinalAvailability', 'trapmf', [0 0 2 3], 'Name', 'Low');
    fis = addMF(fis, 'FinalAvailability', 'trimf', [2 5 8], 'Name', 'Medium');
    fis = addMF(fis, 'FinalAvailability', 'trapmf', [7 8 10 10], 'Name', 'High');
    
    % Define rules for availability adjustment based on run duration
    ruleList = [
        % No run - no reduction
        1 1 1 1 1;  % IF Low AND None THEN Low
        2 1 2 1 1;  % IF Medium AND None THEN Medium
        3 1 3 1 1;  % IF High AND None THEN High
        
        % Short run - minor reduction
        1 2 1 1 1;  % IF Low AND Short THEN Low
        2 2 2 0.9 1;  % IF Medium AND Short THEN Medium (slight reduction)
        3 2 3 0.85 1;  % IF High AND Short THEN High (slight reduction)
        
        % Medium run - moderate reduction
        1 3 1 1 1;  % IF Low AND Medium THEN Low
        2 3 2 0.8 1;  % IF Medium AND Medium THEN Medium (reduced)
        3 3 2 1 1;  % IF High AND Medium THEN Medium
        
        % Long run - major reduction
        1 4 1 1 1;  % IF Low AND Long THEN Low
        2 4 1 0.8 1;  % IF Medium AND Long THEN Low (high weight)
        3 4 2 0.7 1;  % IF High AND Long THEN Medium (reduced)
        
        % Very long run - severe reduction
        1 5 1 1 1;  % IF Low AND VeryLong THEN Low
        2 5 1 1 1;  % IF Medium AND VeryLong THEN Low
        3 5 1 0.5 1;  % IF High AND VeryLong THEN Low (some medium possible)
        3 5 2 0.5 1;  % IF High AND VeryLong THEN Medium (low weight)
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    final_availability = evalfis(fis, [base_availability, run_duration]);
    
    % Ensure output is within bounds
    final_availability = max(0, min(10, final_availability));
end