close all
clear all
clc

% Number of runs
numRuns = 10;

% Initialize arrays to store timing results for each segment across all runs
loadTimes = zeros(1, numRuns);
samplingTimes = zeros(1, numRuns);
imageProcessingTimes = zeros(1, numRuns);
timeCalcTimes = zeros(1, numRuns);
matchedFilterTimes = zeros(1, numRuns);
bubbleCloudTimes = zeros(1, numRuns);
plotTimes = zeros(1, numRuns);
totalTimes = zeros(1, numRuns);

for runIdx = 1:numRuns
    %% Start total timer
    totalTimeStart = tic;

    % Sub-timer for loading data
    loadTimeStart = tic;
    %% loading relevant data files
    Zzz = load(fullfile('Setup Data', 'SetUpC5_2v_ChirpPCI_2024April29.mat'));
    Trans = Zzz.Trans;
    P = Zzz.P;
    Receive3 = Zzz.Receive3;

    tw1 = Zzz.TW(1).Waveform;
    tw2 = load(fullfile('Setup Data', 'SH_Chirp_2024March22.mat')); % loading synthetic waveform used for transmitting fundamental
    tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure 

    filename = fullfile('Fall Data', 'UFData_Agarose_dataset_1.mat');
    y = load(filename);
    loadTimes(runIdx) = toc(loadTimeStart);

    % Sub-timer for setting sampling frequency and template adjustment
    samplingTimeStart = tic;
    % sampling frequency of acquired RF data
    Fs = 250/18 * 1e6;
    tFs = 250e6;

    % adjusting sampling frequency of chirp templates similar to the RF data sampling frequency
    % ------- fundamental chirp template --------
    w1 = interp1((1:length(tw1))/tFs, tw1, 1/Fs:1/Fs:length(tw1)/tFs);
    w1 = [zeros(1, length(w1)) w1];
    w1 = w1/max(abs(w1));
    % ------- subharmonic chirp template --------
    w2 = interp1((1:length(tw2))/tFs, tw2, 1/Fs:1/Fs:length(tw2)/tFs);
    w2 = [zeros(1, length(w2)) w2];
    w2 = w2/max(abs(w2));
    samplingTimes(runIdx) = toc(samplingTimeStart);

    % Sub-timer for processing acquired RF image data
    imageProcessingTimeStart = tic;
    % loading single acquired RF image
    twfm = y.RData(:, 64);
    numZeros = find(flipud(twfm) ~= 0, 1, 'first') - 1;
    ptsd = int16((length(twfm) - numZeros) / P.numAcqs);
    frame_no = 1;
    x = y.RData((frame_no-1) * ptsd + (1:ptsd), :);
    imageProcessingTimes(runIdx) = toc(imageProcessingTimeStart);

    % Sub-timer for absolute time calculation
    timeCalcTimeStart = tic;
    %% Determine absolute time
    time = (1:double(ptsd)) * (1/Fs) + 2 * Receive3(64).startDepth / (Trans.frequency * 1e6);
    timeCalcTimes(runIdx) = toc(timeCalcTimeStart);

    % Sub-timer for matched filter application
    matchedFilterTimeStart = tic;
    %% Apply matched filter to waveforms
    fwfm = zeros(ptsd, 10);
    for idx = 1:10
        fwfm(:, idx) = conv2(y.RData((idx-1) * ptsd + (1:ptsd), 64)', fliplr(w2), 'same')';
    end
    matchedFilterTimes(runIdx) = toc(matchedFilterTimeStart);

    % Sub-timer for bubble cloud analysis
    bubbleCloudTimeStart = tic;
    %% Determine approximate window to assess bubble cloud
    focus = 50;
    width = 5;
    tdx = find(1e6 * time > 2 * (focus - width / 2) / 1.54 & 1e6 * time < 2 * (focus + width / 2) / 1.54);

    % Calculate integrated signal within tdx for each frame
    intGS = zeros(1, 10);
    for idx = 1:10
        temp = fwfm(:, idx).^2;
        intGS(idx) = sum(temp(tdx));
    end
    bubbleCloudTimes(runIdx) = toc(bubbleCloudTimeStart);

    % Sub-timer for plotting
    plotTimeStart = tic;
    %% Now plot data
    figure(101)
    subplot(3, 1, 1)
    plot(time * 1e6, fwfm(:, 1))
    title('0 ms')

    subplot(3, 1, 2)
    plot(time * 1e6, fwfm(:, 5))
    title('5 ms')

    subplot(3, 1, 3)
    plot(time * 1e6, fwfm(:, 10))
    title('10 ms')
    xlabel('Time (\mus)')

    figure(102)
    plot(1:10, intGS / intGS(1), '.', 'MarkerSize', 20)
    xlabel('Time (ms)')
    ylabel('Integrated Signal (AU)')
    plotTimes(runIdx) = toc(plotTimeStart);

    % Sub-timer for fitting
    fitTimeStart = tic;
    % Power law fit
    [efit, gof] = fit((1:10)', intGS' / intGS(1), 'power1');
    hold on
    plot(1:10, feval(efit, 1:10), '--r')
    fitTimes(runIdx) = toc(fitTimeStart);


    % Total time
    totalTimes(runIdx) = toc(totalTimeStart);
end

%% Display Timing Results for each run
fprintf('Load Times (seconds):\n');
fprintf('%.4f ', loadTimes);
fprintf('\n');

fprintf('Sampling Frequency Adjustment Times (seconds):\n');
fprintf('%.4f ', samplingTimes);
fprintf('\n');

fprintf('Image Processing Times (seconds):\n');
fprintf('%.4f ', imageProcessingTimes);
fprintf('\n');

fprintf('Absolute Time Calculation Times (seconds):\n');
fprintf('%.4f ', timeCalcTimes);
fprintf('\n');

fprintf('Matched Filter Application Times (seconds):\n');
fprintf('%.4f ', matchedFilterTimes);
fprintf('\n');

fprintf('Bubble Cloud Analysis Times (seconds):\n');
fprintf('%.4f ', bubbleCloudTimes);
fprintf('\n');

fprintf('Plotting Times (seconds):\n');
fprintf('%.4f ', plotTimes);
fprintf('\n');

fprintf('Power Law Fit Times (seconds):\n');
fprintf('%.4f ', fitTimes);
fprintf('\n');

fprintf('Total Times (excluding plotting) (seconds):\n');
fprintf('%.4f ', totalTimes - plotTimes);
fprintf('\n');

fprintf('Total Times (seconds):\n');
fprintf('%.4f ', totalTimes);
fprintf('\n');

% Create figure 103
figure(103);
hold on;

% Run numbers
runs = 1:10;

% Define color order (5 colors)
colors = lines(5);

% Plot each timing category
hold on;
plot(runs, loadTimes, '-o', 'DisplayName', 'Load Time', 'LineWidth', 2, 'Color', colors(1,:), 'LineStyle', '--');
%plot(runs, samplingTimes, '-o', 'DisplayName', 'Sampling Frequency Adjustment Time', 'LineWidth', 2, 'Color', colors(2,:), 'LineStyle', '--');
%plot(runs, imageProcessingTimes, '-o', 'DisplayName', 'Image Processing Time', 'LineWidth', 2, 'Color', colors(3,:), 'LineStyle', '--');
%plot(runs, timeCalcTimes, '-o', 'DisplayName', 'Absolute Time Calculation Time', 'LineWidth', 2, 'Color', colors(4,:), 'LineStyle', '--');
plot(runs, matchedFilterTimes, '-o', 'DisplayName', 'Matched Filter Application Time', 'LineWidth', 2, 'Color', colors(5,:), 'LineStyle', '--');

%plot(runs, bubbleCloudTimes, '-o', 'DisplayName', 'Bubble Cloud Analysis Time', 'LineWidth', 2, 'Color', colors(1,:), 'LineStyle', '-');
%plot(runs, plotTimes, '-o', 'DisplayName', 'Plotting Time', 'LineWidth', 2, 'Color', colors(2,:), 'LineStyle', '-');
plot(runs, fitTimes, '-o', 'DisplayName', 'Power Law Fit Time', 'LineWidth', 2, 'Color', colors(3,:), 'LineStyle', '--');
%plot(runs, totalTimes - plotTimes - fitTimes, '-o', 'DisplayName', 'Total Time (excluding plotting and fitting)', 'LineWidth', 2, 'Color', colors(4,:), 'LineStyle', '-');
plot(runs, totalTimes, '-o', 'DisplayName', 'Total Time', 'LineWidth', 2, 'Color', colors(2,:), 'LineStyle', '-');

% Formatting the plot
xlabel('Run Number');
ylabel('Time (seconds)');
title('Timing Results for Each Run');
legend('Location', 'northwest');
ylim([0.0001,10]);
set(gca, 'YScale', 'log'); % Set y-axis to log scale
grid on;
hold off;