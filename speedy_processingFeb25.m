%%%----- Sunny, Abby, and Jack's code for ultrafast prediction of histotripsy pulse times----%%%


%%% ttp = time to next pulse
function ttp=speedy_processing(RData, PData, Trans, TW, P, Receive3);

% initialize dictonary to store results
persistent ttp_dict;
if isempty(ttp_dict)
    ttp_dict = {};  % A cell array to store {time, ttp} pairs
end

tw1 = TW(1);
tw1 = tw1.Waveform;
tw2 = load('C:\Users\verasonics\Documents\Vantage-4.5.3-2107301223\PME - UF seq img\Setup Data\SH_Chirp_2024March22.mat'); % loading synthetic waveform used for transmitting fundamental
tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure 

% Length of data
lenData = 10; %eventually dont hardcode this

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

% to display fit time and power law function in the command window:
%params = speedy_power_fit((1:lenData)', intGS'/intGS(1));

% to fit the power law without printing information:
func = @() speedy_power_fit((1:lenData)', intGS'/intGS(1));
[~, params] = evalc('func()');

% Compute R^2 for the fit
t = (1:lenData)';
y_true = intGS'/intGS(1);
y_fit = params(1) * t.^params(2);
SS_res = sum((y_true - y_fit).^2);
SS_tot = sum((y_true - mean(y_true)).^2);
R2 = 1 - (SS_res / SS_tot);

%intensity = mean(y_true);

% Initialize variables
ttp = 0;

% Setting thresholds
dissolved = 0.5;    % intensity at which bubble is declared dissolved
too_long = 100;     % time at which ttp is unreasonably long
too_short = 1;      % time at which ttp is unsreasonably short
min_R2 = 0.01;       % unacceptably low R^2


% Check fit quality
try
    extrapolatedtime = (dissolved / params(1))^(1 / params(2));
    if R2 < min_R2
        ttp = 'Error: poor fit';
    else
        if params(2) < 0
            if extrapolatedtime > too_long
                %ttp = 'Error: ttp is too long';
                ttp = y_true
            elseif extrapolatedtime < too_short
                %ttp = 'Error: ttp is too short';
                 ttp = y_true

            else
                %ttp = extrapolatedtime;
                ttp = y_true
            end
        else
            %ttp = 'Error: non-negative fit'
            ttp = y_true
        end
    end
catch
    % Handle any errors during fitting or calculations
    ttp = 'Error: other'
end

current_time = datetime('now', 'Format', 'HH:mm:ss.SSSSSS');
ttp_dict(end+1,:) = {current_time, ttp};
disp('Dictionary of [Time, ttp]:');
disp(ttp_dict);

end