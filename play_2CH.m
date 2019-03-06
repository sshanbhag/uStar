%% play_2CH.m %%
%  based on playwav.m example script from Microstar Labs
%
%------------------------------------------------------------------------
% 6 Mar 2019 (SJS)
%------------------------------------------------------------------------

% output sample rate
Fs = 10000;
% total output duration (seconds)
sigdur = 0.1;
% signal amplitudes (peak, V)
ch0peak = 1;
ch1peak = 0.5;

% stimulus channel 1 = noise, range [-1 1]
ch0signal = 2 * (rand(1, floor(Fs * sigdur)) - 0.5);
ch0signal = ch0peak * ch0signal;

% stimulus channel 2 = 0.01 second pulse, peak of 1, start at t=0
ch1signal = zeros(1, floor(Fs * sigdur));
pulseIndx = 1:(floor(Fs*0.01)+1);
ch1signal(pulseIndx) = ch1peak;

stimdata = [ch0signal; ch1signal];

% plot signals
t = (1000/Fs) * (0:(length(stimdata)-1));
figure(1)
subplot(211)
plot(t, stimdata(1, :), 'g');
ylabel('S0 signal')
subplot(212)
plot(t, stimdata(2, :), 'r');
xlabel('Time (ms)')
ylabel('S1 signal')
% information
fprintf('Signal Duration (s): %.2f\n', sigdur);
fprintf('samples/channel: %d\n', length(stimdata));
fprintf('total samples: %d\n', numel(stimdata));
fprintf('Time between sample updates (us): %.2f\n', (1e6) * (1/Fs) * (1/2));
pause_dur = ceil(sigdur);


%% Prepare the DAP board to receive the data. Script starts automatically.
dapallopen();
cnfg = dapcnfig(hTextToDap, 'play_2CH.dap');
if cnfg < 1
   dapallclose();
   error('Error configuring DAP')
else
	disp(cnfg)
end

% Send the data to the DAP board for playback.
disp('Sending the data to the DAP board')
nData = dapputm(hBinToDap, stimdata, 'double');
fprintf('nData: %d\n', nData);

% Allow enough time for the playback to finish
fprintf('Allow %.2f seconds for playback\n', pause_dur);
pause(pause_dur);

% Close connections to DAP 
dapallclose();
