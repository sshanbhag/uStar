%-------------------------------------------------------------------------
% dapallopen()
%-------------------------------------------------------------------------
% xxxx
%-------------------------------------------------------------------------
%  Open DAP handles for all of the 'predefined' communication pipes on
%  the specified DAP board. If any handle cannot be opened, all 
%  handles are closed and an error condition terminate the run.
%  If some of these handles are not required... no harm.
%-------------------------------------------------------------------------
%	Handles Opened:
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
% See Also: dapallclose, DAPtools for MATLAB pdf doc.
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

disp('Opening the predefined handles to the DAP board.');

% %--------------------------------------------------------------------------
% % Open WRITE connection to DAP board pipe if not already opened
% %--------------------------------------------------------------------------
% if  exist('hDapW','var')
% 	if  hDapW == 0
% 		temp = dapopen('\\.\Dap0', 'write');
% 	else
% 		disp('Handle hDapW is already open')
% 		temp = hDapW;
% 	end
% else
% 	temp = dapopen('\\.\Dap0', 'write');
% end
% if  temp == 0
% 	dapallclose()
% 	error('Error opening DAP command text handle')
% else
% 	hDapW = temp;
% end
% 

%--------------------------------------------------------------------------
% Open connection to DAP command pipe if not already opened
%--------------------------------------------------------------------------
if  exist('hTextToDap','var')
    if  hTextToDap == 0
        temp = dapopen('\\.\Dap0\$SysIn', 'write');
    else
        disp('Handle hTextToDap is already open')
        temp = hTextToDap;
    end
else
    temp = dapopen('\\.\Dap0\$SysIn', 'write');
end
if  temp == 0
    dapallclose()
    error('Error opening DAP command text handle')
else
    hTextToDap = temp;
end

% Send a command to reset the DAP
dappstr(hTextToDap, 'RESET')
pause(0.2);


%--------------------------------------------------------------------------
% Open connection to DAP message text pipe if not already opened
%--------------------------------------------------------------------------
if  exist('hTextFromDap','var')
    if  hTextFromDap == 0
        temp = dapopen('\\.\Dap0\$SysOut', 'read');
    else
        disp('Handle hTextFromDap is already open')
        temp = hTextFromDap;
    end
else
    temp = dapopen('\\.\Dap0\$SysOut', 'read');
end
if  temp == 0
    dapallclose()
    error('Error opening DAP message text handle')
else
    hTextFromDap = temp;
end
% Flush old messages from text pipe, if any
dapflshi(hTextFromDap);


%--------------------------------------------------------------------------
% Open connection to DAP binary data delivery pipe if not already opened
%--------------------------------------------------------------------------
if  exist('hBinFromDap','var')
    if  hBinFromDap == 0
        temp = dapopen('\\.\Dap0\$BinOut', 'read');
    else
        disp('Handle hBinFromDap is already open')
        temp = hBinFromDap;
    end
else
    temp = dapopen('\\.\Dap0\$BinOut', 'read');
end
if  temp == 0
    dapallclose()
    error('Error opening DAP to host binary data handle')
else
    hBinFromDap = temp;
end
% Flush old DAP data in binary pipe, if any
dapflshi(hBinFromDap);


%--------------------------------------------------------------------------
% Open connections to DAP binary download pipe if not already opened
%--------------------------------------------------------------------------
if  exist('hBinToDap','var')
    if  hBinToDap == 0
        temp = dapopen('\\.\Dap0\$BinIn', 'write');
    else
       disp('Handle hBinToDap is already open')
       temp = hBinToDap;
    end
else
    temp = dapopen('\\.\Dap0\$BinIn', 'write');
end
if  temp == 0
    dapallclose()
    error('Error opening host to DAP binary download data handle')
else
    hBinToDap = temp;
end
%--------------------------------------------------------------------------
% Flush old DAP data in binary pipe, if any
%--------------------------------------------------------------------------
dapflsho(hBinToDap);

%--------------------------------------------------------------------------
% Indicate success in connecting to DAP board
%	commented out, SJS
%--------------------------------------------------------------------------
% dappstr(hTextToDap, 'HELLO');
% pause(0.2);
% avail = dapgavl(hTextFromDap);
% if  avail > 0
%    msg = dapgstr(hTextFromDap, 500);
% end
% disp(msg);
