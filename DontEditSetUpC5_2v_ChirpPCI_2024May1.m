% Notice:
%   This file is provided by Verasonics to end users as a programming
%   example for the Verasonics Vantage Research Ultrasound System.
%   Verasonics makes no claims as to the functionality or intended
%   application of this program and the user assumes all responsibility
%   for its use
%
% File name: SetUpC5_2vFlash.m - Example of curved array imaging with flash
%                                transmit
% Description:
%   Sequence programming file for C5-2v curved array, using a flash transmit
%   and single receive acquisition. All 128 transmit and receive channels
%   are active for each acquisition. Processing is asynchronous with
%   respect to acquisition.
%
% Last update:
% 09/11/2020 - Update to SW 4.3 format for new user UIControls and External function definitions (VTS-1691).
%   More info:(?/Example_Scripts/Vantage_Features/New UI Scheme/SetUpL11_5vFlash_NewUI)

clear all
%-----ADD PATHS AND LOAD FILES---------
path = 'C:\Users\verasonics\Documents\Vantage-4.5.3-2107301223';
load('RenalAblationFile.mat');

 %constants
SpeedOfSound = 1540;
wls2mm = SpeedOfSound/(1000*3.57);
target_depth = 60; % imaging center target depth in mm
P.numRays = 128;  % no. of raylines to program
P.numTx = 14;
P.txFocus = round(target_depth/wls2mm); %100
P.startDepth = 5; % startDepth and endDepth in wavelength
P.endDepth = 192;


% Only acquire one data set per run. Allow 10 pulses to be fired, and then
% amass 900 frames at 1 kHz (check this frame rate and total)
%nskip = Num_Pulses;
P.numAcqs = 10;      % no. of Acquisitions in a Receive frame (this is a "superframe")
P.numFrames = 1; %Num_Pulses/nskip;      % no. of Receive frames (real-time images are produced 1 per frame)
simulateMode = 0;   % 1 for simulation, 0 when connected to verasonics. 2 is to work with saved data at a later time

% RFdataFilename = 'RFdataHFR';
% if simulateMode==2      % playback using this script still results in processing only one acquisiton per super frame
%     load (RFdataFilename)
% end

%% ------------------------------SYSTEM PARAMETERS-----------------------------------------------
% Specify system parameters.
filename = [mfilename '.mat']; % used to launch VSX automatically
Resource.Parameters.numTransmit = 128;  % number of transmit channels.
Resource.Parameters.numRcvChannels = 128;  % number of receive channels.
Resource.Parameters.speedOfSound = 1540;
Resource.Parameters.verbose = 2;
Resource.Parameters.initializeOnly = 0;
Resource.Parameters.simulateMode = 0;
%  Resource.Parameters.simulateMode = 1 forces simulate mode, even if hardware is present.
%  Resource.Parameters.simulateMode = 2 stops sequence and processes RcvData continuously.

%% -----------------------STRUCTURE ARRAYS (TRANS AND PDATA)------------------
% Specify Trans structure array.
Trans.name = 'C5-2v';
Trans.units = 'wavelengths'; % required in Gen3 to prevent default to mm units
Trans = computeTrans(Trans);  % C5-2 transducer is 'known' transducer so we can use computeTrans.
Trans.maxHighVoltage = 50;  % set maximum high voltage limit for pulser supply.
radius = Trans.radius;
scanangle = Trans.numelements*Trans.spacing/radius;
dtheta = scanangle/P.numRays;
theta = -(scanangle/2)+ 0.5*dtheta; % angle to left edge from centerline
Angle = theta:dtheta:(-theta);

% Specify PData structure array.
PData(1).PDelta = [1.0, 0, 0.5];  % x, y and z pdeltas
sizeRows = 10 + ceil((P.endDepth + radius - (radius * cos(scanangle/2)))/PData(1).PDelta(3));
sizeCols = 10 + ceil(2*(P.endDepth + radius)*sin(scanangle/2)/PData(1).PDelta(1));
PData(1).Size = [sizeRows,sizeCols,1];     % size, origin and pdelta set region of interest.
PData(1).Origin(1,1) = (P.endDepth+radius)*sin(-scanangle/2) - 5;
PData(1).Origin(1,2) = 0;
PData(1).Origin(1,3) = ceil(radius * cos(scanangle/2)) - radius - 5;
PData(1).Region = struct(...
    'Shape',struct('Name','Sector','Position',[0,0,-radius],'r1',radius+P.startDepth,'r2',radius+P.endDepth,'angle',scanangle));
PData(1).Region = computeRegions(PData(1));

% Specify A Priori PData structure array.
PData(2).PDelta = [1.0, 0, 0.5];  % x, y and z pdeltas
sizeRows = 10 + ceil((P.endDepth + radius - (radius * cos(scanangle/2)))/PData(1).PDelta(3));
sizeCols = 10 + ceil(2*(P.endDepth + radius)*sin(scanangle/2)/PData(1).PDelta(1));
PData(2).Size = [sizeRows,sizeCols,1];     % size, origin and pdelta set region of interest.
PData(2).Origin(1,1) = (P.endDepth+radius)*sin(-scanangle/2) - 5;
PData(2).Origin(1,2) = 0;
PData(2).Origin(1,3) = ceil(radius * cos(scanangle/2)) - radius - 5;
% Define PData Regions for numRays scanlines
for j = 1:P.numRays
    PData(2).Region(j) = struct(...
        'Shape',struct('Name','Sector',...
                       'Position',[0,0,-radius],...
                       'r1',radius+P.startDepth,...
                       'r2',radius+P.endDepth,...
                       'angle',dtheta,...
                       'steer',Angle(j)));
