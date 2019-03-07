%% playwav.m %%
%  This script delivers digital data, previously recorded and stored
%  in a WAV file format, to a DAP board where the signal is reconstructed
%  by digital-to-analog converter hardware. Though originally intended 
%  for audio data, the WAV format can also represent any sort of
%  multi-channel digitized data stream.

Nsamps = 10000;
Nchans = 2;
Duration = 5.0;
FName  = 'playwav.wav';

% Load the binary data from the WAVE file and verify data sizes
recdata = wavread(FName);
disp('Loaded WAV file: ')
[samples, channels] = size(recdata)

% Reorganize data in multiplex order (channels alternating)
% samples = samples';
% recdata = recdata';

% Prepare the DAP board to receive the data. Script starts automatically.
dapallopen();
cnfg = dapcnfig(hTextToDap, 'playwav.dap');
if cnfg < 1
   dapallclose();
   error('Error configuring DAP')
end

% Send the data to the DAP board for playback.
disp('Sending the data to the DAP board')
% dapputm(hBinToDap, samples, 'int16');
numSentdapputm(hBinToDap, ones(size(recdata)), 'int16');

% Allow enough time for the playback to finish
disp('Allow 6 seconds for playback')
pause(6);

% Close connections to DAP 
dapallclose();
