%% stimresp.m %%
% This example script simulates stimulus-response activity. It writes 
% a matrix of 'stimulus' data to the DAP board. The 'response' 
% data is returned back to the application.
% 


% define sample rate from sample interval (specified in stimresp.dap)
dt = 5e-6;
Fs = 1/dt;
stimamp = 20000;
stimdur = 100;
stimfreq = 100;
recordsamples = ms2bin(stimdur+100, Fs);

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
cnfg = dapcnfig(hTextToDap, 'stimresp.dap');
if cnfg < 1 
  error('Error configuring DAP')
end

% get bytes available in DAP memory; should be max amount (or close to it)
nBytes1 = dappavl(hBinToDap);
fprintf('%d bytes available\n', nBytes1)

% create stimulus = 
stimulus = stimamp*sin2array( ...
								synmonosine(stimdur, Fs, stimfreq, 1, 0), 5, Fs);
% add some "clicks" to indicate start and stop of stimulus
stimulus(1) = stimamp;
stimulus(end) = -1*stimamp;
% make sure end of stimulus is 0
stimulus = [stimulus 0];
% Download the data file for the DAPL configuration to use as 'stimulus'
disp('Downloading the stimulus data')
ret = dapputm(hBinToDap, stimulus, 'int16');
fprintf('%.1f points sent\n', ret);
% get bytes available
nBytes2 = dappavl(hBinToDap);
fprintf('%d bytes available\n', nBytes2)

pause(1)

% Start the DAP board sampling and calculations
dappstr(hTextToDap,'START');

% Collect data
disp('Collecting the response data')
pause(0.1)
% Get response 
timewait = 1100;
timeout = 2000;
response = dapgetm(hBinFromDap, [1, recordsamples], 'int16', timewait, timeout);

% Terminate DAP processing and shut down everything
dappstr(hTextToDap,'STOP');

% close all pipes/streams
dapallclose();

figure(1)
plot(response, '.-')
