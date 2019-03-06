%% playwav.m %%
%  This script delivers digital data, previously recorded and stored
%  in a WAV file format, to a DAP board where the signal is reconstructed
%  by digital-to-analog converter hardware. Though originally intended 
%  for audio data, the WAV format can also represent any sort of
%  multi-channel digitized data stream.
%
%------------------------------------------------------------------------
% 6 Mar 2019 (SJS)
% making some changes in order to test sound output.
%	(1) original "wavread" used to read in wav file is deprecated in MATLAB
%		 2017 - using audioread() instead
%	(2) playwav.wav is stereo, 16 bit, 8kHz sample rate. for some reason, 
%		 playwav.m and playwav.dap use 10kHz sample rate... 
%------------------------------------------------------------------------

Nsamps = 10000;
Nchans = 2;
Duration = 5.0;
FName  = 'playwav.wav';

% Load the file information about WAVE file
Finfo = audioinfo(FName);

% Load the binary data from the WAVE file and verify data sizes
[recdata, Fs] = audioread(FName);
fprintf('WAV File Information: %s\n', FName);
fprintf('\tchannels: %d\n', Finfo.NumChannels);
fprintf('\tsamples: %d\n', Finfo.TotalSamples);
fprintf('\n');
Finfo

[samples, channels] = size(recdata);
% provide info
fprintf('Read data from file: %s\n', FName);
fprintf('\tchannels: %d\n', channels);
fprintf('\tsamples: %d\n', samples);
fprintf('\n\n');

% Reorganize data in multiplex order (channels alternating)
recdata = recdata';
% ramp data on/off
recdata = sin2array(recdata, 100, Fs);
recdata(2, :) = 1;

% plot signals
figure(1)
subplot(211)
plot(recdata(1, :), 'g');
subplot(212)
plot(recdata(2, :), 'r');

%% Prepare the DAP board to receive the data. Script starts automatically.
dapallopen();
cnfg = dapcnfig(hTextToDap, 'playwav.dap');
if cnfg < 1
   dapallclose();
   error('Error configuring DAP')
end

% Send the data to the DAP board for playback.
disp('Sending the data to the DAP board')
dapputm(hBinToDap, recdata, 'int16');

% Allow enough time for the playback to finish
fprintf('Allow %.2f seconds for playback\n', Finfo.Duration);
pause(Finfo.Duration + 0.5);

% Close connections to DAP 
dapallclose();
