% TEST_SCHOOL_COMMUTE_MODEL Test script for the hierarchical fuzzy logic model

clear; close all; clc;

%% Test Cases

% Test Case 1: Ideal conditions
fprintf('Test Case 1: Ideal Conditions\n');
fprintf('Weather: clear, Day: weekday, Parent A: 6:00, Parent B: 6:00\n');
[prob1, inter1] = school_commute_fuzzy_model('clear', 'weekday', 6.0, 6.0);
fprintf('Success Probability: %.1f%%\n', prob1);
fprintf('Intermediate outputs:\n');
disp(inter1);
fprintf('\n');

% Test Case 2: Bad weather
fprintf('Test Case 2: Bad Weather (Heavy Rain)\n');
fprintf('Weather: heavy_rain, Day: weekday, Parent A: 6:30, Parent B: 6:30\n');
[prob2, inter2] = school_commute_fuzzy_model('heavy_rain', 'weekday', 6.5, 6.5);
fprintf('Success Probability: %.1f%%\n', prob2);
fprintf('Run Duration: %.1f minutes\n', inter2.run_duration);
fprintf('Weather Travel Multiplier: %.2f\n', inter2.weather_travel_multiplier);
fprintf('\n');

% Test Case 3: Late wake times
fprintf('Test Case 3: Late Wake Times\n');
fprintf('Weather: clear, Day: weekday, Parent A: 7:30, Parent B: 7:30\n');
[prob3, inter3] = school_commute_fuzzy_model('clear', 'weekday', 7.5, 7.5);
fprintf('Success Probability: %.1f%%\n', prob3);
fprintf('Base Availability: %.1f\n', inter3.base_availability);
fprintf('Final Availability: %.1f\n', inter3.final_availability);
fprintf('\n');

% Test Case 4: Weekend with early Parent B (long run)
fprintf('Test Case 4: Weekend Early Wake (Long Run)\n');
fprintf('Weather: clear, Day: weekend, Parent A: 6:30, Parent B: 5:45\n');
[prob4, inter4] = school_commute_fuzzy_model('clear', 'weekend', 6.5, 5.75);
fprintf('Success Probability: %.1f%%\n', prob4);
fprintf('Run Duration: %.1f minutes\n', inter4.run_duration);
fprintf('Base Availability: %.1f\n', inter4.base_availability);
fprintf('Final Availability: %.1f\n', inter4.final_availability);
fprintf('\n');

% Test Case 5: Snow conditions
fprintf('Test Case 5: Snow Conditions\n');
fprintf('Weather: snow, Day: weekday, Parent A: 6:00, Parent B: 6:00\n');
[prob5, inter5] = school_commute_fuzzy_model('snow', 'weekday', 6.0, 6.0);
fprintf('Success Probability: %.1f%%\n', prob5);
fprintf('Weather Travel Multiplier: %.2f\n', inter5.weather_travel_multiplier);
fprintf('\n');

% Test Case 6: Very early wake with no run (special rule test)
fprintf('Test Case 6: Very Early Wake, Clear Weather, No Run (Special Rule)\n');
fprintf('Weather: clear, Day: weekday, Parent A: 5:45, Parent B: 5:45\n');
[prob6, inter6] = school_commute_fuzzy_model('clear', 'weekday', 5.75, 5.75);
fprintf('Success Probability: %.1f%%\n', prob6);
fprintf('Run Duration: %.1f minutes\n', inter6.run_duration);
fprintf('Base Availability: %.1f\n', inter6.base_availability);
fprintf('Final Availability: %.1f\n', inter6.final_availability);
fprintf('Note: Special rule activates if run < 10 min. Current run: %.1f min\n', inter6.run_duration);
fprintf('\n');

% Test Case 7: Late Parent B wake (should result in no run)
fprintf('Test Case 7: Clear Weather, Late Parent B (No Run Scenario)\n');
fprintf('Weather: clear, Day: weekday, Parent A: 5:45, Parent B: 7:30\n');
[prob7, inter7] = school_commute_fuzzy_model('clear', 'weekday', 5.75, 7.5);
fprintf('Success Probability: %.1f%%\n', prob7);
fprintf('Run Duration: %.1f minutes\n', inter7.run_duration);
fprintf('Note: Special rule activates if both wake ≤ 6:00. Parent B woke at 7:30\n');
fprintf('\n');

% Test Case 8: Early wake but bad weather (no run due to weather)
fprintf('Test Case 8: Early Wake, Heavy Rain (No Run Due to Weather)\n');
fprintf('Weather: heavy_rain, Day: weekday, Parent A: 5:45, Parent B: 5:45\n');
[prob8, inter8] = school_commute_fuzzy_model('heavy_rain', 'weekday', 5.75, 5.75);
fprintf('Success Probability: %.1f%%\n', prob8);
fprintf('Run Duration: %.1f minutes\n', inter8.run_duration);
fprintf('Weather Impact: %.2f\n', inter8.weather_travel_multiplier);
fprintf('Note: Heavy rain prevents running, but special rule requires clear weather\n');
fprintf('\n');

%% Sensitivity Analysis Plots

% Create arrays for sensitivity analysis
wake_times = 5.5:0.25:8.5;
weather_conditions = {'clear', 'cloudy', 'light_rain', 'heavy_rain', 'snow'};

