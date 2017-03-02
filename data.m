%% data.m %%
% Use the DAPL data.dap configuration to receive two channels of data,
% one block per second. Count the samples received. Repeat for eight
% seconds, by counting blocks received. Then shut down the processing.
%
clear;
dapallopen();

% Configure DAP 
cnfg = dapcnfig(hTextToDap, 'data.dap');
if cnfg < 1
   error('Error configuring DAP')  % Print error message
end

% Begin processing blocks of data. Expect data to arrive at approximately
% 1 second intervals. Allow about 1.2 seconds to see each data block;
% allow 1.5 second maximum for a transfer cycle to finish. If there are
% any delays longer than these, something bad happened to terminate the
% data stream unexpectedly.
samples = 0;
disp('Receiving data blocks');
for  seconds=1:8
    [datamat, result] = dapgetm(hBinFromDap, [2,500], 'int16', 1200, 1500);
    if  result==0
       disp('Processing terminated abnormally');
       break;
    end
    samples = samples + 1000
end

dappstr(hTextToDap, 'RESET');
dapallclose();