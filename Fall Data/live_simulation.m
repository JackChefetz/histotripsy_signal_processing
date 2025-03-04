close all
clear all
clc

%% Loading relevant data files
Zzz = load(fullfile('Setup Data', 'SetUpC5_2v_ChirpPCI_PME.mat'));
Trans = Zzz.Trans;
P = Zzz.P;
Receive3 = Zzz.Receive3;

tw1 = Zzz.TW(1).Waveform;
tw2 = load(fullfile('Setup Data', 'SH_Chirp_2024March22.mat')); % Synthetic waveform for transmitting fundamental
tw2 = tw2.TW.Waveform; % Transmit waveform is in the TW structure

Fs = 250 / 18 * 1e6; % Sampling frequency of acquired RF data
tFs = 250e6; % Sampling frequency of synthetic waveform

% Adjust chirp templates to match RF data sampling frequency
w1 = interp1((1:length(tw1)) / tFs, tw1, 1 / Fs:1 / Fs:length(tw1) / tFs);
w1 = [zeros(1, length(w1)) w1];
w1 = w1 / max(abs(w1));

w2 = interp1((1:length(tw2)) / tFs, tw2, 1 / Fs:1 / Fs:length(tw2) / tFs);
w2 = [zeros(1, length(w2)) w2];
w2 = w2 / max(abs(w2));

%% Simulation setup
num_samples = 50; % Number of samples for simulation
num_files = 20; % Total number of data files
results = cell(1, num_samples); % Preallocate results

for sample_idx = 1:num_samples
    % Randomly select a data file
    file_num = randi(num_files); % Sample with replacement
    filename = fullfile('Winter Data', sprintf('UFData_TT_1_dataset_%d.mat', file_num));
    try
        y = load(filename);
    catch
        results{sample_idx} = 'bad data';
        continue;
    end

    % Extract RF data and process
    twfm = y.RData(:, 64);
    numZeros = find(flipud(twfm) ~= 0, 1, 'first') - 1;
    ptsd = int16((length(twfm) - numZeros) / P.numAcqs);
    fwfm = zeros(ptsd, 10);

    for idx = 1:10
        fwfm(:, idx) = conv2(y.RData((idx - 1) * ptsd + (1:ptsd), 64)', fliplr(w2), 'same')';
    end

    % Determine time window for bubble cloud
    time = (1:double(ptsd)) * (1 / Fs) + 2 * Receive3(64).startDepth / (Trans.frequency * 1e6);
    focus = 50; % [mm]
    width = 5; % [mm]
    tdx = find(1e6 * time > 2 * (focus - width / 2) / 1.54 & 1e6 * time < 2 * (focus + width / 2) / 1.54);

    % Calculate integrated signal within tdx for each frame
    intGS = zeros(1, 10);
    for idx = 1:10
        temp = fwfm(:, idx) .^ 2;
        intGS(idx) = sum(temp(tdx));
    end

    % Perform power law fit
    try
        params = speedy_power_fit((1:10)', intGS' / intGS(1));
        fit_values = params(1) * (1:10)'.^params(2);

        % Check fit quality (decreasing with time and reasonable R^2)
        if params(2) < 0
            % Extrapolate time to y = 0.3
            extrapolated_time = (0.3 / params(1))^(1 / params(2));
            
            % Check if extrapolated time is too long
            if extrapolated_time > 100
                results{sample_idx} = 'too long';
            else
                results{sample_idx} = extrapolated_time;
            end
        elseif params(2) > 0
            % If fit suggests increasing values over time
            results{sample_idx} = 'increasing';
        else
            % Default for other cases (e.g., no change)
            results{sample_idx} = 'error';
        end
    catch
        % Handle any errors during fitting or calculations
        results{sample_idx} = 'error';
    end
end


%% Display results
disp('Simulation Results:')
for i = 1:num_samples
    fprintf('Sample %d: %s\n', i, num2str(results{i}));
end
