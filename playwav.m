%% playwav.m %%
%  This script delivers digital data, previously recorded and stored
%  in a WAV file format, to a DAP board where the signal is reconstructed
%  by digital-to-analog converter hardware. Though originally intended 
%  for audio data, the WAV format can also represent any sort of
%  multi-channel digitized data stream.
%-----------------------------------------------------------------------
% 7 March 2019, S. Shanbhag
% modified to test.

AOMAX = 5;
Nsamps = 10000;
Nchans = 2;
Duration = 5.0;
FName  = 'playwav.wav';

% Load the file information about WAVE file
% recdata = wavread(FName);  original code - wavread no longer supported or
% is deprecated in Matlab r2017a
Finfo = audioinfo(FName);
disp(Finfo);
% Load the binary data from the WAVE file and verify data sizes
[rawdata, Fs] = audioread(FName);
% provide info
[samples, channels] = size(rawdata);
fprintf('Read data from file: %s\n', FName);
fprintf('\tchannels: %d\n', channels);
fprintf('\tsamples: %d\n', samples);
fprintf('\n\n');

% keep 50000 per channel and set first and last sample values to 0
outdata = rawdata(1:50000, :);
outdata(1, :) = 0 * outdata(1, :);
outdata(end, :) = 0 * outdata(end, :);

% scale to range +/- 32767 (max int 16 value)
outdata = floor(32767 * outdata);

% Reorganize data in multiplex order (channels alternating)
% samples = samples';
outdata = outdata';

% Prepare the DAP board to receive the data. Script starts automatically.
dapallopen();
cnfg = dapcnfig(hTextToDap, 'playwav.dap');
if cnfg < 1
   dapallclose();
   error('Error configuring DAP')
end

% Send the data to the DAP board for playback.
disp('Sending the data to the DAP board')
numSent = dapputm(hBinToDap, outdata, 'int16');
fprintf('Sent %d \n', numSent);

qResult = dapquery(hBinToDap, 'DapDiskIoStatus');
disp(qResult)
% “DaplOutputCount [target=<configuration list>|*]”

% Allow enough time for the playback to finish
disp('Allow 6 seconds for playback')
pause(6);

% Close connections to DAP 
dapallclose();
