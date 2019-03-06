%% play_tone.m %%
%  based on playwav.m example script from Microstar Labs
%
%------------------------------------------------------------------------
% 6 Mar 2019 (SJS)
%------------------------------------------------------------------------

% output sample rate
Fs = 10000;
% tone parameters
tone_dur = 200;	% milliseconds
tone_freq = 100;	% Hz
tone_ramp = 10;	% milliseconds
tone_delay = 100; % milliseconds
tone_amp = 1;		% Volts

% Create tone

% generate time vector
tvec = (1/Fs)*(0:((Fs * 0.001 * tone_dur)-1));
% convert to angular frequency
omega = 2 * pi * tone_freq;
% create sinusoid
tone = tone_amp * sin(omega * tvec);
% ramp tone on/off to avoid clicks
rampbins = floor(Fs * tone_ramp / 1000);
ramp1 = sin(linspace(0, pi/2, rampbins)).^2;
ramp2 = fliplr(ramp1);
n = length(tone);
tone = [(ramp1 .* tone(1, 1:rampbins)) ...
		tone(1, rampbins + 1:n - rampbins) ...
		(ramp2 .* tone(1, n-rampbins+1:n))];
% insert delay
tone = [zeros(1, ceil(Fs * tone_delay / 1000)) tone];

% plot signal
t = (1000/Fs) * (0:(length(tone)-1));
figure(1)
plot(t, tone);
xlabel('Time (ms)')
ylabel('S0 signal')
% information
signal_dur = tone_dur + tone_delay;
fprintf('Signal Duration (s): %.2f\n', signal_dur / 1000);
fprintf('samples/channel: %d\n', length(tone));
fprintf('total samples: %d\n', numel(tone));
fprintf('Time between sample updates (us): %.2f\n', (1e6) * (1/Fs) * (1/2));

pause_dur = ceil(0.001 * signal_dur);

%% Prepare the DAP board to receive the data. Script starts automatically.
dapallopen();
cnfg = dapcnfig(hTextToDap, 'play_tone.dap');
if cnfg < 1
   dapallclose();
   error('Error configuring DAP')
end

% Send the data to the DAP board for playback.
disp('Sending the data to the DAP board')
nData = dapputm(hBinToDap, tone, 'double');
fprintf('nData: %d\n', nData);

% Allow enough time for the playback to finish
fprintf('Allow %.2f seconds for playback\n', pause_dur);
pause(pause_dur);

% Close connections to DAP 
dapallclose();