end
PData(2).Region = computeRegions(PData(2));

%  Media points for curved array.
% - Uncomment for speckle
% Media.numPoints = (20000);
% Media.MP = rand(Media.numPoints,4);
% Media.MP(:,2) = 0;
% Media.MP(:,4) = 0.01 + 0.04*Media.MP(:,4);  % Random low amplitude
% RandR = P.endDepth*Media.MP(:,1)+radius;
% RandTheta = scanangle*(Media.MP(:,3)-0.5);
% Media.MP(:,1) = RandR.*sin(RandTheta);
% Media.MP(:,3) = RandR.*cos(RandTheta)-radius;
% - Define points
%Media.MP(1,:) = [0,0,70,1.0];
Media.MP(1,:) = [0,0,10,1.0];
Media.MP(2,:) = [(radius+10)*sin(-0.2608),0,(radius+10)*cos(-0.2608)-radius,1.0];
Media.MP(3,:) = [(radius+10)*sin(0.2608),0,(radius+10)*cos(0.2608)-radius,1.0];
Media.MP(4,:) = [(radius+10)*sin(-0.5267),0,(radius+10)*cos(-0.5267)-radius,1.0];
Media.MP(5,:) = [(radius+10)*sin(0.5267),0,(radius+10)*cos(0.5267)-radius,1.0];
Media.MP(6,:) = [0,0,40,1.0];
Media.MP(7,:) = [0,0,70,1.0];
Media.MP(8,:) = [(radius+70)*sin(-0.2608),0,(radius+70)*cos(-0.2608)-radius,1.0];
Media.MP(9,:) = [(radius+70)*sin(0.2608),0,(radius+70)*cos(0.2608)-radius,1.0];
Media.MP(10,:) = [(radius+70)*sin(-0.5267),0,(radius+70)*cos(-0.5267)-radius,1.0];
Media.MP(11,:) = [(radius+70)*sin(0.5267),0,(radius+70)*cos(0.5267)-radius,1.0];
Media.MP(12,:) = [0,0,100,1.0];
Media.MP(13,:) = [0,0,130,1.0];
Media.MP(14,:) = [(radius+130)*sin(-0.2608),0,(radius+130)*cos(-0.2608)-radius,1.0];
Media.MP(15,:) = [(radius+130)*sin(0.2608),0,(radius+130)*cos(0.2608)-radius,1.0];
Media.MP(16,:) = [(radius+130)*sin(-0.5267),0,(radius+130)*cos(-0.5267)-radius,1.0];
Media.MP(17,:) = [(radius+130)*sin(0.5267),0,(radius+130)*cos(0.5267)-radius,1.0];
Media.MP(18,:) = [0,0,160,1.0];
Media.MP(19,:) = [0,0,190,1.0];
Media.MP(20,:) = [(radius+190)*sin(-0.2608),0,(radius+190)*cos(-0.2608)-radius,1.0];
Media.MP(21,:) = [(radius+190)*sin(0.2608),0,(radius+190)*cos(0.2608)-radius,1.0];
Media.MP(22,:) = [(radius+190)*sin(-0.5267),0,(radius+190)*cos(-0.5267)-radius,1.0];
Media.MP(23,:) = [(radius+190)*sin(0.5267),0,(radius+190)*cos(0.5267)-radius,1.0];
Media.function = 'movePoints';

%% -------------------------RESOURCES------------------------------------
% % Specify Resources.
% Resource.RcvBuffer(1).datatype = 'int16';
% Resource.RcvBuffer(1).rowsPerFrame = 4096*P.numAcqs;
% Resource.RcvBuffer(1).colsPerFrame = Resource.Parameters.numRcvChannels;
% Resource.RcvBuffer(1).numFrames = 1;     % UF Frames
% Resource.InterBuffer(1).numFrames = 1;     % 20 frames for rcvDataLoop buffer.
% Resource.ImageBuffer(1).datatype = 'double';
% Resource.ImageBuffer(1).numFrames = P.numFrames*P.numAcqs;
% Resource.DisplayWindow(1).Title = 'C5-2vFlash';
% Resource.DisplayWindow(1).numFrames = P.numFrames*P.numAcqs;
% Resource.DisplayWindow(1).pdelta = 0.45;
% ScrnSize = get(0,'ScreenSize');
% DwWidth = ceil(PData(1).Size(2)*PData(1).PDelta(1)/Resource.DisplayWindow(1).pdelta);
% DwHeight = ceil(PData(1).Size(1)*PData(1).PDelta(3)/Resource.DisplayWindow(1).pdelta);
% Resource.DisplayWindow(1).Position = [250,(ScrnSize(4)-(DwHeight+150))/2, ...  % lower left corner position
%                                       DwWidth, DwHeight];
% Resource.DisplayWindow(1).ReferencePt = [PData(1).Origin(1),0,PData(1).Origin(3)];   % 2D imaging is in the X,Z plane
% Resource.DisplayWindow(1).Type = 'Matlab';
% Resource.DisplayWindow(1).numFrames = P.numFrames*P.numAcqs;
% Resource.DisplayWindow(1).AxesUnits = 'mm';
% Resource.DisplayWindow.Colormap = gray(256);

