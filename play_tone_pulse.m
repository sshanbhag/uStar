%% play_tone_pulse.m %%
% plays a tone on AO0, pulse on AO1 at sample rate of 10000 Hz.
%  based on playwav.m example script from Microstar Labs
%  using 
%------------------------------------------------------------------------
% 7 Mar 2019 (SJS)
%------------------------------------------------------------------------

%% define some values
% max Analog output range of ustar board
AOMAX = 5;
% max int16 value
MAXINT16 = ( ((2^16)/2) - 1);

%% generate stimuli
% output sample rate
Fs = 250000;
% tone parameters
tone_dur = 200;
tone_freq = 100;
tone_ramp = 10;
tone_delay = 100;
tone_amp = 1;
% pulse parameters
pulse_dur = 10;
pulse_delay = 100;
pulse_amp = 5;
% overall signal duration
signal_dur = tone_dur + tone_delay;

% synthesize raw tone
raw_tone = synmonosine(tone_dur, Fs, tone_freq, 1, 0, 0);
raw_tone = sin2array(raw_tone, tone_ramp, Fs);
% use tone_dur for total pulse stim duration so that they match
raw_pulse = synmonoclick(tone_dur, Fs, 0, pulse_dur, 1);
% insert delays
tone = insert_delay(raw_tone, tone_delay, Fs);
pulse = insert_delay(raw_pulse, pulse_delay, Fs);
% scale and convert to integer
% max output range is +/- 5V, so scale desired amplitudes appropriately
scaled_tone = (tone_amp / AOMAX) * tone;
scaled_pulse = (pulse_amp / AOMAX) * pulse;
scaled_tone = floor(MAXINT16 * scaled_tone);
scaled_pulse = floor(MAXINT16 * scaled_pulse);
% combine into stimulus, samples in columns, channels in rows
stimdata = [scaled_tone; scaled_pulse];

% calculate time in sec to pause while waiting for signal to finish output
pause_dur = ceil(0.001 * signal_dur);

% plot signals
t = (1000/Fs) * (0:(length(tone)-1));
figure(1)
subplot(211)
plot(t, stimdata(1, :), 'g');
ylim(1.05*MAXINT16 * [-1 1])
ylabel('S0 signal')
subplot(212)
plot(t, stimdata(2, :), 'r');
ylim(1.05*MAXINT16 * [-1 1])
xlabel('Time (ms)')
ylabel('S1 signal')
% information
fprintf('Signal Duration (s): %.2f\n', signal_dur / 1000);
fprintf('samples/channel: %d\n', length(tone));
fprintf('total samples: %d\n', numel(stimdata));
fprintf('Time between sample updates (us): %.2f\n', (1e6) * (1/Fs) * (1/2));


%% Play signals

% Prepare the DAP board to receive the data. 
dapallopen();

% %% ?once dapallopen() is run, this portion can be looped for each trial ?
% Script starts automatically.
cnfg = dapcnfig(hTextToDap, 'play_tone_pulse.dap');
if cnfg < 1
   dapallclose();
   error('Error configuring DAP')
end

% Send the data to the DAP board for playback.
disp('Sending the data to the DAP board')
nData = dapputm(hBinToDap, stimdata, 'int16');
fprintf('nData: %d\n', nData);

% Allow enough time for the playback to finish
fprintf('Allow %.2f seconds for playback\n', pause_dur);
pause(pause_dur);

% %% ?end of loopable portion?

% Close connections to DAP 
dapallclose();
