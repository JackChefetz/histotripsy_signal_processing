%%%----- Sunny, Abby, and Jack's code for ultrafast prediction of histotripsy pulse times----%%%


%%% ttp = time to next pulse
function [ttp]= speedy_processing(UFData, Trans, RData)


%% loading relevant data files

%y = UFdata;

Trans = Zzz.Trans;
P = Zzz.P;
Receive3 = Zzz.Receive3;

tw1 = Zzz.TW(1).Waveform;
tw2 = load(fullfile('Setup Data', 'SH_Chirp_2024March22.mat')); % loading synthetic waveform used for transmitting fundamental
tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure 


% Length of data
lenData = 14;

% sampling frequency of acquired RF data
Fs = 250/18 * 1e6 ;
tFs = 250e6; % Sampling frequency of synthetically generated waveform

% adjusting sampling frequency of chirp templates similar to the RF data sampling frequency (i.e. Fs)
w1 = interp1((1:length(tw1))/tFs,tw1,1/Fs:1/Fs:length(tw1)/tFs);
w1 = [zeros(1,length(w1)) w1]; % padding extra zeros
w1 = w1/max(abs(w1));
w2 = interp1((1:length(tw2))/tFs,tw2,1/Fs:1/Fs:length(tw2)/tFs);
w2 = [zeros(1,length(w2)) w2]; % padding extra zeros
w2 = w2/max(abs(w2));

% Determine number of points associated with individual waveform
twfm = RData(:, 64); % Averaged RF data collection
numZeros = find(flipud(twfm) ~= 0, 1, 'first')-1;  % Lenght of all RF data without additional buffer
ptsd = int16((length(twfm)-numZeros)/P.numAcqs); % Points per frame
frame_no = 1;
x = RData((frame_no-1)*ptsd+(1:ptsd),:);

%% Determine absolute time
time = (1:double(ptsd))*(1/Fs) + 2*Receive3(64).startDepth/(Trans.frequency*1e6);

%% Apply matched filter to waveforms
fwfm = zeros(ptsd, lenData);
for idx = 1:lenData
    fwfm(:, idx) = conv2(RData((idx-1)*ptsd+(1:ptsd),64)', fliplr(w2),'same')';
end


%% Determine approximate window to assess bubble cloud
focus = 50; % [mm] focal distance
width = 5;  % [mm] FWHM of focal width
tdx = find(1e6*time > 2*(focus - width/2)/1.54 & 1e6*time < 2*(focus + width/2)/1.54); % Time indices for bubble activity within focus

% Calculate integrated signal within tdx for each frame
intGS = zeros(1,lenData);   % Preallocate to assign integrated signal for each frame
for idx = 1:lenData
    temp = fwfm(:, idx).^2;
    intGS(idx) = sum(temp(tdx));
end


%%% c++ power law fit
params = speedy_power_fit((1:lenData)', intGS'/intGS(1));
ttp = params(1) * (1:lenData)'.^params(2);

2+3