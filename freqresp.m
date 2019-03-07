%% freqresp.m %%
%  Calculate a frequency response transfer spectrum from input output
%  data pairs captured by a DAP board.

%  Configure the number of replications to be collected
Nrep = 10;
scalefact = 1.0/Nrep;

%  Configure the data block size the DAP will return
Nblock = 20000;
Nval   = Nblock/8;
respavg= zeros(1,Nval);

% Configure the input/output test - it begins immediately
dapallopen();
errcode = dapcnfig(hTextToDap, 'freqresp.dap');
if errcode < 1
   error('Error configuring DAP')
   dapallclose();
end
 
% Collect the 2-channel data. Allow sufficient time for each block.
disp('Collecting the frequency response data')
for  rep=1:Nrep
   % Collect one new input/output block
   disp('  --Collecting the frequency response data block:'); disp(rep)
   [respmat,errcode] = dapgetm(hBinFromDap, [2, Nblock], 'int16', 5000, 6000);
   if (errcode <= 0)
       disp('Matrix fetch timed out')
       break;
   end
   
   % Updating response array
   disp('  --Updating response arrays')
   excite = respmat(1,:);
   inspect = fft(excite);
   response = respmat(2,:);
   outspect = fft(response);

   % Real-valued input, so only the first half provides unique information.
   % Of that, only 1/4 of the Nyquist rate has any stimulus information.
   inspect = inspect(1:Nval);
   outspect = outspect(1:Nval);
   respspect = (outspect ./ inspect)*scalefact;

   % Add to the response average
   respavg = respavg + respspect;
end

% Convert response to polar form.
respmag = abs(respavg);
respang = angle(respavg);


% Phase compensation. The response is actually measured 1/2 sample
% following the stimulus... this generates artificial phase advance 
% artifacts in the response spectrum. These are completely predictable
% however, and the phase response can be adjusted to compensate.
disp('Applying correction for response phase terms');
corrfact = pi/Nblock;
for  iterm=1:Nval
   respang(iterm) = respang(iterm) - (iterm-1)*corrfact;
   if  respang(iterm) < -pi
      respang(iterm) = respang(iterm)+2*pi;
   end
end

% Plot raw transfer gain and phase curves
figure(1)
plot(1:Nval,respmag(1:Nval),'b');
title('Frequency response, gain');
figure(2)
plot(1:Nval,respang(1:Nval),'g');
title('Frequency response, phase');

dapallclose();
