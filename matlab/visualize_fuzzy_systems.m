% VISUALIZE_FUZZY_SYSTEMS Visualize the membership functions of each fuzzy subsystem

clear; close all; clc;

%% Create temporary instances of each fuzzy system for visualization

% Run Decision System
fis_run = mamfis('Name', 'RunDecision');
fis_run = addInput(fis_run, [5.5 8.5], 'Name', 'ParentBWakeTime');
fis_run = addInput(fis_run, [1 5], 'Name', 'Weather');
fis_run = addInput(fis_run, [0 1], 'Name', 'DayType');
fis_run = addOutput(fis_run, [0 120], 'Name', 'RunDuration');

% Add membership functions
fis_run = addMF(fis_run, 'ParentBWakeTime', 'trapmf', [5.5 5.5 6.0 6.25], 'Name', 'VeryEarly');
fis_run = addMF(fis_run, 'ParentBWakeTime', 'trimf', [6.0 6.5 7.0], 'Name', 'Early');
fis_run = addMF(fis_run, 'ParentBWakeTime', 'trimf', [6.5 7.0 7.5], 'Name', 'Normal');
fis_run = addMF(fis_run, 'ParentBWakeTime', 'trapmf', [7.0 7.5 8.5 8.5], 'Name', 'Late');

fis_run = addMF(fis_run, 'Weather', 'trapmf', [1 1 2 2.5], 'Name', 'GoodRunning');
fis_run = addMF(fis_run, 'Weather', 'trimf', [2.5 3 3.5], 'Name', 'PoorRunning');
fis_run = addMF(fis_run, 'Weather', 'trapmf', [3.5 4 5 5], 'Name', 'BadRunning');

fis_run = addMF(fis_run, 'DayType', 'trimf', [-0.5 0 0.5], 'Name', 'Weekend');
fis_run = addMF(fis_run, 'DayType', 'trimf', [0.5 1 1.5], 'Name', 'Weekday');

fis_run = addMF(fis_run, 'RunDuration', 'trapmf', [0 0 5 10], 'Name', 'None');
fis_run = addMF(fis_run, 'RunDuration', 'trimf', [10 20 30], 'Name', 'Short');
fis_run = addMF(fis_run, 'RunDuration', 'trimf', [25 37.5 50], 'Name', 'Medium');
fis_run = addMF(fis_run, 'RunDuration', 'trimf', [45 67.5 90], 'Name', 'Long');
fis_run = addMF(fis_run, 'RunDuration', 'trapmf', [80 100 120 120], 'Name', 'VeryLong');

% Weather Travel Impact System
fis_weather = mamfis('Name', 'WeatherTravelImpact');
fis_weather = addInput(fis_weather, [1 5], 'Name', 'Weather');
fis_weather = addOutput(fis_weather, [1.0 2.5], 'Name', 'TravelMultiplier');

fis_weather = addMF(fis_weather, 'Weather', 'trapmf', [1 1 2 2.5], 'Name', 'Clear');
fis_weather = addMF(fis_weather, 'Weather', 'trimf', [2.5 3 3.5], 'Name', 'LightRain');
fis_weather = addMF(fis_weather, 'Weather', 'trimf', [3.5 4 4.5], 'Name', 'HeavyRain');
fis_weather = addMF(fis_weather, 'Weather', 'trapmf', [4.5 5 5 5], 'Name', 'Snow');

fis_weather = addMF(fis_weather, 'TravelMultiplier', 'trapmf', [1.0 1.0 1.1 1.3], 'Name', 'Normal');
fis_weather = addMF(fis_weather, 'TravelMultiplier', 'trimf', [1.2 1.4 1.7], 'Name', 'ModerateDelay');
fis_weather = addMF(fis_weather, 'TravelMultiplier', 'trapmf', [1.5 2.0 2.5 2.5], 'Name', 'MajorDelay');

%% Create visualization figures

% Figure 1: Run Decision System
figure('Position', [100, 100, 1200, 800], 'Name', 'Run Decision Fuzzy System');

subplot(2,3,1);
plotmf(fis_run, 'input', 1);
title('Parent B Wake Time MFs');
xlabel('Wake Time (hours)');

subplot(2,3,2);
plotmf(fis_run, 'input', 2);
title('Weather Condition MFs');
xlabel('Weather (1=clear to 5=snow)');

