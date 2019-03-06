%% play_tone_pulse.m %%
%  based on playwav.m example script from Microstar Labs
%
%------------------------------------------------------------------------
% 6 Mar 2019 (SJS)
%------------------------------------------------------------------------

% output sample rate
Fs = 10000;
% tone parameters
tone_dur = 200;
tone_freq = 100;
tone_ramp = 10;
tone_delay = 100;
tone_amp = 1;
% pulse parameters
pulse_dur = 10;
pulse_delay = 100;
pulse_amp = 1;

tone = synmonosine(tone_dur, Fs, tone_freq, 1, 0, 0);
tone = sin2array(tone, tone_ramp, Fs);
pulse = synmonoclick(tone_dur, Fs, 0, pulse_dur, pulse_amp);
% insert delays, combine into stimulus
tone = insert_delay(tone, tone_delay, Fs);
pulse = insert_delay(pulse, pulse_delay, Fs);
stimdata = [tone; pulse];


stimdata = 0.01*ones(size(stimdata));

% plot signals
t = (1000/Fs) * (0:(length(tone)-1));
figure(1)
subplot(211)
plot(t, stimdata(1, :), 'g');
ylabel('S0 signal')
subplot(212)
plot(t, stimdata(2, :), 'r');
xlabel('Time (ms)')
ylabel('S1 signal')
% information
signal_dur = tone_dur + tone_delay;
fprintf('Signal Duration (s): %.2f\n', signal_dur / 1000);
fprintf('samples/channel: %d\n', length(tone));
fprintf('total samples: %d\n', numel(stimdata));
fprintf('Time between sample updates (us): %.2f\n', (1e6) * (1/Fs) * (1/2));

pause_dur = ceil(0.001 * signal_dur);



%% Prepare the DAP board to receive the data. Script starts automatically.
dapallopen();
cnfg = dapcnfig(hTextToDap, 'play_tone_pulse.dap');
if cnfg < 1
   dapallclose();
   error('Error configuring DAP')
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
