%% dapstop_simple.m %%
%
% This simplified script shows the essential clean-up steps to close
% communications with a DAP board, assuming that the connections were
% initially established using the dapinit_simple script. It is important
% to release all communication connections when they are no longer
% needed, to avoid spurious conflicts later. 
%

% Stop any processing that is currently running on the DAP board
dappstr(texthandle,'STOP');

% Close the command text channel
textclose = dapclose(texthandle)
if textclose==0
   error('Error closing DAP input text handle')
end

% Close the binary data transfer channel
binclose = dapclose (binaryhandle)
if binclose==0
   error('Error closing DAP binary output handle')
end
