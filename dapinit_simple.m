%% dapsinit_simple.m %%
%
% This simplified script shows the essential steps to establish
% communications with a DAP board. One connection is opened to the
% 'command text' channel for sending commands or script files. One
% connection is opened to the 'binary output' channel for receiving
% digitized data. 
%
% Optional: remove all past variables from Matlab workspace
clear;

% Open a handle to the 'text input to DAP' communication pipe
texthandle = dapopen('\\.\Dap0\$SysIn', 'write')
if texthandle == 0
   error('Error opening DAP input command text handle')
end

% Open a handle to the 'binary data output from DAP' communication pipe
binaryhandle = dapopen('\\.\Dap0\$BinOut', 'read')
if binaryhandle == 0
   error('Error opening DAP binary output handle')
end

% Stop any extraneous activity that happens to be running
dappstr(texthandle, 'reset');

% Flush any extraneous data that happens to be buffered in the host
dapflshi(binaryhandle);	
