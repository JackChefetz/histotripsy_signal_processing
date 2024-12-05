close all
clear all
clc

% Number of runs for timing
numRuns = 10;

% Preallocate arrays to store timing results
loadTimes = zeros(1, numRuns);
samplingTimes = zeros(1, numRuns);
imageProcessingTimes = zeros(1, numRuns);
timeCalcTimes = zeros(1, numRuns);
matchedFilterTimes = zeros(1, numRuns);
bubbleCloudTimes = zeros(1, numRuns);
plotTimes = zeros(1, numRuns);
fitTimes = zeros(1, numRuns);
totalTimes = zeros(1, numRuns);

for runIdx = 1:numRuns
    % Start total timer
    totalTimeStart = tic;
    
    %% Loading relevant data files
    loadTimeStart = tic;
    Zzz = load('SetUpC5_2v_ChirpPCI_2024April29.mat');
    Trans = Zzz.Trans;
    P = Zzz.P;
    Receive3 = Zzz.Receive3;
    tw1 = Zzz.TW(1).Waveform;
    tw2 = load('SH_Chirp_2024March22.mat'); % loading synthetic waveform
    tw2 = tw2.TW.Waveform;
    filename = ['UFData_Agarose_dataset_1', '.mat'];
    y = load(filename);
    loadTimes(runIdx) = toc(loadTimeStart);
    
    %% Sampling frequency and template adjustment
    samplingTimeStart = tic;
    Fs = 250/18 * 1e6;
    tFs = 250e6;
    w1 = interp1((1:length(tw1))/tFs, tw1, 1/Fs:1/Fs:length(tw1)/tFs);
    w1 = [zeros(1, length(w1)) w1];
    w1 = w1/max(abs(w1));
    w2 = interp1((1:length(tw2))/tFs, tw2, 1/Fs:1/Fs:length(tw2)/tFs);
    w2 = [zeros(1, length(w2)) w2];
    w2 = w2/max(abs(w2));
    samplingTimes(runIdx) = toc(samplingTimeStart);
    
    %% Image processing
    imageProcessingTimeStart = tic;
    twfm = y.RData(:, 64);
    numZeros = find(flipud(twfm) ~= 0, 1, 'first')-1;
    ptsd = int16((length(twfm) - numZeros) / P.numAcqs);
    frame_no = 1;
    x = y.RData((frame_no-1)*ptsd+(1:ptsd), :);
    imageProcessingTimes(runIdx) = toc(imageProcessingTimeStart);
    
    %% Absolute time calculation
    timeCalcTimeStart = tic;
    time = (1:double(ptsd)) * (1/Fs) + 2 * Receive3(64).startDepth / (Trans.frequency * 1e6);
    timeCalcTimes(runIdx) = toc(timeCalcTimeStart);
    
    %% Matched filter application
    matchedFilterTimeStart = tic;
    fwfm = zeros(ptsd, 10);
    for idx = 1:10
        fwfm(:, idx) = conv2(y.RData((idx-1)*ptsd+(1:ptsd), 64)', fliplr(w2), 'same')';
    end
    matchedFilterTimes(runIdx) = toc(matchedFilterTimeStart);
    
    %% Bubble cloud analysis
    bubbleCloudTimeStart = tic;
    focus = 50; %[mm] focal distance
    width = 5; %[mm] FWHM of focal width
    tdx = find(1e6*time > 2*(focus - width/2)/1.54 & 1e6*time < 2*(focus + width/2)/1.54);
    intGS = zeros(1, 10);
    for idx = 1:10
        temp = fwfm(:, idx).^2;
        intGS(idx) = sum(temp(tdx));
    end
    bubbleCloudTimes(runIdx) = toc(bubbleCloudTimeStart);
    
    %% Plotting data
    plotTimeStart = tic;
    if runIdx == 1
        figure(101);
        subplot(3, 1, 1);
        plot(time * 1e6, fwfm(:, 1));
        title('0 ms');
        subplot(3, 1, 2);
        plot(time * 1e6, fwfm(:, 5));
        title('5 ms');
        subplot(3, 1, 3);
        plot(time * 1e6, fwfm(:, 10));
        title('10 ms');
        xlabel('Time (\mus)');
        figure(102);
        plot(1:10, intGS/intGS(1), '.', 'MarkerSize', 20);
        xlabel('Time (ms)');
        ylabel('Integrated Signal (AU)');
    end
    plotTimes(runIdx) = toc(plotTimeStart);
    
    %% Power law fit timing
    fitTimeStart = tic;
    params = speedy_power_fit((1:10)', intGS'/intGS(1));
    fitTimes(runIdx) = toc(fitTimeStart);
    
    % Store total time
    totalTimes(runIdx) = toc(totalTimeStart);
end

% Plot all timing results in a single figure (Figure 103)
figure(103);
hold on;
runs = 1:numRuns;
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
