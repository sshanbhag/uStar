%% stimresp.m %%
% This example script simulates stimulus-response activity. It writes 
% a matrix of 'stimulus' data to the DAP board. The 'response' 
% data is returned back to the application.
% 


% define sample rate from sample interval (specified in stimresp.dap)
dt = 2e-6;
Fs = 1/dt;
% scaling factor for stimulus
stimamp = 10000;
% stimulus duration (ms)
stimdur = 100;
% stimulus frequency (Hz)
stimfreq = 100;
% # of samples to record
recordsamples = ms2bin(stimdur+200, Fs);

% time to wait for data (milliseconds)
timewait = 5000;
timeout = 10000;

% open DAP
%	will create several handles to predefined pipes to communicate
%	with the DAP board:
% 		hTextToDap		command pipe for string commands to DAP
% 							within DAP, this is #SysIn
% 		hTextFromDap	command pipe for messages from DAP
% 							DAPL equivalent is $SysOut
% 		hBinFromDap		binary data delivery pipe from DAP
% 							DAPL equivalent is $BinOut
% 		hBinToDap		binary data pipe to DAP
% 							DAPL equivalend is $BinIn							
dapallopen();

% Configure DAP using DAPL command file stimresp.dap
cnfg = dapcnfig(hTextToDap, 'stimresp_triggered.dap');
if cnfg < 1 
  error('Error configuring DAP')
end

% Start the DAP board sampling and calculations
dappstr(hTextToDap,'START');

% get bytes available in DAP memory; should be max amount (or close to it)
nBytes1 = dappavl(hBinToDap);
fprintf('%d bytes available\n', nBytes1)

loopFlag = true;

while loopFlag

	% create stimulus
	sf = randi(stimfreq*[1 2]);
	stimulus = stimamp*sin2array( synmonosine(stimdur, Fs, sf, 1, 0), ...
											5, Fs);
	% add some "clicks" to indicate start and stop of stimulus
	stimulus(1) = stimamp;
	stimulus(end) = -1*stimamp;
	% make sure end of stimulus is 0
	stimulus = [stimulus 0]; %#ok<AGROW>
	
	% plot stimulus, response
	figure(1)
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
% 	cmdStr = sprintf('EDIT INDATA COUNT %d\n', recordsamples);
% 	ret = dappstr(hTextToDap, cmdStr);
% 	fprintf('%s returned: %d\n', cmdStr, ret);
	
	% Collect data
	fprintf('Collecting the response data\n')
	pause(0.1)
	% Get response
	[response, ret] = dapgetm(hBinFromDap, [1, recordsamples], ...
												'int16', timewait, timeout);
	fprintf('dapgetm returned: %d\n', ret);
										

	% plot stimulus, response
	figure(1)
	subplot(212)
	plot(response, '.-')
	title('S0 Input')
	xlabel('samples')

	% Find onset of stimulus
	onsetbin = min(find(response>1000)); %#ok<MXFND>
	onsetms = bin2ms(onsetbin, Fs);
	fprintf('Stim onset = %s ms (%d samples)\n', onsetms, onsetbin); 
	
% 	% flush output stream
 	ret = dapflsho(hBinToDap);
	
	% continue loop?
	loopFlag = logical(query_user('Continue', 1));
end
% Terminate DAP processing and shut down everything
dappstr(hTextToDap,'STOP');

% close all pipes/streams
dapallclose();