% %----------FOR PRE BMODE--------------------------------------------------%
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = 2*4096*P.numRays;   % this size allows for maximum range
Resource.RcvBuffer(1).colsPerFrame = Resource.Parameters.numRcvChannels;
Resource.RcvBuffer(1).numFrames = 2;    % pre bmode frames acquired
Resource.InterBuffer(1).numFrames = 1;  % one intermediate buffer needed.
Resource.ImageBuffer(1).datatype = 'double';
Resource.ImageBuffer(1).numFrames = 2;
Resource.DisplayWindow(1).Title = 'C5-2vRyLns';
Resource.DisplayWindow(1).pdelta = 0.45;
ScrnSize = get(0,'ScreenSize');
DwWidth = ceil(PData(2).Size(2)*PData(2).PDelta(1)/Resource.DisplayWindow(1).pdelta);
DwHeight = ceil(PData(2).Size(1)*PData(2).PDelta(3)/Resource.DisplayWindow(1).pdelta);
Resource.DisplayWindow(1).Position = [250,(ScrnSize(4)-(DwHeight+150))/2, ...  % lower left corner position
                                      DwWidth, DwHeight];
Resource.DisplayWindow(1).ReferencePt = [PData(2).Origin(1),0,PData(2).Origin(3)];   % 2D imaging is in the X,Z plane
Resource.DisplayWindow(1).Type = 'Verasonics';
Resource.DisplayWindow(1).numFrames = 20;
Resource.DisplayWindow(1).AxesUnits = 'mm';
Resource.DisplayWindow.Colormap = gray(256);

%-----------FOR PCI-------------------------------------------------------%
Resource.RcvBuffer(2).datatype = 'int16';
Resource.RcvBuffer(2).rowsPerFrame = 2*2048; %4096
Resource.RcvBuffer(2).colsPerFrame = Resource.Parameters.numRcvChannels;
Resource.RcvBuffer(2).numFrames = nskip;    % PCI frames acquired

% -------------------------UF RESOURCES------------------------------------
Resource.RcvBuffer(3).datatype = 'int16';
Resource.RcvBuffer(3).rowsPerFrame = 4096*P.numAcqs;
Resource.RcvBuffer(3).colsPerFrame = Resource.Parameters.numRcvChannels;
Resource.RcvBuffer(3).numFrames = 1;     % UF Frames

%% -------------------------TX, TPC, TGC--------------------
% Specify Transmit waveform structure.
% Load Chirp
addpath('C:\Users\verasonics\Documents\Vantage-4.5.3-2107301223\Tools\ArbWaveToolbox')
tt = load('Chirp_2024March22.mat', 'TW');
tt.TW.Parameters = [];
TW(1) = tt.TW;

% % Specify Transmit waveform structure for PCI
TW(2).type = 'parametric';
TW(2).Parameters = [Trans.frequency,.67,2,1];

% Specify Transmit waveform structure for Pre Bmode
TW(3).type = 'parametric';
TW(3).Parameters = [Trans.frequency,.67,2,1];

% Set voltage to imaging array
TPC(1).maxHighVoltage = 40; % set maximum high voltage limit for pulser supply.
TPC(1).highVoltageLimit = 40;  % set maximum high voltage limit for pulser supply.
TPC(1).hv = 25;  % max val: 25 V

% Specify TX structure array.
TX(1) = repmat(struct('waveform', 1, ...
                   'Origin', [0.0,0.0,radius], ...
                   'focus', 0.0, ...
                   'Steer', [0.0,0.0], ...
                   'Apod', ones(1,Trans.numelements), ...
                   'Delay', zeros(1,Trans.numelements)), 1, 1);
% - Set event specific TX attributes.
TX(1).Delay = computeTXDelays(TX(1));

% %-----------FOR PCI-------------------------------------------------------%
% %Transmit Apod set to zero
txFocus = 0;        % focal distance in wavelengths (0 means plane wave transmit)
TX(2).waveform = 2;
TX(2).Origin = [0,0,0];            % set origin to 0,0,0 for flat focus.
TX(2).focus = txFocus;     % set focus to negative for concave TX.Delay profile.
TX(2).Steer = [0,0];
TX(2).Apod = zeros(1,Trans.numelements);  % set TX.Apod to zero to turn off transmit
TX(2).Delay = zeros(1,Trans.numelements);

% %----------FOR PRE BMODE--------------------------------------------------%
% uf?
PRETX = repmat(struct('waveform', 3, ...
                   'Origin', [0.0,0.0,0.0], ...
                   'focus', P.txFocus, ...
                   'Steer', [0.0,0.0], ...
                   'Apod', zeros(1,Trans.numelements), ...
                   'Delay', zeros(1,Trans.numelements)), 1, P.numRays);
               
for n = 1:P.numRays   % numRays transmit events
    PRETX(n).waveform = 3;  % Set transmit waveform
    % Set transmit Origins.
    PRETX(n).Origin = [radius*sin(Angle(n)), 0.0, radius*cos(Angle(n))-radius];
    ce = round(1+127*(Angle(n) - theta)/(-2*theta));
    % Set transmit Apodization so that a maximum of numTx + 1 transmitters are active.
    lft = round(ce - P.numTx/2);
    if lft < 1, lft = 1; end
    rt = round(ce + P.numTx/2);
    if rt > Trans.numelements, rt = Trans.numelements; end
    PRETX(n).Apod(lft:rt) = 1.0;
    PRETX(n).Delay = computeTXDelays(PRETX(n));
