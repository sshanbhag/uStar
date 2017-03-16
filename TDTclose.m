function [outhandles, outflag] = TDTclose(config, RZ5, zBUS)
%------------------------------------------------------------------------
% [outhandles, outflag] = TDTclose(config, RZ5, zBUS)
%------------------------------------------------------------------------
% 
% Closes/shuts down TDT I/O Hardware for triggeredIO program
% 
%------------------------------------------------------------------------
% Input Arguments:
%   config        matlab struct containing configuration information
%   RZ5            matlab struct containing output device information
%   zBUS        matlab struct containing zBUS device information
% Output Arguments:
%   outhandles  handle containing RZ5, zBUS
%   outflag    flag to show if TDT is successfully terminated 
%               -1: error
%                0: not terminated 
%                1: success
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version (HPSearch): 2009-2011 by SJS
% Upgraded Version (HPSearch2): 2011-2012 by GA
% Four-channel Input Version (FOCHS): 2012 by GA
% Optogen mods: 2016 by SJS
% uSTar mods: 2017 by SJS
%------------------------------------------------------------------------

disp([ mfilename ': ...closing TDT devices...']);
outflag = 0; %#ok<NASGU> % not terminated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the TDT lock file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(config.TDTLOCKFILE, 'file')
    disp([ mfilename ': TDT lock file not found: ', config.TDTLOCKFILE ]);
    disp('Creating lock file, assuming TDT hardware is not initialized');
    TDTINIT = 0;
    save(config.TDTLOCKFILE, 'TDTINIT');
else
    load(config.TDTLOCKFILE);  % load the lock information
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exit gracefully (close TDT objects, etc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TDTINIT
	outhandles = struct(); %#ok<UNRCH>
	outhandles.zBUS = zBUS;
	outhandles.RZ5 = RZ5;

	%------------------------------------------------------------------
	% terminate zBUS, RZ5
	%------------------------------------------------------------------
	disp('...closing RZ5')
	outhandles.RZ5.status = outhandles.RZ5.closeFunc(outhandles.RZ5);
	disp('...closing zBUS')
	outhandles.zBUS.status = outhandles.zBUS.closeFunc(outhandles.zBUS);
	% Reset TDTINIT
	TDTINIT = 0;
	save(config.TDTLOCKFILE, 'TDTINIT');
	outflag = 1;
else
    disp([mfilename ': TDTINIT is not set!'])
    outflag = -1;
    outhandles = [];
end