subplot(2,3,3);
plotmf(fis_run, 'input', 3);
title('Day Type MFs');
xlabel('Day Type (0=weekend, 1=weekday)');

subplot(2,3,4);
plotmf(fis_run, 'output', 1);
title('Run Duration MFs');
xlabel('Duration (minutes)');

% Add surface plots
subplot(2,3,5);
gensurf(fis_run, [1 2], 1);
title('Run Duration vs Wake Time & Weather');
xlabel('Parent B Wake Time');
ylabel('Weather');
zlabel('Run Duration');

subplot(2,3,6);
gensurf(fis_run, [1 3], 1);
title('Run Duration vs Wake Time & Day Type');
xlabel('Parent B Wake Time');
ylabel('Day Type');
zlabel('Run Duration');

% Figure 2: Weather Travel Impact System
figure('Position', [150, 150, 800, 600], 'Name', 'Weather Travel Impact System');

subplot(2,2,1);
plotmf(fis_weather, 'input', 1);
title('Weather Condition MFs');
xlabel('Weather (1=clear to 5=snow)');

subplot(2,2,2);
plotmf(fis_weather, 'output', 1);
title('Travel Multiplier MFs');
xlabel('Multiplier');

subplot(2,2,[3,4]);
weather_vals = 1:0.1:5;
travel_mult = zeros(size(weather_vals));
for i = 1:length(weather_vals)
    travel_mult(i) = evalfis(fis_weather, weather_vals(i));
end
plot(weather_vals, travel_mult, 'b-', 'LineWidth', 2);
xlabel('Weather Condition');
ylabel('Travel Time Multiplier');
title('Weather to Travel Multiplier Mapping');
grid on;
xticks([1 2 3 4 5]);
xticklabels({'Clear', 'Cloudy', 'Light Rain', 'Heavy Rain', 'Snow'});

% Figure 3: System Architecture Diagram
figure('Position', [200, 200, 1000, 800], 'Name', 'System Architecture');
axis off;

% Title
text(0.5, 0.95, 'Hierarchical Fuzzy Logic Model Architecture', ...
    'HorizontalAlignment', 'center', 'FontSize', 16, 'FontWeight', 'bold');

% Level 0: Inputs
text(0.1, 0.85, 'Level 0: Inputs', 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.80, '• Weather Condition', 'FontSize', 10);
text(0.1, 0.77, '• Day Type', 'FontSize', 10);
text(0.1, 0.74, '• Parent A Wake Time', 'FontSize', 10);
text(0.1, 0.71, '• Parent B Wake Time', 'FontSize', 10);

% Level 1
text(0.1, 0.65, 'Level 1: Primary Decisions', 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.60, '• Run Decision', 'FontSize', 10);
text(0.1, 0.57, '• Base Parent Availability', 'FontSize', 10);

% Level 2
text(0.1, 0.51, 'Level 2: Adjusted Assessment', 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.46, '• Final Parent Availability', 'FontSize', 10);
text(0.1, 0.43, '• Weather Travel Impact', 'FontSize', 10);

% Level 3
text(0.1, 0.37, 'Level 3: Routine Efficiency', 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.32, '• Breakfast Efficiency', 'FontSize', 10);
text(0.1, 0.29, '• Dressing Efficiency', 'FontSize', 10);
text(0.1, 0.26, '• Transportation Logistics', 'FontSize', 10);

% Level 4
text(0.1, 0.20, 'Level 4: Consolidation', 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.15, '• Morning Routine Efficiency', 'FontSize', 10);

% Level 5
text(0.1, 0.09, 'Level 5: Final Output', 'FontSize', 12, 'FontWeight', 'bold');
text(0.1, 0.04, '• School Arrival Probability', 'FontSize', 10);

% Flow diagram
text(0.6, 0.85, 'Data Flow:', 'FontSize', 12, 'FontWeight', 'bold');
text(0.6, 0.80, 'Weather → Run Decision → Final Availability', 'FontSize', 10);
text(0.6, 0.77, 'Weather → Weather Travel Impact → Final Probability', 'FontSize', 10);
text(0.6, 0.74, 'Wake Times → Base Availability → Final Availability', 'FontSize', 10);
text(0.6, 0.71, 'Final Availability → Routine Tasks → Final Probability', 'FontSize', 10);

fprintf('Fuzzy system visualizations complete.\n');