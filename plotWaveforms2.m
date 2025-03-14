close all
clear all
clc

%% loading relevant data files
Zzz = load(fullfile('Setup Data', 'SetUpC5_2v_ChirpPCI_2024April29.mat'));
Trans = Zzz.Trans;
P = Zzz.P;
Receive3 = Zzz.Receive3;

tw1 = Zzz.TW(1).Waveform;
tw2 = load(fullfile('Setup Data', 'SH_Chirp_2024March22.mat')); % loading synthetic waveform used for transmitting fundamental
tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure 

%filename = fullfile('Fall Data', 'UFData_Agarose_dataset_1.mat');
filename = fullfile('Winter Data', 'UFData_TT_1_dataset_1.mat');
y = load(filename);

% sampling frequency of acquired RF data (For verasonics, if Recieve structure has 'sample mode' = 'NS200BW', then it means fs = 4*Trans_center_frequency.
% Thus, here it will be 3.57 x 4 = 14.28 MHz. Now verasonics can only generate sampling frequencies to be factor of 250 MHz,
% Therefore, here the closest to 14.28 MHz will be: 250/18 = 13.8889.
% Because 250/17 = 14.7059 MHz will be slightly further from 14.28 MHz.
Fs = 250/18 * 1e6 ;
tFs = 250e6; % Sampling frequency of synthetically generated waveform

% adjusting sampling frequency of chirp templates similar to the RF data sampling frequency (i.e. Fs)
% ------- fundamental chirp template --------
w1 = interp1((1:length(tw1))/tFs,tw1,1/Fs:1/Fs:length(tw1)/tFs);
w1 = [zeros(1,length(w1)) w1];% padding extra zeros because the center point is considered by Matlab as zeroth index while doing convolution
w1 = w1/max(abs(w1));
% ------- subharmonic chirp template --------
w2 = interp1((1:length(tw2))/tFs,tw2,1/Fs:1/Fs:length(tw2)/tFs);
w2 = [zeros(1,length(w2)) w2];% padding extra zeros because the center point is considered by Matlab as zeroth index while doing convolution
w2 = w2/max(abs(w2));

% loading single acquired RF image (whose imaging window is from start_depth to end_depth).
% Later on, instead of just one, all bunch of acquired RF images can be called here and then process them one-by-one in For loop

% Determine number of points associated with individual waveform
twfm = y.RData(:, 64); % Averaged RF data collection
numZeros = find(flipud(twfm) ~= 0, 1, 'first')-1;  % Lenght of all RF data without additional buffer
ptsd = int16((length(twfm)-numZeros)/P.numAcqs); % Points per frame ... instead of ptsPWfm let's call it ptsd for fun!
frame_no = 1;
x = y.RData((frame_no-1)*ptsd+(1:ptsd),:);

%% Determine absolute time

time = (1:double(ptsd))*(1/Fs) + 2*Receive3(64).startDepth/(Trans.frequency*1e6);

%% Apply matched filter to waveforms

fwfm = zeros(ptsd, P.numAcqs);
for idx = 1:P.numAcqs
    fwfm(:, idx) = conv2(y.RData((idx-1)*ptsd+(1:ptsd),64)', fliplr(w2),'same')';
end

figure(101)
subplot(3, 1, 1)
plot(time*1e6, fwfm(:, 1))
title('0 ms???')

subplot(3, 1, 2)
plot(time*1e6, fwfm(:, P.numAcqs/2))
title('5 ms???')

subplot(3, 1, 3)
plot(time*1e6, fwfm(:, P.numAcqs))
title('10 ms???')
xlabel('Time (\mus)')


%% Determine approximate window to assess bubble cloud
focus = 50; %[mm] focal distance
width = 5;  %[mm] FWHM of focual width
tdx = find(1e6*time > 2*(focus - width/2)/1.54 & 1e6*time< 2*(focus + width/2)/1.54); %Time indicies for bubble activity within focus (5 mm length)

% Calculate integrated signal within tdx for each frame
intGS = zeros(1, P.numAcqs);   % Preallocate to assign integrated signal for each frame

for idx = 1:P.numAcqs
    temp = fwfm(:, idx).^2;
    intGS(idx) = sum(temp(tdx));
end


% Now plot data
figure(102)
plot(1:P.numAcqs, intGS/intGS(1), '.', 'MarkerSize', 20)
xlabel('Time (ms)')
ylabel('Integrated Signal (AU)')

% Maybe do power law
[efit gof] = fit((1:P.numAcqs)', intGS'/intGS(1),'power1')

hold on
plot(1:P.numAcqs, feval(efit, 1:P.numAcqs), '--r')



    