end


TX = [TX PRETX];

% Specify TGC Waveform structure.
TGC(1).CntrlPts = [153,308,410,520,605,665,705,760];
TGC(1).rangeMax = P.endDepth;
TGC(1).Waveform = computeTGCWaveform(TGC(1));

% %-----------FOR PCI-----------------------------------------------------%
FlatTGCPCI = 50; % Need to confirm if this TGC allows sufficent gain without clipping
TGC(2).CntrlPts = [FlatTGCPCI; FlatTGCPCI; FlatTGCPCI; FlatTGCPCI; FlatTGCPCI; FlatTGCPCI; FlatTGCPCI; FlatTGCPCI];
TGC(2).rangeMax = P.endDepth;
TGC(2).Waveform = computeTGCWaveform(TGC(2));

% %----------FOR PRE BMODE--------------------------------------------------%
TGC(3).CntrlPts = [153,308,410,520,605,665,705,760];
TGC(3).rangeMax = P.endDepth;
TGC(3).Waveform = computeTGCWaveform(TGC(3));

%% ----------------------RECEIVE STRUCTURE ARRAYS--------------------------
% Specify Receive structure arrays.
% UF 
% -- Compute the maximum receive path length, using the law of cosines.
maxAcqLength = ceil(sqrt((P.endDepth+radius)^2 + radius^2 - ...
                     2*(P.endDepth+radius)*radius*cos(scanangle)));
Receive1 = repmat(struct('Apod', ones(1,Trans.numelements),'startDepth', P.startDepth, ...
                        'endDepth', maxAcqLength, ...
                        'TGC', 1, ...
                        'bufnum', 3, ...
                        'framenum', 1, ...
                        'acqNum', 1, ...
                        'sampleMode', 'NS200BW', ...
                         'mode', 0, ...
                        'callMediaFunc', 1), 1, P.numFrames*P.numAcqs); %Resource.RcvBuffer(1).numFrames);
                    
                    
% - Set event specific Receive attributes for each frame.
for i = 1:Resource.RcvBuffer(3).numFrames
    for j = 1:P.numAcqs
        % -- Acquisitions for 'super' frame.
        rcvNum = P.numAcqs*(i-1) + j;
        Receive1(rcvNum).Apod(:)=1; 
        Receive1(rcvNum).framenum = i;
        Receive1(rcvNum).acqNum = j;
        
%         if floor((j-0)/3) ~= (j-0)/3
%             Receive1(rcvNum).TGC = 4;
%         end
    end
end

N_BMD_Receive=size(Receive1,2);

% %-----------FOR PCI-------------------------------------------------------%
% % the bubble cloud center is seen at 30 mm on a b-mode image, the
% % transducer focus is at 75 mm. (75+30)/(1.54/6.25)/2 = flighttime - 70 is the required
% % wavelength
fDEPTH = 80;    %[mm] Histotripsy focal depth
flighttime = round((fDEPTH+target_depth)/2/wls2mm);
Receive2 = repmat(struct('Apod', ones(1,Trans.numelements), ...
    'startDepth', flighttime - 70, ... % Need to adjust this for TOF (e.g. trigger delay). Software assumes out an back, so end depth is half of total record time.Need to adjust this for TOF (e.g. trigger delay)
    'endDepth', flighttime + 80, ...   % Software assumes out an back, so end depth is half of total record time.Need to adjust this for TOF (e.g. trigger delay)
    'TGC', 2, ...
    'bufnum', 2, ...
    'framenum', 1, ...
    'acqNum', 1, ...
    'sampleMode', 'NS200BW', ...
    'mode', 0, ...
    'callMediaFunc',1),1,Resource.RcvBuffer(2).numFrames);

% - Set event specific Receive attributes.
for i = 1:Resource.RcvBuffer(2).numFrames
    Receive2(i).framenum = i;
end

N_PCI_Receive = size(Receive2,2);

% % ------------------------PRE BMODE--------------------------------------%
% % Specify Receive structure arrays -
% %   endDepth - add additional acquisition depth to account for some channels
% %              having longer path lengths.
maxAcqLength = ceil(sqrt((P.endDepth+radius)^2 + radius^2 - 2*(P.endDepth+radius)*radius*cos(scanangle)));
Receive3 = repmat(struct('Apod', ones(1,Trans.numelements), ...
    'startDepth', P.startDepth, ...
    'endDepth', maxAcqLength,...
    'TGC', 3, ...
    'bufnum', 1, ...
    'framenum', 1, ...
    'acqNum', 1, ...
    'sampleMode', 'NS200BW', ...
    'mode', 0, ...
    'callMediaFunc', 0),1, P.numRays*Resource.RcvBuffer(1).numFrames);
% - Set event specific Receive attributes.
for i = 1:Resource.RcvBuffer(3).numFrames
    Receive3(P.numRays*(i-1)+1).callMediaFunc = 1;
    for j = 1:P.numRays
        Receive3(P.numRays*(i-1)+j).framenum = i;
        Receive3(P.numRays*(i-1)+j).acqNum = j;
    end
end
N_PREBMD_Receive = size(Receive3, 2);


Receive=[Receive1 Receive2 Receive3];

%% ----------------------RECON STRUCTURE ARRAYS-------------------------
% Specify Recon structure arrays.
% - We need one Recon structure which will be used for each frame.

