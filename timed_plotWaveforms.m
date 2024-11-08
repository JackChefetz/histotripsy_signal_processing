close all
clear all
clc

%% Start total timer
totalTimeStart = tic;

% Sub-timer for loading data
loadTimeStart = tic;
%% loading relevant data files
Zzz = load('SetUpC5_2v_ChirpPCI_2024April29.mat');
Trans = Zzz.Trans;
P = Zzz.P;
Receive3 = Zzz.Receive3;
tw1 = Zzz.TW(1).Waveform;
tw2 = load('SH_Chirp_2024March22.mat'); % loading synthetic waveform used for transmitting fundamental
tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure
filename = ['UFData_Agarose_dataset_1', '.mat'];
y = load(filename);
loadTime = toc(loadTimeStart);

% Sub-timer for setting sampling frequency and template adjustment
samplingTimeStart = tic;
% sampling frequency of acquired RF data
Fs = 250/18 * 1e6;
tFs = 250e6; % Sampling frequency of synthetically generated waveform

% adjusting sampling frequency of chirp templates similar to the RF data sampling frequency
% ------- fundamental chirp template --------
w1 = interp1((1:length(tw1))/tFs, tw1, 1/Fs:1/Fs:length(tw1)/tFs);
w1 = [zeros(1,length(w1)) w1]; % padding extra zeros
w1 = w1/max(abs(w1));
% ------- subharmonic chirp template --------
w2 = interp1((1:length(tw2))/tFs, tw2, 1/Fs:1/Fs:length(tw2)/tFs);
w2 = [zeros(1,length(w2)) w2]; % padding extra zeros
w2 = w2/max(abs(w2));
samplingTime = toc(samplingTimeStart);

% Sub-timer for processing acquired RF image data
imageProcessingTimeStart = tic;
% loading single acquired RF image
twfm = y.RData(:, 64); % Averaged RF data collection
numZeros = find(flipud(twfm) ~= 0, 1, 'first') - 1;  % Length without additional buffer
ptsd = int16((length(twfm) - numZeros) / P.numAcqs); % Points per frame
frame_no = 1;
x = y.RData((frame_no-1) * ptsd + (1:ptsd), :);
imageProcessingTime = toc(imageProcessingTimeStart);

% Sub-timer for absolute time calculation
timeCalcTimeStart = tic;
%% Determine absolute time
time = (1:double(ptsd)) * (1/Fs) + 2 * Receive3(64).startDepth / (Trans.frequency * 1e6);
timeCalcTime = toc(timeCalcTimeStart);

% Sub-timer for matched filter application
matchedFilterTimeStart = tic;
%% Apply matched filter to waveforms
fwfm = zeros(ptsd, 10);
for idx = 1:10
    fwfm(:, idx) = conv2(y.RData((idx-1) * ptsd + (1:ptsd), 64)', fliplr(w2), 'same')';
end
matchedFilterTime = toc(matchedFilterTimeStart);

% Sub-timer for bubble cloud analysis
bubbleCloudTimeStart = tic;
%% Determine approximate window to assess bubble cloud
focus = 50; %[mm] focal distance
width = 5;  %[mm] FWHM of focal width
tdx = find(1e6 * time > 2 * (focus - width / 2) / 1.54 & 1e6 * time < 2 * (focus + width / 2) / 1.54);

% Calculate integrated signal within tdx for each frame
intGS = zeros(1, 10); % Preallocate
for idx = 1:10
    temp = fwfm(:, idx).^2;
    intGS(idx) = sum(temp(tdx));
end
bubbleCloudTime = toc(bubbleCloudTimeStart);

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

% Power law fit
[efit, gof] = fit((1:10)', intGS' / intGS(1), 'power1');
hold on
plot(1:10, feval(efit, 1:10), '--r')
plotTime = toc(plotTimeStart);

% Total time
totalTime = toc(totalTimeStart);

%% Display Timing Results
fprintf('Load Time: %.4f seconds\n', loadTime);
fprintf('Sampling Frequency Adjustment Time: %.4f seconds\n', samplingTime);
fprintf('Image Processing Time: %.4f seconds\n', imageProcessingTime);
fprintf('Absolute Time Calculation Time: %.4f seconds\n', timeCalcTime);
fprintf('Matched Filter Application Time: %.4f seconds\n', matchedFilterTime);
fprintf('Bubble Cloud Analysis Time: %.4f seconds\n', bubbleCloudTime);
fprintf('Plotting Time: %.4f seconds\n', plotTime);
fprintf('Total Time (excluding plotting): %.4f seconds\n', totalTime - plotTime);
fprintf('Total Time: %.4f seconds\n', totalTime);
