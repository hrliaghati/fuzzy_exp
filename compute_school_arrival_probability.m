function success_prob = compute_school_arrival_probability(routine_efficiency, transport_efficiency, weather_travel_multiplier, varargin)
    % COMPUTE_SCHOOL_ARRIVAL_PROBABILITY Final assessment combining all factors
    %
    % Inputs:
    %   routine_efficiency - numeric: overall routine efficiency score (0-10)
    %   transport_efficiency - numeric: transportation efficiency score (0-10)
    %   weather_travel_multiplier - numeric: travel time multiplier (1.0-2.5)
    %   varargin - optional: parentA_wake, parentB_wake, weather_num, run_duration for special rules
    %
    % Output:
    %   success_prob - numeric: probability of successful school arrival (0-100%)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'SchoolArrivalProbability');
    
    % Add input variables
    fis = addInput(fis, [0 10], 'Name', 'RoutineEfficiency');
    fis = addInput(fis, [0 10], 'Name', 'TransportEfficiency');
    fis = addInput(fis, [1.0 2.5], 'Name', 'WeatherImpact');
    
    % Add output variable
    fis = addOutput(fis, [0 100], 'Name', 'SuccessProbability');
    
    % Define membership functions for Routine Efficiency
    fis = addMF(fis, 'RoutineEfficiency', 'trapmf', [0 0 2 3], 'Name', 'Poor');
    fis = addMF(fis, 'RoutineEfficiency', 'trimf', [2 5 8], 'Name', 'Moderate');
    fis = addMF(fis, 'RoutineEfficiency', 'trapmf', [7 8 10 10], 'Name', 'Excellent');
    
    % Define membership functions for Transport Efficiency
    fis = addMF(fis, 'TransportEfficiency', 'trapmf', [0 0 2 3], 'Name', 'Poor');
    fis = addMF(fis, 'TransportEfficiency', 'trimf', [2 5 8], 'Name', 'Moderate');
    fis = addMF(fis, 'TransportEfficiency', 'trapmf', [7 8 10 10], 'Name', 'Excellent');
    
    % Define membership functions for Weather Impact
    fis = addMF(fis, 'WeatherImpact', 'trapmf', [1.0 1.0 1.1 1.3], 'Name', 'Normal');
    fis = addMF(fis, 'WeatherImpact', 'trimf', [1.2 1.4 1.7], 'Name', 'ModerateDelay');
    fis = addMF(fis, 'WeatherImpact', 'trapmf', [1.5 2.0 2.5 2.5], 'Name', 'MajorDelay');
    
    % Define membership functions for Success Probability
    fis = addMF(fis, 'SuccessProbability', 'trapmf', [0 0 15 25], 'Name', 'VeryLow');
    fis = addMF(fis, 'SuccessProbability', 'trimf', [20 35 50], 'Name', 'Low');
    fis = addMF(fis, 'SuccessProbability', 'trimf', [45 60 75], 'Name', 'Medium');
    fis = addMF(fis, 'SuccessProbability', 'trimf', [70 85 95], 'Name', 'High');
    fis = addMF(fis, 'SuccessProbability', 'trapmf', [80 90 100 100], 'Name', 'VeryHigh');
    
    % Define comprehensive rules
    ruleList = [
        % Excellent routine + Excellent transport + Normal weather → Very High success
        3 3 1 5 1 1;
        
        % Excellent routine + Moderate transport + Normal weather → High success
        3 2 1 4 1 1;
        
        % Moderate routine + Excellent transport + Normal weather → High success
        2 3 1 4 1 1;
        
        % Moderate routine + Moderate transport + Normal weather → Medium success
        2 2 1 3 1 1;
        
        % Weather impact rules (downgrades success)
        3 3 2 4 1 1;  % Excellent + Excellent + Moderate delay → High (not Very High)
        3 3 3 3 1 1;  % Excellent + Excellent + Major delay → Medium (capped)
        3 2 2 3 1 1;  % Excellent + Moderate + Moderate delay → Medium
        3 2 3 2 1 1;  % Excellent + Moderate + Major delay → Low
        2 3 2 3 1 1;  % Moderate + Excellent + Moderate delay → Medium
        2 3 3 2 1 1;  % Moderate + Excellent + Major delay → Low
        2 2 2 2 1 1;  % Moderate + Moderate + Moderate delay → Low
        2 2 3 1 1 1;  % Moderate + Moderate + Major delay → Very Low
        
        % Poor efficiency rules
        1 3 1 3 1 1;  % Poor routine + Excellent transport + Normal weather → Medium
        3 1 1 3 1 1;  % Excellent routine + Poor transport + Normal weather → Medium
        1 2 1 2 1 1;  % Poor routine + Moderate transport + Normal weather → Low
        2 1 1 2 1 1;  % Moderate routine + Poor transport + Normal weather → Low
        1 1 1 1 1 1;  % Poor routine + Poor transport + Normal weather → Very Low
        
        % Poor efficiency with weather delays
        1 3 2 2 1 1;  % Poor routine + Excellent transport + Moderate delay → Low
        1 3 3 1 1 1;  % Poor routine + Excellent transport + Major delay → Very Low
        3 1 2 2 1 1;  % Excellent routine + Poor transport + Moderate delay → Low
        3 1 3 1 1 1;  % Excellent routine + Poor transport + Major delay → Very Low
        1 2 2 1 1 1;  % Poor routine + Moderate transport + Any delay → Very Low
        2 1 2 1 1 1;  % Moderate routine + Poor transport + Any delay → Very Low
        1 1 2 1 1 1;  % Poor routine + Poor transport + Any delay → Very Low
        1 1 3 1 1 1;  % Poor routine + Poor transport + Any delay → Very Low
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    success_prob = evalfis(fis, [routine_efficiency, transport_efficiency, weather_travel_multiplier]);
    
    % Apply special rules if additional context is provided
    if length(varargin) >= 4
        parentA_wake = varargin{1};
        parentB_wake = varargin{2};
        weather_num = varargin{3};
        run_duration = varargin{4};
        
        % Special rule 1: IF very early wake AND clear weather AND no/short run THEN very high
        % Very early wake: both parents wake before 6:00
        % Clear weather: weather_num == 1 or 2 (clear or cloudy)
        % No/short run: run_duration < 30 minutes
        if (parentA_wake <= 6.0 && parentB_wake <= 6.0 && weather_num <= 2 && run_duration < 30)
            % Boost to very high probability (minimum 90%)
            success_prob = max(success_prob, 90);
        end
        
        % Additional interpretation: IF very early wake AND clear weather (regardless of run) THEN boost
        % This captures the spirit that very early wake with good weather should lead to high success
        if (parentA_wake <= 6.0 && parentB_wake <= 6.0 && weather_num == 1)
            % Ensure at least 85% success
            success_prob = max(success_prob, 85);
        end
    end
    
    % Ensure output is within bounds
    success_prob = max(0, min(100, success_prob));
end