% % Specify Recon structure arrays.
% Recon(1) = struct('senscutoff', 0.6, ...
%                'pdatanum', 1, ...
%                'rcvBufFrame', -1, ...     % use most recently transferred frame
%                'IntBufDest', [1,1], ...
%                'ImgBufDest', [1,-1], ...  % auto-increment ImageBuffer each recon
%                'RINums', 1);
% 
% % Define ReconInfo structures.  (just one ReconInfo to process one acquisition per superframe)
% ReconInfo(1) = struct('mode', 'replaceIntensity', ...
%                    'txnum', 1, ...
%                    'rcvnum', 1, ...  % use the first acquisition of each frame
%                    'regionnum', 1);

% % Specify Recon structure arrays.
Recon(1) = struct('senscutoff', 0.6, ...
               'pdatanum', 2, ...
               'rcvBufFrame', -1, ...     % use most recently transferred frame
               'IntBufDest', [1,1], ...    
               'ImgBufDest', [1,-1], ...  % auto-increment ImageBuffer each recon
               'RINums', 1:(P.numRays+0));

% - Set specific ReconInfo attributes.
for i = 1:P.numRays
    ReconInfo(i+0) = struct('mode', 'replaceIntensity', ...
        'txnum', i+2, ...
        'rcvnum', N_BMD_Receive+N_PCI_Receive+i, ...
        'regionnum', i);
end
%% ------------------------------PROCESSESS-----------------------------------
% Specify Process structure array.
pers = 30;
Process(1).classname = 'Image';
Process(1).method = 'imageDisplay';
Process(1).Parameters = {'imgbufnum',1,...   % number of buffer to process.
                         'framenum',-1,...   % (-1 => lastFrame)
                         'pdatanum',2,...    % number of PData structure to use
                         'pgain',1.0,...            % pgain is image processing gain
                         'reject',2,...      % reject level
                         'persistMethod','simple',...
                         'persistLevel',pers,...
                         'interpMethod','4pt',...
                         'grainRemoval','none',...
                         'processMethod','none',...
                         'averageMethod','none',...
                         'compressMethod','power',...
                         'compressFactor',40,...
                         'mappingMethod','full',...
                         'display',1,...      % display image after processing
                         'displayWindow',1};

% External Process to save Pre B-Mode data
Process(2).classname = 'External';      % This process is an externally defined process
Process(2).method = 'saveData';
Process(2).Parameters = {'srcbuffer','image',... % name of buffer to process.
    'srcbufnum',1,...
    'srcframenum',0,...         % '0' --> Process all frames. '-1' --> Process most recent frame
    'dstbuffer','none'};

% External Process to save PCI data
Process(3).classname = 'External';
Process(3).method = 'pciData';
Process(3).Parameters = {'srcbuffer','receive',...
    'srcbufnum',2,...
    'srcframenum',0,...
    'dstbuffer','none'};

% External Process to save UF data
Process(4).classname = 'External';
Process(4).method = 'ufData';
Process(4).Parameters = {'srcbuffer','receive',...
    'srcbufnum',3,...
    'srcframenum',0,...
    'dstbuffer','none'};


%% ---------------------------SEQCONTROL-----------------------------------
%Specify SeqControl structyure arrays.
SeqControl(1).command = 'jump'; % jump back to start
SeqControl(1).argument = 1;
SeqControl(2).command = 'timeToNextAcq';  % time between synthetic aperture acquisitions
SeqControl(2).argument = 250;  % 290 usec
SeqControl(3).command = 'timeToNextAcq';  % time between frames
SeqControl(3).argument = 500;  % 1 msec
SeqControl(4).command = 'returnToMatlab';
SeqControl(5).command = 'pause';        % Pause for external trigger in, note that Resource.VDAS.dmaTimeout should be set to an appropriate value.
SeqControl(5).condition = 'extTrigger'; % Specify Ext Trigger in
SeqControl(5).argument = 17;            % External Trigger will be on input 1 with a rising edge.
% SeqControl(6).command = 'sync';         % Pause the hardware sequencer until the software processing in this Event is completed
% SeqControl(6).argument = 2.14e9;        % 10 sec timeout for software sequencer (default is 0.5 seconds)
% SeqControl(7).command = 'loopCnt';
% SeqControl(7).argument = nset-1;

% % - Jump back to start of accumulate.
% SeqControl(8).command = 'loopTst';
% SeqControl(8).argument = [];

% - Transfer data frame to host.
% SeqControl(9).command = 'noop';         % Do nothing, but wait for 200ns * number in argument
% SeqControl(9).argument = 5e3;

SeqControl(6).command = 'timeToNextAcq';
SeqControl(6).argument = round(4*maxAcqLength/Trans.frequency);%250;
SeqControl(7).command = 'sync';         % Pause the hardware sequencer until the software processing in this Event is completed
SeqControl(7).argument = 2.14e9;        % 10 sec timeout for software sequencer (default is 0.5 seconds)


nsc = length(SeqControl)+1; % nsc is count of SeqControl objects

%% ---------------------------EVENTS----------------------------------------
% Specify Event structure arrays.
n = 1;

