close all
clear all
clc

% Number of runs for timing
numRuns = 10;

% Preallocate arrays to store timing results
loadTimesStep1 = zeros(1, numRuns);
loadTimesStep2 = zeros(1, numRuns);
loadTimesStep3 = zeros(1, numRuns);

for runIdx = 1:numRuns
    % Start total timer
    totalTimeStart = tic;
    
    %% Step 1: Loading 'SetUpC5_2v_ChirpPCI_2024April29.mat'
    loadTimeStep1Start = tic;
    Zzz = load('SetUpC5_2v_ChirpPCI_2024April29.mat');
    loadTimesStep1(runIdx) = toc(loadTimeStep1Start);
    
    %% Step 2: Loading 'SH_Chirp_2024March22.mat'
    loadTimeStep2Start = tic;
    tw2 = load('SH_Chirp_2024March22.mat');  % loading synthetic waveform
    loadTimesStep2(runIdx) = toc(loadTimeStep2Start);
    
    %% Step 3: Loading 'UFData_Agarose_dataset_1.mat'
    loadTimeStep3Start = tic;
    y = load('UFData_Agarose_dataset_1.mat');
    loadTimesStep3(runIdx) = toc(loadTimeStep3Start);
    
    % Store total time (combine load steps)
    totalTimes(runIdx) = toc(totalTimeStart);
end

% Plot all timing results in a single figure (Figure 103)
figure(103);
hold on;
runs = 1:numRuns;

% Define color order (5 colors)
colors = lines(5);

% Plot each loading step timing
plot(runs, loadTimesStep1, '-o', 'DisplayName', 'Load Step 1 (SetUpC5_2v)', 'LineWidth', 2, 'Color', colors(1,:), 'LineStyle', '--');
plot(runs, loadTimesStep2, '-o', 'DisplayName', 'Load Step 2 (SH_Chirp)', 'LineWidth', 2, 'Color', colors(2,:), 'LineStyle', '--');
plot(runs, loadTimesStep3, '-o', 'DisplayName', 'Load Step 3 (UFData_Agarose)', 'LineWidth', 2, 'Color', colors(3,:), 'LineStyle', '--');

% Formatting the plot
xlabel('Run Number');
ylabel('Time (seconds)');
title('Loading Time for Each Step');
legend('Location', 'northwest');
ylim([0 0.2]);
grid on;
hold off;
