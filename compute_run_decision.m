function run_duration = compute_run_decision(parentB_wake, weather_num, day_type_num)
    % COMPUTE_RUN_DECISION Models how weather and schedule affect Parent B's running decision
    %
    % Inputs:
    %   parentB_wake - numeric: wake time in decimal hours (5.5-8.5)
    %   weather_num - numeric: 1=clear, 2=cloudy, 3=light_rain, 4=heavy_rain, 5=snow
    %   day_type_num - numeric: 1=weekday, 0=weekend
    %
    % Output:
    %   run_duration - numeric: actual run duration in minutes (0-120)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'RunDecision');
    
    % Add input variables
    fis = addInput(fis, [5.5 8.5], 'Name', 'ParentBWakeTime');
    fis = addInput(fis, [1 5], 'Name', 'Weather');
    fis = addInput(fis, [0 1], 'Name', 'DayType');
    
    % Add output variable
    fis = addOutput(fis, [0 120], 'Name', 'RunDuration');
    
    % Define membership functions for Parent B Wake Time
    fis = addMF(fis, 'ParentBWakeTime', 'trapmf', [5.5 5.5 6.0 6.25], 'Name', 'VeryEarly');
    fis = addMF(fis, 'ParentBWakeTime', 'trimf', [6.0 6.5 7.0], 'Name', 'Early');
    fis = addMF(fis, 'ParentBWakeTime', 'trimf', [6.5 7.0 7.5], 'Name', 'Normal');
    fis = addMF(fis, 'ParentBWakeTime', 'trapmf', [7.0 7.5 8.5 8.5], 'Name', 'Late');
    
    % Define membership functions for Weather
    fis = addMF(fis, 'Weather', 'trapmf', [1 1 2 2.5], 'Name', 'GoodRunning');
    fis = addMF(fis, 'Weather', 'trimf', [2.5 3 3.5], 'Name', 'PoorRunning');
    fis = addMF(fis, 'Weather', 'trapmf', [3.5 4 5 5], 'Name', 'BadRunning');
    
    % Define membership functions for Day Type
    fis = addMF(fis, 'DayType', 'trimf', [-0.5 0 0.5], 'Name', 'Weekend');
    fis = addMF(fis, 'DayType', 'trimf', [0.5 1 1.5], 'Name', 'Weekday');
    
    % Define membership functions for Run Duration
    fis = addMF(fis, 'RunDuration', 'trapmf', [0 0 5 10], 'Name', 'None');
    fis = addMF(fis, 'RunDuration', 'trimf', [10 20 30], 'Name', 'Short');
    fis = addMF(fis, 'RunDuration', 'trimf', [25 37.5 50], 'Name', 'Medium');
    fis = addMF(fis, 'RunDuration', 'trimf', [45 67.5 90], 'Name', 'Long');
    fis = addMF(fis, 'RunDuration', 'trapmf', [80 100 120 120], 'Name', 'VeryLong');
    
    % Define rules
    ruleList = [
        % Bad weather (heavy rain/snow) overrides everything - no running
        1 3 1 1 1 1;  % IF VeryEarly AND BadRunning AND Weekday THEN None
        1 3 2 1 1 1;  % IF VeryEarly AND BadRunning AND Weekend THEN None
        2 3 1 1 1 1;  % IF Early AND BadRunning AND Weekday THEN None
        2 3 2 1 1 1;  % IF Early AND BadRunning AND Weekend THEN None
        3 3 1 1 1 1;  % IF Normal AND BadRunning AND Weekday THEN None
        3 3 2 1 1 1;  % IF Normal AND BadRunning AND Weekend THEN None
        4 3 1 1 1 1;  % IF Late AND BadRunning AND Weekday THEN None
        4 3 2 1 1 1;  % IF Late AND BadRunning AND Weekend THEN None
        
        % Very early wake time rules
        1 1 2 5 1 1;  % IF VeryEarly AND GoodRunning AND Weekend THEN VeryLong
        1 1 1 4 1 1;  % IF VeryEarly AND GoodRunning AND Weekday THEN Long
        1 2 2 3 1 1;  % IF VeryEarly AND PoorRunning AND Weekend THEN Medium
        1 2 1 2 1 1;  % IF VeryEarly AND PoorRunning AND Weekday THEN Short
        
        % Early wake time rules
        2 1 2 4 1 1;  % IF Early AND GoodRunning AND Weekend THEN Long
        2 1 1 3 1 1;  % IF Early AND GoodRunning AND Weekday THEN Medium
        2 2 2 2 1 1;  % IF Early AND PoorRunning AND Weekend THEN Short
        2 2 1 2 1 1;  % IF Early AND PoorRunning AND Weekday THEN Short
        
        % Normal wake time rules
        3 1 2 3 1 1;  % IF Normal AND GoodRunning AND Weekend THEN Medium
        3 1 1 2 1 1;  % IF Normal AND GoodRunning AND Weekday THEN Short
        3 2 2 2 1 1;  % IF Normal AND PoorRunning AND Weekend THEN Short
        3 2 1 1 1 1;  % IF Normal AND PoorRunning AND Weekday THEN None
        
        % Late wake time rules
        4 1 2 2 1 1;  % IF Late AND GoodRunning AND Weekend THEN Short
        4 1 1 1 1 1;  % IF Late AND GoodRunning AND Weekday THEN None
        4 2 1 1 1 1;  % IF Late AND PoorRunning AND Weekday THEN None
        4 2 2 1 1 1;  % IF Late AND PoorRunning AND Weekend THEN None
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    run_duration = evalfis(fis, [parentB_wake, weather_num, day_type_num]);
    
    % Ensure output is within bounds
    run_duration = max(0, min(120, run_duration));
end