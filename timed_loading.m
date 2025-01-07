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
    Zzz = load(fullfile('Setup Data', 'SetUpC5_2v_ChirpPCI_2024April29.mat'));
    Trans = Zzz.Trans;
    P = Zzz.P;
    Receive3 = Zzz.Receive3;
    tw1 = Zzz.TW(1).Waveform
    loadTimesStep1(runIdx) = toc(loadTimeStep1Start);
    
    %% Step 2: Loading 'SH_Chirp_2024March22.mat'
    loadTimeStep2Start = tic;
    tw2 = load(fullfile('Setup Data', 'SH_Chirp_2024March22.mat')); % loading synthetic waveform
    tw2 = tw2.TW.Waveform;
    loadTimesStep2(runIdx) = toc(loadTimeStep2Start);
    
    %% Step 3: Loading 'UFData_Agarose_dataset_1.mat'
    loadTimeStep3Start = tic;
    filename = fullfile('Fall Data', 'UFData_Agarose_dataset_1.mat');
    y = load(filename);
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
plot(runs, loadTimesStep1, '-o', 'DisplayName', 'Setup File', 'LineWidth', 2, 'Color', colors(1,:));
plot(runs, loadTimesStep2, '-o', 'DisplayName', 'Synthetic Waveform', 'LineWidth', 2, 'Color', colors(2,:));
plot(runs, loadTimesStep3, '-o', 'DisplayName', 'Live Data', 'LineWidth', 2, 'Color', colors(3,:));

% Formatting the plot
xlabel('Run Number');
ylabel('Time (seconds)');
title('Loading Time for Each Step');
legend('Location', 'northeast');
ylim([0.0001,1]);
set(gca, 'YScale', 'log'); % Set y-axis to log scale
grid on;
hold off;
