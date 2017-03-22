%-------------------------------------------------------------------------
% dapallclose()
%-------------------------------------------------------------------------
% xxxx
%-------------------------------------------------------------------------
%  Look for all 'predefined' DAP handles that could have
%  been opened by the dapallopen script, and close them.
%  If the expected handle variables do not exist, or if they
%  exist but the handle variable contents have been corrupted, 
%  control of the channel pipe is lost. To recover from this,
%  it is necessary to exit Matlab environment and reset the 
%  DAP system software from the Control Panel. If a handle 
%  variable exists, and has a non-zero value indicating that 
%  the handle was opened, an attempt is made to close 
%  that handle. After this, the handle value is set to zero, 
%  indicating that the handle was closed. This process is
%  repeated for each handle, regardless of success or failure.
%
%  If a handle fails to open properly after an error or 
%  debugging trace exit, it is likely that manually invoking
%  dapallclose will be able to clear the problem. 
%-------------------------------------------------------------------------
%	Handles Closed:
% 
% 		Var Name			Pipe		Use
%		-------------	--------	--------------------------------------------
%		hDapW				dap0		board-level pipe (e.g., for dapreset(hDap))
% 		hTextToDap		$SysIn	Commands going to DAPL system on DAP
% 		hTextFromDap	$SysOut	Messages returned to host system from DAP
% 		hBinToDap		$BinIn	Precomputed signals downloaded to DAP
% 		hBinFromDap		$BinOut	Sample values delivered to host from DAP
%
%-------------------------------------------------------------------------
% See Also: dapallopen, DAPtools for MATLAB pdf doc.
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created: Original code by Microstar Labs (mstarlabs.com)
%
% Revision History:
%	22 Mar 2017 (SJS): added hDapW variable for dap0 pipe
%--------------------------------------------------------------------------

disp('Closing the predefined handles to the DAP board.')

% 
% %--------------------------------------------------------------------------
% % Close WRITE handle to the DAP board pipe
% %--------------------------------------------------------------------------
% if  exist('hDapW','var')
%    if hDapW ~= 0
%       dappstr(hDapW,'STOP');
%       dappstr(hDapW,'RESET');
%       pause(0.1);
%       dapflsho(hDapW);
%       temp = dapclose(hDapW);
%       hDapW = 0;
%    end
% else
%    hDapW = 0;
% end


%--------------------------------------------------------------------------
% Close handle to the DAP command pipe
%--------------------------------------------------------------------------
if  exist('hTextToDap','var')
   if hTextToDap ~= 0
      dappstr(hTextToDap,'STOP');
      dappstr(hTextToDap,'RESET');
      pause(0.1);
      dapflsho(hTextToDap);
      temp = dapclose(hTextToDap);
      hTextToDap = 0;
   end
else
   hTextToDap = 0;
end

%--------------------------------------------------------------------------
% Close handle to the DAP message text pipe
%--------------------------------------------------------------------------
if  exist('hTextFromDap','var')
   if hTextFromDap ~= 0
       temp = dapclose(hTextFromDap);
       hTextFromDap = 0;
   end
else
   hTextFromDap = 0;
end

%--------------------------------------------------------------------------
% Close handle to the binary sample data pipe
%--------------------------------------------------------------------------
if  exist('hBinFromDap','var')
   if hBinFromDap ~= 0
       temp = dapclose(hBinFromDap);
       hBinFromDap = 0;
   end
else
   hBinFromDap = 0;
end

%--------------------------------------------------------------------------
% Close handle to the binary sample data pipe
%--------------------------------------------------------------------------
if  exist('hBinToDap','var')
   if hBinToDap ~= 0
       dapflsho(hBinToDap);
       temp = dapclose(hBinToDap);
       hBinToDap = 0;
   end
else
   hBinToDap = 0;
end

%--------------------------------------------------------------------------
% done!
%--------------------------------------------------------------------------
disp('All opened connections to DAP boards closed.');
