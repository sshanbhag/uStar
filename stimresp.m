%% stimresp.m %%
% This example script simulates stimulus-response activity. It writes 
% a matrix of 'stimulus' data to the DAP board. The 'response' 
% data is returned back to the application.
% 


% define sample rate from sample interval (specified in stimresp.dap)
dt = 5e-6;
Fs = 1/dt;

stimdur = 1000;

% open DAP
dapallopen();

% Configure DAP using DAPL command file BIWAY.DAP
cnfg = dapcnfig(hTextToDap, 'stimresp.dap');
if cnfg < 1 
  error('Error configuring DAP')
end

% get bytes available
nBytes1 = dappavl(hBinToDap);
fprintf('%d bytes available\n', nBytes1)

% create stimulus
stimulus = 20000*sin2array(synmonosine(stimdur, Fs, 100, 1, 0), 100, Fs);
stimulus(1) = max(stimulus);
stimulus(end) = -1*stimulus(1);
stimulus = [stimulus 0];
% Download the data file for the DAPL configuration to use as 'stimulus'
disp('Downloading the stimulus data')
ret = dapputm(hBinToDap, stimulus, 'int16');
fprintf('%.1f points sent\n', ret);
% get bytes available
nBytes2 = dappavl(hBinToDap);
fprintf('%d bytes available\n', nBytes2)

pause(0.1)

% Start the DAP board sampling and calculations
dappstr(hTextToDap,'START');

% Collect data
disp('Collecting the response data')

% Get response 
timewait = 1100;
timeout = 2000;
response = dapgetm(hBinFromDap, [1, ms2bin(stimdur+100, Fs)], 'int16', timewait, timeout);

% Terminate DAP processing and shut down everything
dappstr(hTextToDap,'STOP');

% close all pipes/streams
dapallclose();

figure(1)
plot(response, '.-')
