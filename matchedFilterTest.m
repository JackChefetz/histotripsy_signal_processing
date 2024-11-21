close all;
clear all;
clc;

% Number of runs
numRuns = 20;

%% Loading relevant data files
Zzz = load('SetUpC5_2v_ChirpPCI_2024April29.mat');
Trans = Zzz.Trans;
P = Zzz.P;
Receive3 = Zzz.Receive3;
tw1 = Zzz.TW(1).Waveform;

tw2 = load('SH_Chirp_2024March22.mat');
tw2 = tw2.TW.Waveform;
filename = ['UFData_Agarose_dataset_1', '.mat'];
y = load(filename);

% Sampling frequency of acquired RF data
Fs = 250/18 * 1e6;
tFs = 250e6;

% Adjusting sampling frequency of chirp templates similar to the RF data sampling frequency
% ------- fundamental chirp template --------
w1 = interp1((1:length(tw1))/tFs, tw1, 1/Fs:1/Fs:length(tw1)/tFs);
w1 = [zeros(1, length(w1)) w1];
w1 = w1 / max(abs(w1));
% ------- subharmonic chirp template --------
w2 = interp1((1:length(tw2))/tFs, tw2, 1/Fs:1/Fs:length(tw2)/tFs);
w2 = [zeros(1, length(w2)) w2];
w2 = w2 / max(abs(w2));

% Loading single acquired RF image
twfm = y.RData(:, 64);
numZeros = find(flipud(twfm) ~= 0, 1, 'first') - 1;
ptsd = int16((length(twfm) - numZeros) / P.numAcqs);
frame_no = 1;
x = y.RData((frame_no-1) * ptsd + (1:ptsd), :);

% Initialize arrays to store timing results for each run
matchedFilterTimesMatlab = zeros(1, numRuns);
matchedFilterTimesCpp = zeros(1, numRuns);

% Detailed timing checkpoints
dataLoadingTimes = zeros(1, numRuns);
convTimes = zeros(1, numRuns);
loopTimes = zeros(1, numRuns);

% Pre-allocate memory for results
fwfmMatlab = zeros(ptsd, 10);
fwfmCpp = zeros(ptsd, 10);

% Pre-compute the flipped filter to avoid redundant computations
flipped_w2 = fliplr(w2);

% Perform initial setup outside the timing loop
conv(y.RData(1:ptsd, 64)', flipped_w2, 'same'); % MATLAB initialization
% Note: Ensure the C++ MEX function is correctly compiled before running this script
temp = matchedFilterCpp(y.RData(1:ptsd, 64)', flipped_w2); % C++ initialization

for runIdx = 1:numRuns
    % Timing the data loading
    dataLoadingTimeStart = tic;
    yDataSubset = y.RData((runIdx-1) * ptsd + (1:ptsd), 64)';
    dataLoadingTimes(runIdx) = toc(dataLoadingTimeStart);
    
    % Timing the convolution loop using MATLAB's conv function
    loopTimeStart = tic;
    for idx = 1:10
        convTimeStart = tic;
        fwfmMatlab(:, idx) = conv(y.RData((idx-1) * ptsd + (1:ptsd), 64)', flipped_w2, 'same');
        convTimes(runIdx) = convTimes(runIdx) + toc(convTimeStart);
    end
    loopTimes(runIdx) = toc(loopTimeStart);
    
    % Total time for the entire MATLAB matched filter application
    matchedFilterTimesMatlab(runIdx) = dataLoadingTimes(runIdx) + loopTimes(runIdx);
end

% Sub-timer for matched filter application using the C++ MEX function
for runIdx = 1:numRuns
    matchedFilterTimeStartCpp = tic;
    for idx = 1:10
        fwfmCpp(:, idx) = matchedFilterCpp(y.RData((idx-1) * ptsd + (1:ptsd), 64)', flipped_w2);
    end
    matchedFilterTimesCpp(runIdx) = toc(matchedFilterTimeStartCpp);
end

% Convert times to microseconds
matchedFilterTimesMatlabmus = matchedFilterTimesMatlab * 1e6;
matchedFilterTimesCppmus = matchedFilterTimesCpp * 1e6;
dataLoadingTimesMus = dataLoadingTimes * 1e6;
convTimesMus = convTimes * 1e6;
loopTimesMus = loopTimes * 1e6;

%% Plot the comparison of execution times
figure;
hold on;
plot(1:numRuns, matchedFilterTimesMatlabmus, '-o', 'DisplayName', 'Total MATLAB Matched Filter Time', 'LineWidth', 2);
plot(1:numRuns, matchedFilterTimesCppmus, '-o', 'DisplayName', 'Total MEX (cpp) Matched Filter Time', 'LineWidth', 2);
plot(1:numRuns, dataLoadingTimesMus, '-o', 'DisplayName', 'Data Loading Time', 'LineWidth', 2);
plot(1:numRuns, convTimesMus, '-o', 'DisplayName', 'Convolution Time', 'LineWidth', 2);
%plot(1:numRuns, loopTimesMus, '-o', 'DisplayName', 'Loop Time', 'LineWidth', 2);
xlabel('Run Number');
ylabel('Time (\mus)');
title('Detailed Timing of MATLAB Matched Filter Function');
legend('Location', 'northwest');
grid on;
hold off;

% Set the axes to log scale
set(gca, 'YScale', 'log');
