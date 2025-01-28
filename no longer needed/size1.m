% fall setup file
%Zzz = load(fullfile('Setup Data', 'SetUpC5_2v_ChirpPCI_2024April29.mat'));
% winter setup file
Zzz = load(fullfile('Setup Data','SetUpC5_2v_ChirpPCI_PME.mat'));
Trans = Zzz.Trans;
P = Zzz.P;
Receive3 = Zzz.Receive3;

tw1 = Zzz.TW(1).Waveform;
tw2 = load(fullfile('Setup Data', 'SH_Chirp_2024March22.mat')); % loading synthetic waveform used for transmitting fundamental
tw2 = tw2.TW.Waveform; % transmit waveform is in the TW structure 

filename = fullfile('Winter Data', 'UFData_TT_1_dataset_18.mat');
y = load(filename);