% % A priori B-mode data
for i = 1:Resource.RcvBuffer(1).numFrames
    for j = 1:P.numRays                      % Acquire frame
        Event(n).info = 'Aqcuisition.';
        Event(n).tx = j+2;   % use next TX structure.
        Event(n).rcv =  N_BMD_Receive+N_PCI_Receive + P.numRays*(i-1)+j;
        Event(n).recon = 0;      % no reconstruction.
        Event(n).process = 0;    % no processing
        Event(n).seqControl = 6; % seqCntrl
        n = n+1;
    end
    % Replace last events SeqControl for inter-frame timeToNextAcq.
    Event(n-1).seqControl = 3;
    
    
    Event(n).info = 'Transfer frame to host.';
    Event(n).tx = 0;        % no TX
    Event(n).rcv = 0;       % no Rcv
    Event(n).recon = 0;     % no Recon
    Event(n).process = 0;
    Event(n).seqControl = nsc;
        SeqControl(nsc).command = 'transferToHost'; % transfer frame to host buffer
        nsc = nsc+1;
    n = n+1;
    
    Event(n).info = 'recon and process';
    Event(n).tx = 0;         % no transmit
    Event(n).rcv = 0;        % no rcv
    Event(n).recon = 1;      % reconstruction
    Event(n).process = 1;    
    Event(n).seqControl = 0;
    if (floor(i/5) == i/5)&&(i ~= Resource.RcvBuffer(1).numFrames)  % Exit to Matlab every 5th frame
        Event(n).seqControl = 4; % return to Matlab
    end
    n = n+1;
end

% PCI Data 
for i = 1:Resource.RcvBuffer(2).numFrames                     % Acquire frame
     Event(n).info = 'Pause for Ext Trigger then Acquire RF Data, then start Transfer of Data';
     Event(n).tx = 2;
     Event(n).rcv = i+N_BMD_Receive;
     Event(n).recon = 0;
     Event(n).process = 0;
     Event(n).seqControl = [5, 7, nsc, 3];
         SeqControl(nsc).command = 'transferToHost';
         nsc = nsc + 1;  % index for SeqControl
         n = n+1;
     
      Event(n).info = 'Pause until RF data is transferred.'; % Not sure if this is necessary
      Event(n).tx = 0;            % no TX structure.
      Event(n).rcv = 0;           % no Rcv structure.
      Event(n).recon = 0;         % no reconstruction.
      Event(n).process = 0;       % call processing function
      Event(n).seqControl = nsc;    % after running the process, now execute Sequence Control to wait for transfer to finish
      SeqControl(nsc).command = 'waitForTransferComplete';  % Wait for transfer to host to finish before allowing any processing
      SeqControl(nsc).argument = nsc-1;         % The arguement for waitForTransferComplete should reference the previous 'transferToHost' command.
      nsc=nsc+1;
      n=n+1;
      
      if i == Resource.RcvBuffer(2).numFrames 
          %UF
          for ui = 1:P.numAcqs
              Event(n).info = 'Full aperture.';
              Event(n).tx = 1;
              Event(n).rcv = ui;
              Event(n).recon = 0;
              Event(n).process = 0;
              Event(n).seqControl = 3;
              n = n+1;
          end
              
          % Set last acquisitions SeqControl for transferToHost.
          Event(n-1).seqControl = [nsc];
          SeqControl(nsc).command = 'transferToHost'; % transfer all acqs in one super frame
          nsc = nsc + 1;
      end
      
end
              
Event(n).info = 'Save PCI'; % Event to run external function for NN
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 3; % run 'ProcBmode_no_US.m'
Event(n).seqControl = 0;
n=n+1;

Event(n).info = 'Save Entire Pre Bmode Receive Buffer to mat file'; % Event to save Bmode
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 2; % run 'ProcBmode_no_US.m'
Event(n).seqControl = 0;
n=n+1;

Event(n).info = 'Save Entire UF Receive Buffer to mat file'; % Event to save Bmode
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 4; % run 'ProcBmode_no_US.m'
Event(n).seqControl = 0;
n=n+1;


Event(n).info = 'Jump back';
Event(n).tx = 0;        % no TX
Event(n).rcv = 0;       % no Rcv
Event(n).recon = 0;     % no Recon
Event(n).process = 0;
Event(n).seqControl = 1;

%% User specified UI Control Elements

import vsv.seq.uicontrol.VsSliderControl

% - Sensitivity Cutoff
UI(1).Control = VsSliderControl('LocationCode','UserB7',...
    'Label','Sens. Cutoff',...
    'SliderMinMaxVal',[0,1.0,Recon(1).senscutoff],...
    'SliderStep',[0.025,0.1],'ValueFormat','%1.3f',...
    'Callback',@SensCutoffCallback);

% - Range Change
wls2mm = 1;
AxesUnit = 'wls';
if isfield(Resource.DisplayWindow(1),'AxesUnits')&&~isempty(Resource.DisplayWindow(1).AxesUnits)
    if strcmp(Resource.DisplayWindow(1).AxesUnits,'mm')
        AxesUnit = 'mm';
        wls2mm = Resource.Parameters.speedOfSound/1000/Trans.frequency;
    end
end
UI(2).Control = VsSliderControl('LocationCode','UserA1',...
    'Label',['Range (',AxesUnit,')'],...
    'SliderMinMaxVal',[64,300,P.endDepth]*wls2mm,...
    'SliderStep',[0.1,0.2],'ValueFormat','%3.0f',...
    'Callback',@RangeChangeCallback);

% - Transmit focus change
UI(3).Control = VsSliderControl('LocationCode','UserB4',...
    'Label',['TX Focus (',AxesUnit,')'],...
    'SliderMinMaxVal',[50,300,P.txFocus]*wls2mm,...
    'SliderStep',[10/250,20/250],'ValueFormat','%3.0f',...
    'Callback',@TxFocusCallback);

