%%%----- Sunny, Abby, and Jack's code for ultrafast prediction of histotripsy pulse times----%%%


%%% ttp = time to next pulse
function [ttp, ttpcheck]=speedy_processing(RData, PData, Trans, TW, P, Receive3);


%% loading relevant data files

%y = UFdata;

%Trans = Zzz.Trans;
%P = Zzz.P;
%Receive3 = Zzz.Receive3;

tw1 = TW(1);
%tw1 = Zzz.tw1.Waveform;
tw1 = tw1.Waveform;
tw2 = load('C:\Users\verasonics\Documents\Vantage-4.5.3-2107301223\PME - UF seq img\Setup Data\SH_Chirp_2024March22.mat'); % loading synthetic waveform used for transmitting fundamental
%tw2 = TW(2) come back and fix
tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure 
%tw2 = tw2.Waveform;

% Length of data
lenData = 10; %eventually dont hardcode this
thresh = 0.3; %intensity at which bubble is declared dissolved
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
ttp = 0; %initialize ttp variable
ttpcheck = 0;

% Check fit quality (decreasing with time and reasonable R^2)
try
    % Extrapolate time to y = threshold
    extrapolatedtime = (thresh / params(1))^(1 / params(2));
    if params(2) < 0

        % Check if extrapolated time is too long
        if extrapolatedtime > 100
            ttpcheck = 'Warning: The time to next pulse is too long'
        else
            ttpcheck = 'No errors!'
            ttp = extrapolatedtime
        end
    elseif params(2) > 0
        % If fit suggests increasing values over time
        ttpcheck = 'Warning: The power law fit is increasing'
        ttp = extrapolatedtime
    else
        % Default for other cases (e.g., no change)
        ttpcheck = 'Warning: non-negative power law fit'
        ttp = extrapolatedtime
    end
catch
    % Handle any errors during fitting or calculations
    ttpcheck = 'Warning: Fit function error'
    ttp = extrapolatedtime
end

%newRow = table(params(1), params(2), 'VariableNames', {'Param1','Param2'});
%matname = 'resultsTable.mat';
%csvname = 'params.csv';
%if exist (matname, 'file')
%    load(matname, 'resultsTable');
%    resultsTable = [resultsTable; newRow];
%else
%    resultsTable = newRow;
%end

% save(matname, 'resultsTable');
% writeable(resultsTable, csvname);