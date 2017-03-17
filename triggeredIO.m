%% triggeredIO.m %%
%
% Test code that 


% max value is 32767
% output range is set to +- 5 V
% input range is set to +/- 10 V
MAXINT = (2^15) - 1;
% 1V -> 3165
% 5V -> 15581
% 10V -> 32767
% V = (X/32768) * F
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% Settings for IO
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% define sample rate from sample interval 
%(specified in stimresp_triggered.dap)
dt = 2e-6;
Fs = 1/dt;
% scaling factor for stimulus
stimamp = MAXINT;
% stimulus duration (ms)
stimdur = 600;
% stimulus delay (ms)
stimdelay = 100;
% stimulus ramp time (ms)
stimramp = 5;
% stimulus frequency (Hz) (will be randomized on each trial)
stimfreq = 100;
% post stim record time (ms)
poststimdur = 100;
% time to record
recorddur = stimdur + stimdelay + poststimdur;
% # of samples to record
recordsamples = 0.001*(recorddur)*Fs;
% time to wait for data (milliseconds)
timewait = 5000;
timeout = 10000;

loadtime = 2*(0.001*stimdur);

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% TDT Setup
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
config.TDTLOCKFILE = fullfile(pwd, 'tdtlockfile.mat');
config.CONFIGNAME = 'RZ5D_TRIGOUT';
[TDT, tdtstatus] = TDTopen(config);
if tdtstatus < 1
	error('could not open TDT');
end
% set the TTL pulse duration to 1 ms
RPsettag(TDT.RZ5, 'TTLPulseDur', ms2bin(1, TDT.RZ5.Fs));
% Send zBUS A pulse to enable circuit
zBUStrigA_PULSE(TDT.zBUS, 0, 4);

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% Initialize DAP
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% open DAP
%	This will create several handles to predefined pipes to communicate
%	with the DAP board:
% 		hTextToDap		command pipe for string commands to DAP
% 							within DAP, this is #SysIn
% 		hTextFromDap	command pipe for messages from DAP
% 							DAPL equivalent is $SysOut
% 		hBinFromDap		binary data delivery pipe from DAP
% 							DAPL equivalent is $BinOut
% 		hBinToDap		binary data pipe to DAP
% 							DAPL equivalend is $BinIn							
%-------------------------------------------------------------------------
dapallopen();

%-------------------------------------------------------------------------
% Configure DAP using DAPL command file stimresp_triggered.dap
%-------------------------------------------------------------------------
cnfg = dapcnfig(hTextToDap, 'stimresp_triggered.dap');
if cnfg < 1 
  error('Error configuring DAP')
end
% test string IO
dappstr(hTextToDap, 'hello');
message = dapgstr(hTextFromDap,250);
fprintf('Message from DAP:\n\t<%s>\n', message);

%-------------------------------------------------------------------------
% get bytes available in DAP memory; should be max amount (or close to it)
%-------------------------------------------------------------------------
nBytes1 = dappavl(hBinToDap);
fprintf('%d bytes available\n', nBytes1)

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% Loop!
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

% initialize loopFlag
loopFlag = true;

while loopFlag
	% Start the DAP board for sampling and calculations
	dappstr(hTextToDap,'START');
	
	% create stimulus (sinusoid with randomized frequency)
	sf = randi(stimfreq*[0.5 2]);
	stimulus = stimamp*sin2array( synmonosine(stimdur, Fs, sf, 1, 0), ...
											stimramp, Fs);
	% add some "clicks" to indicate start and stop of stimulus
	stimulus(1) = stimamp;
	stimulus(end) = -1*stimamp;
	% make sure end of stimulus is 0
	stimulus = [stimulus 0]; %#ok<AGROW>
	% insert delay
	stimulus = insert_delay(stimulus, stimdelay, Fs);
	
	% plot stimulus, response
	figure(100)
	subplot(211)
	plot(stimulus, '.')
	title(sprintf('DAC0 Output, f = %d', sf));
	xlabel('samples')
	
	% Download the data for the DAPL configuration to use as 'stimulus'
	fprintf('Downloading the stimulus data to DAP\n')
	ret = dapputm(hBinToDap, stimulus, 'int16');
	fprintf('%.1f points sent\n', ret);
	% get bytes available
	nBytes2 = dappavl(hBinToDap);
	fprintf('%d bytes available\n', nBytes2)

	% set input count to recordsamples
%  	cmdStr = sprintf('EDIT INDATA COUNT %d', recordsamples);
%  	ret = dappstr(hTextToDap, cmdStr);
%  	fprintf('%s returned: %d\n', cmdStr, ret);
	% pause to allow data transfer
	pause(loadtime)
	
	% Run IO by triggering TDT
	% send trigger pulse
	RPtrig(TDT.RZ5, 1);
	
	% pause
	pause((2*recorddur) * 0.001)

	% Collect data
	fprintf('Collecting the response data\n')
	% Get response
	[response, ret] = dapgetm(hBinFromDap, [1, recordsamples], ...
												'int16', timewait, timeout);
	fprintf('dapgetm returned: %d\n', ret);
	
	% Terminate DAP processing
	dappstr(hTextToDap,'STOP');

	% plot stimulus, response
	figure(100)
	subplot(212)
	plot(response*10/32768, '.-')
	title('S0 Input')
	xlabel('samples')

	% Find onset of stimulus
	onsetbin = min(find(response>1000)); %#ok<MXFND>
	onsetms = bin2ms(onsetbin, Fs);
	fprintf('Stim onset = %s ms (%d samples)\n', onsetms, onsetbin); 
	fprintf('Max value = %d\n', max(response));
	
 	% flush output stream
  	ret = dapflsho(hBinToDap);
 	% flush input stream
  	ret = dapflshi(hBinFromDap);
	
	% continue loop?
	loopFlag = logical(query_user('Continue', 1));
	if loopFlag
		fprintf('continuing IO ...\n')
	else
		fprintf('exiting loop ...\n');
	end
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% Close DAP hardware
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Terminate DAP processing and shut down everything
dappstr(hTextToDap,'STOP');
% check for errors
dappstr(hTextToDap, 'DIPLAY EMSG');
[textFromDap, ret] = dapgstr(hTextFromDap, 100);
fprintf('message:\n\t<%s>\n', textFromDap);
% close all pipes/streams
dapallclose();

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% Close TDT Hardware
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% send zBUS B pulse to stop circuit
zBUStrigB_PULSE(TDT.zBUS, 0, 4);
% close hardware
[TDT, tdtstatus] = TDTclose(config, TDT.RZ5, TDT.zBUS);
if tdtstatus < 1
	error('could not CLOSE TDT');
end

