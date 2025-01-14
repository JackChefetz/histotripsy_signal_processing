close all
clear all
clc

%% loading relevant data files
Zzz = load(fullfile('Setup Data', 'SetUpC5_2v_ChirpPCI_PME.mat'));
Trans = Zzz.Trans;
P = Zzz.P;
Receive3 = Zzz.Receive3;

tw1 = Zzz.TW(1).Waveform;
tw2 = load(fullfile('Setup Data', 'SH_Chirp_2024March22.mat')); % loading synthetic waveform used for transmitting fundamental
tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure 

% Get all filenames in Winter Data folder for 'UFData_TT_1_dataset_*.mat'
dataFiles = dir(fullfile('Winter Data', 'UFData_TT_1_dataset_*.mat'));

% Ensure the directory for saving figures exists
outputDir = 'Figs_WinterWk2';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

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

% Loop over each data file
for fileIdx = 1:length(dataFiles)
    % Load the data file
    filename = fullfile(dataFiles(fileIdx).folder, dataFiles(fileIdx).name);
    y = load(filename);

    % Determine number of points associated with individual waveform
    twfm = y.RData(:, 64); % Averaged RF data collection
    numZeros = find(flipud(twfm) ~= 0, 1, 'first')-1;  % Lenght of all RF data without additional buffer
    ptsd = int16((length(twfm)-numZeros)/P.numAcqs); % Points per frame
    frame_no = 1;
    x = y.RData((frame_no-1)*ptsd+(1:ptsd),:);

    %% Determine absolute time
    time = (1:double(ptsd))*(1/Fs) + 2*Receive3(64).startDepth/(Trans.frequency*1e6);

    %% Apply matched filter to waveforms
    fwfm = zeros(ptsd, lenData);
    for idx = 1:lenData
        fwfm(:, idx) = conv2(y.RData((idx-1)*ptsd+(1:ptsd),64)', fliplr(w2),'same')';
    end

    %% Plot and save separate figures
    for i = 1:10
        figure; % Create a new figure for each plot
        subplot(3, 1, 1)
        plot(time*1e6, fwfm(:, 1))
        title('0 ms')

        subplot(3, 1, 2)
        plot(time*1e6, fwfm(:, 5))
        title('5 ms')

        subplot(3, 1, 3)
        plot(time*1e6, fwfm(:, 10))
        title('10 ms')
        xlabel('Time (\mus)')

        % Save the figure to the output directory
        saveas(gcf, fullfile(outputDir, sprintf('Fig_Fwfm_Time_%d.png', fileIdx)));
        close; % Close the figure to prevent overlapping
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

    % Plot integrated signal
    figure;
    plot(1:lenData, intGS/intGS(1), '.', 'MarkerSize', 20)
    xlabel('Time (ms)')
    ylabel('Integrated Signal (AU)')

    % Fit power law
    [efit, gof] = fit((1:lenData)', intGS'/intGS(1), 'power1');
    hold on
    plot(1:lenData, feval(efit, 1:lenData), '--r')

    % Save the figure to the output directory
    saveas(gcf, fullfile(outputDir, sprintf('Fig_Integrated_Signal_%d.png', fileIdx)));
    close; % Close the figure to prevent overlapping
end
