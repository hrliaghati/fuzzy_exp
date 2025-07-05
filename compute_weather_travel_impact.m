function travel_multiplier = compute_weather_travel_impact(weather_num)
    % COMPUTE_WEATHER_TRAVEL_IMPACT Model how weather affects actual travel time to school
    %
    % Input:
    %   weather_num - numeric: 1=clear, 2=cloudy, 3=light_rain, 4=heavy_rain, 5=snow
    %
    % Output:
    %   travel_multiplier - numeric: travel time multiplier (1.0-2.5)
    
    % Create fuzzy inference system
    fis = mamfis('Name', 'WeatherTravelImpact');
    
    % Add input variable
    fis = addInput(fis, [1 5], 'Name', 'Weather');
    
    % Add output variable
    fis = addOutput(fis, [1.0 2.5], 'Name', 'TravelMultiplier');
    
    % Define membership functions for Weather
    fis = addMF(fis, 'Weather', 'trapmf', [1 1 2 2.5], 'Name', 'Clear');
    fis = addMF(fis, 'Weather', 'trimf', [2.5 3 3.5], 'Name', 'LightRain');
    fis = addMF(fis, 'Weather', 'trimf', [3.5 4 4.5], 'Name', 'HeavyRain');
    fis = addMF(fis, 'Weather', 'trapmf', [4.5 5 5 5], 'Name', 'Snow');
    
    % Define membership functions for Travel Multiplier
    fis = addMF(fis, 'TravelMultiplier', 'trapmf', [1.0 1.0 1.1 1.3], 'Name', 'Normal');
    fis = addMF(fis, 'TravelMultiplier', 'trimf', [1.2 1.4 1.7], 'Name', 'ModerateDelay');
    fis = addMF(fis, 'TravelMultiplier', 'trapmf', [1.5 2.0 2.5 2.5], 'Name', 'MajorDelay');
    
    % Define rules mapping weather to travel impact
    ruleList = [
        1 1 1 1;  % IF Clear THEN Normal
        2 2 1 1;  % IF LightRain THEN ModerateDelay
        3 2 0.5 1;  % IF HeavyRain THEN ModerateDelay (partial)
        3 3 0.5 1;  % IF HeavyRain THEN MajorDelay (partial)
        4 3 1 1;  % IF Snow THEN MajorDelay
    ];
    
    fis = addRule(fis, ruleList);
    
    % Evaluate the fuzzy system
    travel_multiplier = evalfis(fis, weather_num);
    
    % Ensure output is within bounds
    travel_multiplier = max(1.0, min(2.5, travel_multiplier));
end