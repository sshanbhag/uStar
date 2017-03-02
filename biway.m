%% biway.m %%
% This example script simulates stimulus-response activity. It writes 
% a matrix of 'stimulus' data to the DAP board. The downloaded data is
% combined with other data obtained on the DAP board by filtering an
% input data signal and performing some calculations. The 'response' 
% data is returned back to the application.
% 

dapallopen();

% Configure DAP using DAPL command file BIWAY.DAP
cnfg = dapcnfig(hTextToDap, 'biway.dap');
if cnfg < 1 
  error('Error configuring DAP')
end

% Download the data file for the DAPL configuration to use as 'stimulus'
disp('Downloading the stimulus data')
x=1/300:2*pi/300:6*pi;
stimulus=sin(x)*10000;
dapputm(hBinToDap, stimulus, 'int16');

% Start the DAP board sampling and calculations
dappstr(hTextToDap,'START');

% Ignore "startup transient" for first cycle of 300 points
disp('Collecting the response data')

% Get response for second stimulus cycle of 300 points
response = dapgetm(hBinFromDap, [300, 1], 'int16');

% Compare stimulus and response curves
disp('Plotting stimulus and response curves')
x=1/300:2*pi/300:2*pi;
plot(x,stimulus(1:300),'k', x,response(1:300),'b');
title('Stimulus and response waveforms for one cycle');
ylabel('Amplitude'); xlabel('Radians');
legend('stimulus','response');

% Terminate DAP processing and shut down everything
dappstr(hTextToDap,'STOP');
dapallclose();