% Plot 1: Parent A wake time sensitivity
figure('Position', [100, 100, 800, 600]);
subplot(2,2,1);
probs_parentA = zeros(length(wake_times), 1);
for i = 1:length(wake_times)
    [probs_parentA(i), ~] = school_commute_fuzzy_model('clear', 'weekday', wake_times(i), 6.5);
end
plot(wake_times, probs_parentA, 'b-', 'LineWidth', 2);
xlabel('Parent A Wake Time (hours)');
ylabel('Success Probability (%)');
title('Sensitivity to Parent A Wake Time');
grid on;

% Plot 2: Parent B wake time sensitivity
subplot(2,2,2);
probs_parentB = zeros(length(wake_times), 1);
for i = 1:length(wake_times)
    [probs_parentB(i), ~] = school_commute_fuzzy_model('clear', 'weekday', 6.5, wake_times(i));
end
plot(wake_times, probs_parentB, 'r-', 'LineWidth', 2);
xlabel('Parent B Wake Time (hours)');
ylabel('Success Probability (%)');
title('Sensitivity to Parent B Wake Time');
grid on;

% Plot 3: Weather impact
subplot(2,2,3);
probs_weather = zeros(length(weather_conditions), 1);
for i = 1:length(weather_conditions)
    [probs_weather(i), ~] = school_commute_fuzzy_model(weather_conditions{i}, 'weekday', 6.5, 6.5);
end
bar(categorical(weather_conditions), probs_weather);
ylabel('Success Probability (%)');
title('Weather Impact on Success');
xtickangle(45);

% Plot 4: Combined heat map
subplot(2,2,4);
[X, Y] = meshgrid(wake_times, wake_times);
Z = zeros(size(X));
for i = 1:length(wake_times)
    for j = 1:length(wake_times)
        [Z(i,j), ~] = school_commute_fuzzy_model('clear', 'weekday', wake_times(j), wake_times(i));
    end
end
contourf(X, Y, Z, 20);
colorbar;
xlabel('Parent A Wake Time (hours)');
ylabel('Parent B Wake Time (hours)');
title('Success Probability Heat Map');

%% Run Duration Analysis

figure('Position', [950, 100, 800, 600]);

% Plot run duration vs Parent B wake time for different weather
subplot(2,2,1);
weather_for_run = {'clear', 'light_rain', 'heavy_rain'};
colors = {'b-', 'g-', 'r-'};
for w = 1:length(weather_for_run)
    run_durations = zeros(length(wake_times), 1);
    for i = 1:length(wake_times)
        [~, inter] = school_commute_fuzzy_model(weather_for_run{w}, 'weekday', 6.5, wake_times(i));
        run_durations(i) = inter.run_duration;
    end
    plot(wake_times, run_durations, colors{w}, 'LineWidth', 2);
    hold on;
end
xlabel('Parent B Wake Time (hours)');
ylabel('Run Duration (minutes)');
title('Run Duration by Wake Time and Weather');
legend(weather_for_run, 'Location', 'northwest');
grid on;

% Plot availability cascade
subplot(2,2,2);
base_avail = zeros(length(wake_times), 1);
final_avail = zeros(length(wake_times), 1);
for i = 1:length(wake_times)
    [~, inter] = school_commute_fuzzy_model('clear', 'weekday', 6.5, wake_times(i));
    base_avail(i) = inter.base_availability;
    final_avail(i) = inter.final_availability;
end
plot(wake_times, base_avail, 'b-', 'LineWidth', 2);
hold on;
plot(wake_times, final_avail, 'r--', 'LineWidth', 2);
xlabel('Parent B Wake Time (hours)');
ylabel('Availability Score (0-10)');
title('Base vs Final Availability');
legend({'Base Availability', 'Final Availability'}, 'Location', 'southwest');
grid on;

% Plot weather travel impact
subplot(2,2,3);
weather_multipliers = zeros(length(weather_conditions), 1);
for i = 1:length(weather_conditions)
    [~, inter] = school_commute_fuzzy_model(weather_conditions{i}, 'weekday', 6.5, 6.5);
    weather_multipliers(i) = inter.weather_travel_multiplier;
end
bar(categorical(weather_conditions), weather_multipliers);
ylabel('Travel Time Multiplier');
title('Weather Impact on Travel Time');
xtickangle(45);
ylim([0.9, 2.6]);

% Plot routine efficiency components
subplot(2,2,4);
availability_levels = 0:1:10;
breakfast_times = zeros(length(availability_levels), 1);
dressing_times = zeros(length(availability_levels), 1);
for i = 1:length(availability_levels)
    breakfast_times(i) = compute_breakfast_efficiency(availability_levels(i));
    dressing_times(i) = compute_dressing_efficiency(availability_levels(i));
end
plot(availability_levels, breakfast_times, 'b-', 'LineWidth', 2);
hold on;
plot(availability_levels, dressing_times, 'r-', 'LineWidth', 2);
xlabel('Parent Availability Score');
ylabel('Time (minutes)');
title('Routine Task Times vs Availability');
legend({'Breakfast Time', 'Dressing Time'}, 'Location', 'northeast');
grid on;

fprintf('\nVisualization complete. Check the generated figures.\n');