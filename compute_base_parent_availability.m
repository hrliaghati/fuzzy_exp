function base_availability = compute_base_parent_availability(parentA_wake, parentB_wake)
    % COMPUTE_BASE_PARENT_AVAILABILITY Assess availability purely from wake times
    %
    % Inputs:
    %   parentA_wake - numeric: wake time in decimal hours (5.5-8.5)
    %   parentB_wake - numeric: wake time in decimal hours (5.5-8.5)
    %
    % Output:
    %   base_availability - numeric: base availability score (0-10)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'BaseParentAvailability');
    
    % Add input variables
    fis = addInput(fis, [5.5 8.5], 'Name', 'ParentAWakeTime');
    fis = addInput(fis, [5.5 8.5], 'Name', 'ParentBWakeTime');
    
    % Add output variable
    fis = addOutput(fis, [0 10], 'Name', 'BaseAvailability');
    
    % Define membership functions for Parent A Wake Time
    fis = addMF(fis, 'ParentAWakeTime', 'trapmf', [5.5 5.5 6.0 6.5], 'Name', 'Early');
    fis = addMF(fis, 'ParentAWakeTime', 'trimf', [6.0 6.75 7.5], 'Name', 'Normal');
    fis = addMF(fis, 'ParentAWakeTime', 'trapmf', [7.0 7.5 8.5 8.5], 'Name', 'Late');
    
    % Define membership functions for Parent B Wake Time
    fis = addMF(fis, 'ParentBWakeTime', 'trapmf', [5.5 5.5 6.0 6.5], 'Name', 'Early');
    fis = addMF(fis, 'ParentBWakeTime', 'trimf', [6.0 6.75 7.5], 'Name', 'Normal');
    fis = addMF(fis, 'ParentBWakeTime', 'trapmf', [7.0 7.5 8.5 8.5], 'Name', 'Late');
    
    % Define membership functions for Base Availability
    fis = addMF(fis, 'BaseAvailability', 'trapmf', [0 0 2 3], 'Name', 'Low');
    fis = addMF(fis, 'BaseAvailability', 'trimf', [2 5 8], 'Name', 'Medium');
    fis = addMF(fis, 'BaseAvailability', 'trapmf', [7 8 10 10], 'Name', 'High');
    
    % Define rules based on wake time coordination
    ruleList = [
        % Both early → high base availability
        1 1 3 1 1;  % IF ParentA Early AND ParentB Early THEN High
        
        % One early, one normal → medium-high availability
        1 2 3 0.8 1;  % IF ParentA Early AND ParentB Normal THEN High (0.8 weight)
        2 1 3 0.8 1;  % IF ParentA Normal AND ParentB Early THEN High (0.8 weight)
        
        % Both normal → medium availability
        2 2 2 1 1;  % IF ParentA Normal AND ParentB Normal THEN Medium
        
        % One early, one late → medium availability
        1 3 2 1 1;  % IF ParentA Early AND ParentB Late THEN Medium
        3 1 2 1 1;  % IF ParentA Late AND ParentB Early THEN Medium
        
        % One normal, one late → low-medium availability
        2 3 2 0.7 1;  % IF ParentA Normal AND ParentB Late THEN Medium (0.7 weight)
        3 2 2 0.7 1;  % IF ParentA Late AND ParentB Normal THEN Medium (0.7 weight)
        
        % Both late → low base availability
        3 3 1 1 1;  % IF ParentA Late AND ParentB Late THEN Low
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    base_availability = evalfis(fis, [parentA_wake, parentB_wake]);
    
    % Ensure output is within bounds
    base_availability = max(0, min(10, base_availability));
end