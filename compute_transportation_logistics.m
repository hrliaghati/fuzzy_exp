function transport_efficiency = compute_transportation_logistics(final_availability, day_type_num)
    % COMPUTE_TRANSPORTATION_LOGISTICS Calculate transportation efficiency score
    %
    % Inputs:
    %   final_availability - numeric: final parent availability score (0-10)
    %   day_type_num - numeric: 1=weekday, 0=weekend
    %
    % Output:
    %   transport_efficiency - numeric: transportation efficiency score (0-10)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'TransportationLogistics');
    
    % Add input variables
    fis = addInput(fis, [0 10], 'Name', 'ParentAvailability');
    fis = addInput(fis, [0 1], 'Name', 'DayType');
    
    % Add output variable
    fis = addOutput(fis, [0 10], 'Name', 'TransportEfficiency');
    
    % Define membership functions for Parent Availability
    fis = addMF(fis, 'ParentAvailability', 'trapmf', [0 0 2 3], 'Name', 'Low');
    fis = addMF(fis, 'ParentAvailability', 'trimf', [2 5 8], 'Name', 'Medium');
    fis = addMF(fis, 'ParentAvailability', 'trapmf', [7 8 10 10], 'Name', 'High');
    
    % Define membership functions for Day Type
    fis = addMF(fis, 'DayType', 'trimf', [-0.5 0 0.5], 'Name', 'Weekend');
    fis = addMF(fis, 'DayType', 'trimf', [0.5 1 1.5], 'Name', 'Weekday');
    
    % Define membership functions for Transport Efficiency
    fis = addMF(fis, 'TransportEfficiency', 'trapmf', [0 0 2 3], 'Name', 'Poor');
    fis = addMF(fis, 'TransportEfficiency', 'trimf', [2 5 8], 'Name', 'Moderate');
    fis = addMF(fis, 'TransportEfficiency', 'trapmf', [7 8 10 10], 'Name', 'Excellent');
    
    % Define rules
    ruleList = [
        % High availability rules
        3 1 3 1 1;  % IF High availability AND Weekend THEN Excellent
        3 2 3 0.9 1;  % IF High availability AND Weekday THEN Excellent (slightly reduced)
        
        % Medium availability rules
        2 1 2 1 1;  % IF Medium availability AND Weekend THEN Moderate
        2 2 2 0.8 1;  % IF Medium availability AND Weekday THEN Moderate (reduced)
        
        % Low availability rules
        1 1 1 0.8 1;  % IF Low availability AND Weekend THEN Poor (slightly better)
        1 2 1 1 1;  % IF Low availability AND Weekday THEN Poor
        
        % Additional nuanced rules
        3 2 2 0.3 1;  % IF High availability AND Weekday THEN also some Moderate
        1 1 2 0.2 1;  % IF Low availability AND Weekend THEN also slight Moderate
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    transport_efficiency = evalfis(fis, [final_availability, day_type_num]);
    
    % Ensure output is within bounds
    transport_efficiency = max(0, min(10, transport_efficiency));
end