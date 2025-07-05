% TEST_SPECIAL_RULES Test the special rules specifically

clear; close all; clc;

fprintf('Testing Special Rules in School Commute Model\n');
fprintf('=============================================\n\n');

% Test Case 1: Very early wake with clear weather (should trigger special rule)
fprintf('Test Case 1: Very Early Wake (5:45), Clear Weather\n');
[prob1, inter1] = school_commute_fuzzy_model('clear', 'weekday', 5.75, 5.75);
fprintf('Success Probability: %.1f%%\n', prob1);
fprintf('Run Duration: %.1f minutes\n', inter1.run_duration);
fprintf('Expected: Should get at least 85%% due to special rule\n\n');

% Test Case 2: Early wake but not very early (6:15) - should not trigger
fprintf('Test Case 2: Early Wake (6:15), Clear Weather\n');
[prob2, inter2] = school_commute_fuzzy_model('clear', 'weekday', 6.25, 6.25);
fprintf('Success Probability: %.1f%%\n', prob2);
fprintf('Run Duration: %.1f minutes\n', inter2.run_duration);
fprintf('Expected: Normal processing, no special rule\n\n');

% Test Case 3: Very early wake but bad weather - should not trigger
fprintf('Test Case 3: Very Early Wake (5:45), Heavy Rain\n');
[prob3, inter3] = school_commute_fuzzy_model('heavy_rain', 'weekday', 5.75, 5.75);
fprintf('Success Probability: %.1f%%\n', prob3);
fprintf('Run Duration: %.1f minutes\n', inter3.run_duration);
fprintf('Expected: No special rule due to bad weather\n\n');

% Test Case 4: One parent very early, one not - should not trigger
fprintf('Test Case 4: Mixed Wake Times (5:45 & 6:30), Clear Weather\n');
[prob4, inter4] = school_commute_fuzzy_model('clear', 'weekday', 5.75, 6.5);
fprintf('Success Probability: %.1f%%\n', prob4);
fprintf('Run Duration: %.1f minutes\n', inter4.run_duration);
fprintf('Expected: No special rule (Parent B not very early)\n\n');

% Test Case 5: Very early wake with cloudy weather (should still trigger)
fprintf('Test Case 5: Very Early Wake (5:45), Cloudy Weather\n');
[prob5, inter5] = school_commute_fuzzy_model('cloudy', 'weekday', 5.75, 5.75);
fprintf('Success Probability: %.1f%%\n', prob5);
fprintf('Run Duration: %.1f minutes\n', inter5.run_duration);
fprintf('Expected: Should trigger special rule for good weather\n\n');

% Direct test of the probability function with controlled inputs
fprintf('Direct Function Test:\n');
fprintf('Testing with excellent routine, excellent transport, normal weather\n');
% These should trigger the normal "very high" rule
routine_eff = 9;  % Excellent
transport_eff = 9;  % Excellent  
weather_mult = 1.0;  % Normal weather
parentA = 5.75;  % Very early
parentB = 5.75;  % Very early
weather_num = 1;  % Clear
run_dur = 20;  % Short run

prob_direct = compute_school_arrival_probability(routine_eff, transport_eff, weather_mult, ...
    parentA, parentB, weather_num, run_dur);
fprintf('Direct call result: %.1f%%\n', prob_direct);
fprintf('Expected: Should be very high (90%+) due to both excellent conditions and special rule\n');

fprintf('\nTest complete.\n');