% - F number change
UI(4).Control = VsSliderControl('LocationCode','UserB3',...
    'Label','F Number',...
    'SliderMinMaxVal',[0.8,20,round(P.txFocus/(P.numTx*Trans.spacing))],...
    'SliderStep',[0.05,0.1],'ValueFormat','%2.1f',...
    'Callback',@FNumCallback);

savedata = false;
UI(5).Control = {'UserC4', 'Style', 'VsPushButton', 'Label', 'Save Image'};
UI(5).Callback = {'assignin(''base'',''savedata'',true);'};

% PCI label
pcidata = false;
%ufdata  = false;
%UI(11).Control = {'UserB5', 'Style', 'VsPushButton', 'Label', 'PCI'};
UI(6).Control = {'UserB5', 'Style', 'VsToggleButton', 'Label', 'PCI/UF'};
%UI(11).Callback = {'assignin(''base'',''pcidata'',true);'};
UI(6).Callback = {'assignin(''base'',''pcidata'',UIState);'};
% 

% %% ----------------External Function References-----------------------
% % Save the external functions defined in this file
% EF(1).Function = text2cell('%-EF#1');
% EF(2).Function = text2cell('%-EF#2');
% EF(3).Function = text2cell('%-EF#3');
% % Specify factor for converting sequenceRate to frameRate.
% frameRateFactor = 5;
% 
% % Save all the structures to a .mat file.
% save(sprintf('C:\\Users\\verasonics\\Documents\\Vantage-4.5.3-2107301223\\MatFiles\\%s',filename));
% disp([ mfilename ': NOTE -- Running VSX automatically!']), disp(' ')
% 
% VSX
% % commandwindow  % just makes the Command window active to show printout
% 
% return


%% ----------------External Function References----------------------- v2
for n = 1 %:3
    EF(n).Function = text2cell(['%-EF#' num2str(n)]);
end

% Specify factor for converting sequenceRate to frameRate.
frameRateFactor = 5;

% Save all the structures to a .mat file.
save(sprintf('C:\\Users\\verasonics\\Documents\\Vantage-4.5.3-2107301223\\MatFiles\\%s',filename));

disp([ mfilename ': NOTE -- Running VSX automatically!']), disp(' ')

VSX
% commandwindow  % just makes the Command window active to show printout

return

%% External functions with process object

%-EF#1
saveData(RData)
global bmode_count


savedata = evalin('base', 'savedata');
if savedata 
    if isempty(bmode_count)
        bmode_count = 1;
    else
%         while bmode_count <= 10
        bmode_count = bmode_count + 1;
%         end 
    end
%     ProcSave_Bmode_no_US(RData)
    patient = evalin('base', 'patient');
    ProcSave_Bmode_Mice_2023Nov15(RData, patient, bmode_count)
    assignin('base','savedata', false);
end
return
%-EF#1

%-EF#2
pciData(RData)
global pci_count

pcidata = evalin('base', 'pcidata');
nskip   = evalin('base', 'nskip');
if pcidata
    if isempty(pci_count)
        pci_count = 1;
    else
%         while pci_count <= 10
        pci_count = pci_count + 1;
%         end
    end
    
    if mod(pci_count, nskip) == 0
        patient = evalin('base', 'patient');
        ProcSave_PCI_Mice_2023Nov15(RData, patient, pci_count/nskip)
        assignin('base','savedata', true);
    end
else
    %assignin('base','pcidata', false);
    return
    %assignin('base','savedata', true);
    %assignin('base','ufdata', true);
end
return
%-EF#2

%-EF#3
ufData(RData)
global uf_count

pcidata = evalin('base', 'pcidata');
nskip   = evalin('base', 'nskip');
if pcidata
    if isempty(uf_count)
        uf_count = 1;
    else
%         while uf_count <= 10
        uf_count = uf_count + 1;
%         end
    end
    
    if mod(uf_count, nskip) == 0
        patient = evalin('base', 'patient');
        % Need to update this function
        ProcSave_UF_Mice_2023Nov15(RData, patient, uf_count/nskip)
   end
else
    assignin('base','pcidata', false);
    return
    %assignin('base','pcidata', false);
end
return
%-EF#3

%% **** Callback routines used by UIControls (UI) ****

function SensCutoffCallback(~, ~, UIValue)
    ReconL = evalin('base', 'Recon');
    for i = 1:size(ReconL,2)
        ReconL(i).senscutoff = UIValue;
    end
    assignin('base','Recon',ReconL);
    Control = evalin('base','Control');
    Control.Command = 'update&Run';
    Control.Parameters = {'Recon'};
    assignin('base','Control', Control);
end

