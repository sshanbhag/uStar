function [outhandles, outflag] = TDTopen(config, varargin)
%------------------------------------------------------------------------
% [outhandles, outflag] = TDTopen(config, varargin)
%------------------------------------------------------------------------
% 
%--- Initializes TDT I/O Hardware ---------------------------------------
% 
%------------------------------------------------------------------------
% Input Arguments:
%   config        matlab struct containing configuration information
%   varargin		for future use
%
% Output Arguments:
%   outhandles  handle containing indev, outdev, zBUS, PA5L, PA5R
%   outflag    flag to show if TDT is successfully initialized 
%              -1: error 
%               0: not initialized 
%               1: success 
%               2: already initialized
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%	Go Ashida & Sharad Shanbhag 
%	ashida@umd.edu
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version (HPSearch_TDTopen): 2009-2011 by SJS
% Upgraded Version (HPSearch2_TDTopen): 2011-2012 by GA
% Four-channel Input Version (FOCHS_TDTopen): 2012 by GA
% Optogen mods: 2016 by SJS
% uStar mods: 2017 by SJS
%------------------------------------------------------------------------
disp([mfilename ': ...starting TDT devices...']);
outflag = 0; % not initialized

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDTINIT_FORCE is usually 0, unless user chooses 'RESTART' 
% if TDTINIT is set in the .tdtlock.mat file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TDTINIT_FORCE = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if the TDT lock file (.tdtlock.mat) exists 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(config.TDTLOCKFILE, 'file')
    disp([mfilename ': TDT lock file not found: ', config.TDTLOCKFILE]);
    disp('Creating lock file, assuming TDT hardware is not initialized');
    TDTINIT = 0;
    save(config.TDTLOCKFILE, 'TDTINIT');
else
    load(config.TDTLOCKFILE);     % load the lock information
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the lock variable (TDTINIT) in the TDT lock file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TDTINIT
    questStr = {'TDTINIT already set in .tdtlock.mat', ...
                'TDT Hardware might be active.', ...
                'Continue, Restart TDT Hardware, or Abort?'}; %#ok<UNRCH>
    titleStr = 'FOCHS: TDTINIT error';
    respStr = questdlg(questStr, titleStr, 'Do_Nothing', 'Restart', 'Abort', 'Abort');
    
    switch upper(respStr)
        case 'DO_NOTHING'
            disp([mfilename ': continuing anyway...'])
            outhandles = [];
            outflag = 2;  % already initialized
            return;        
        case 'ABORT'
            disp([mfilename ': aborting initialization...'])
            outhandles = [];
            outflag = -1;  % error state
            return;
        case 'RESTART'
            disp([mfilename ': forcing to start TDT hardware...'])
            TDTINIT_FORCE = 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if TDTINIT is not set (TDT hardware not initialized) OR if
% TDTINIT_FORCE is set, initialize TDT hardware
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~TDTINIT || TDTINIT_FORCE
	disp([mfilename ': Configuration = ' config.CONFIGNAME]); 

	%------------------------------------------------------------------
	% initialize the outhandles structure
	%------------------------------------------------------------------
	outhandles = struct();
	outhandles.RZ5 = ...
		struct(	'hardware', 'RZ5D', ...
					'C', [], ...
					'handle', [], ...
					'status', 0, ...
					'Fs', 50000, ...
					'Circuit_Path', ...
						'C:\Users\sshanbhag.OPTOCOM\Code\Matlab\dev\uStar', ...
					'Circuit_Name', 'RZ5D_trigouttest.rcx', ...
					'Dnum', 1	);
	outhandles.zBUS =  struct(	'C', [], ...
										'handle', [], ...
										'status', 0	);
	% function handles
	outhandles.zBUS.initFunc = @zBUSinit;
	outhandles.zBUS.closeFunc = @zBUSclose;
	outhandles.RZ5.initFunc = @RZ5init;
	outhandles.RZ5.closeFunc = @RPclose; 
	outhandles.RZ5.loadFunc = @RPload; 
	outhandles.RZ5.runFunc  = @RPrun; 
	outhandles.RZ5.samplefreqFunc = @RPsamplefreq;

	%------------------------------------------------------------------
	% initialize zBUS, RZ5, then load and start circuits
	%------------------------------------------------------------------
	try
		% Initialize zBus control
		disp('...starting zBUS...')
		tmpdev = outhandles.zBUS.initFunc('GB');
		outhandles.zBUS.C = tmpdev.C;
		outhandles.zBUS.handle = tmpdev.handle;
		outhandles.zBUS.status = tmpdev.status;
% 		clear tmpdev
		% Initialize RZ5D
		disp('...starting RZ5D...');
		tmpdev = outhandles.RZ5.initFunc('GB', outhandles.RZ5.Dnum);
		outhandles.RZ5.C = tmpdev.C;
		outhandles.RZ5.handle = tmpdev.handle;
		outhandles.RZ5.status = tmpdev.status;
% 		clear tmpdev
		% Load circuits
		disp('...loading circuits...')
		outhandles.RZ5.status  = outhandles.RZ5.loadFunc(outhandles.RZ5);
		% Starts Circuits
		disp('...starting circuits...')
		outhandles.RZ5.runFunc(outhandles.RZ5);
		% Get the input and output sampling rates
		outhandles.RZ5.Fs  = outhandles.RZ5.samplefreqFunc(outhandles.RZ5);
		disp(['RZ5 frequency (Hz) = '  num2str(outhandles.RZ5.Fs)]);
		% Set the lock
		TDTINIT = 1;  %#ok<NASGU>
		outflag = 1; % success
	catch ME
		TDTINIT = 0; %#ok<NASGU>
		outflag = -1; %#ok<NASGU> % TDT initialization failed  
		disp([mfilename ': error starting TDT hardware'])
		disp(ME.identifier);
		rethrow(ME);
	end

    % save TDTINIT in lock file
    save(config.TDTLOCKFILE, 'TDTINIT');
    return;
end