function RangeChangeCallback(hObject, ~, UIValue)
    simMode = evalin('base','Resource.Parameters.simulateMode');
    % No range change if in simulate mode 2.
    if simMode == 2
        set(hObject,'Value',evalin('base','P.endDepth'));
        return
    end
    Trans = evalin('base','Trans');
    Resource = evalin('base','Resource');
    scaleToWvl = Trans.frequency/(Resource.Parameters.speedOfSound/1000);

    P = evalin('base','P');
    P.endDepth = UIValue;
    if isfield(Resource.DisplayWindow(1),'AxesUnits')&&~isempty(Resource.DisplayWindow(1).AxesUnits)
        if strcmp(Resource.DisplayWindow(1).AxesUnits,'mm')
            P.endDepth = UIValue*scaleToWvl;
        end
    end
    assignin('base','P',P);

    scanangle = evalin('base','scanangle');
    radius = evalin('base','radius');
    theta = evalin('base','theta');
    dtheta = -2*theta/P.numRays;
    Angle = theta:dtheta:(-theta);
    height = P.endDepth + radius - (radius*cos(scanangle/2));
    % Modify PData for new range
    PData = evalin('base','PData');
    PData(1).Size(1) = 10+ceil(height/PData(1).PDelta(3));
    for j = 1:P.numRays
        PData(1).Region(j).Shape = struct( ...
                           'Name','Sector',...
                           'Position',[0,0,-radius],...
                           'r1',radius+P.startDepth,...
                           'r2',radius+P.endDepth,...
                           'angle',dtheta,...
                           'steer',Angle(j));
        PData(1).Region(j).PixelsLA = [];
        PData(1).Region(j).numPixels = 0;
    end
    assignin('base','PData',PData);
    evalin('base','PData(1).Region = computeRegions(PData(1));');
    evalin('base','Resource.DisplayWindow(1).Position(4) = ceil(PData(1).Size(1)*PData(1).PDelta(3)/Resource.DisplayWindow(1).pdelta);');
    Receive = evalin('base', 'Receive');
    maxAcqLength = ceil(sqrt((P.endDepth+radius)^2 + radius^2 - 2*(P.endDepth+radius)*radius*cos(scanangle)));
    for i = 1:size(Receive,2)
        Receive(i).endDepth = maxAcqLength;
    end
    assignin('base','Receive',Receive);
    evalin('base','TGC.rangeMax = P.endDepth;');
    evalin('base','TGC.Waveform = computeTGCWaveform(TGC);');
    Control = evalin('base','Control');
    Control.Command = 'update&Run';
    Control.Parameters = {'PData','InterBuffer','ImageBuffer','Receive','TGC','Recon','DisplayWindow'};
    assignin('base','Control', Control);
    assignin('base', 'action', 'displayChange');
end

function TxFocusCallback(hObject, ~, UIValue)
    simMode = evalin('base','Resource.Parameters.simulateMode');
    % No focus change if in simulate mode 2.
    if simMode == 2
        set(hObject,'Value',evalin('base','P.txFocus'));
        return
    end
    Trans = evalin('base','Trans');
    Resource = evalin('base','Resource');
    scaleToWvl = Trans.frequency/(Resource.Parameters.speedOfSound/1000);

    P = evalin('base','P');
    P.txFocus = UIValue;
    if isfield(Resource.DisplayWindow(1),'AxesUnits')&&~isempty(Resource.DisplayWindow(1).AxesUnits)
        if strcmp(Resource.DisplayWindow(1).AxesUnits,'mm')
            P.txFocus = UIValue*scaleToWvl;
        end
    end
    assignin('base','P',P);

    TX = evalin('base', 'TX');
    for n = 1:128   % 128 transmit events
        TX(n).focus = P.txFocus;
        TX(n).Delay = computeTXDelays(TX(n));
    end
    assignin('base','TX', TX);
    % Update Fnumber based on new txFocus
    evalin('base','set(UI(4).handle(2),''Value'',round(P.txFocus/(P.numTx*Trans.spacing)));');
    evalin('base','set(UI(4).handle(3),''String'',num2str(round(P.txFocus/(P.numTx*Trans.spacing)),''%2.1f''));');
    Control = evalin('base','Control');
    Control.Command = 'update&Run';
    Control.Parameters = {'TX'};
    assignin('base','Control', Control);
end

function FNumCallback(hObject, ~, UIValue)
    simMode = evalin('base','Resource.Parameters.simulateMode');
    P = evalin('base','P');
    Trans = evalin('base','Trans');
    % No F number change if in simulate mode 2.
    if simMode == 2
        set(hObject,'Value',round(P.txFocus/(P.numTx*Trans.spacing)));
        return
    end
    txFNum = UIValue;
    P.numTx = round(P.txFocus/(txFNum*Trans.spacing));
    radius = Trans.radius;
    scanangle = Trans.numelements*Trans.spacing/radius;
    dtheta = scanangle/P.numRays;
    theta = -(scanangle/2) + 0.5*dtheta; % angle to left edge from centerline
    Angle = theta:dtheta:(-theta);
    % - Redefine event specific TX attributes for the new numTx.
    TX = evalin('base', 'TX');
    for n = 1:P.numRays  % numRays transmit events
        TX(n).waveform = 1;
        % Set transmit Origins.
        TX(n).Origin = [radius*sin(Angle(n)), 0.0, radius*cos(Angle(n))-radius];
        ce = round(1+127*(Angle(n) - theta)/(-2*theta));
        % Set transmit Apodization so that a maximum of numTx + 1 transmitters are active.
        lft = round(ce - P.numTx/2);
        if lft < 1, lft = 1; end
        rt = round(ce + P.numTx/2);
        if rt > Trans.numelements, rt = Trans.numelements; end
        TX(n).Apod = zeros(1,128);
        TX(n).Apod(lft:rt) = 1.0;
        TX(n).Delay = computeTXDelays(TX(n));
    end
    assignin('base','TX', TX);
    Control = evalin('base','Control');
    Control.Command = 'update&Run';
    Control.Parameters = {'TX'};
    assignin('base','Control', Control);
end