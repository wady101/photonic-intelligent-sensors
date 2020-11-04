clc;  % Clear command window.
clear;  % Delete all variables.
  % Close all figure windows exc_ept those created by imtool.

  
% Generics for this smoke test
generics.C_NFFT_MAX = 13 ;
generics.C_HAS_NFFT = 0;
generics.C_ARCH = 3;
generics.C_INPUT_WIDTH = 32; % Must be 32 if C_USE_FLT_PT = 1
generics.C_TWIDDLE_WIDTH = 25; % Must be 24 or 25 if C_USE_FLT_PT = 1
generics.C_HAS_SCALING = 0; % Set to 0 if C_USE_FLT_PT = 1
generics.C_HAS_ROUNDING = 1; % Set to 0 if C_USE_FLT_PT = 1

channels = 1;

samples = 2^generics.C_NFFT_MAX;

% Handle multichannel FFTs if required
for channel = 1:channels
Filtername = "/home/kogami/workspace/InPhoSS-RA/InitialTrainingData/Comb3/2m.txt"; 
fileID = fopen('exp.txt','w');
  
TimeData = importdata(Filtername,'\n');
%TimeData = sine_fn;
hold on 
 % Plotting sim
NFFT = 8192;
Y = fft(TimeData,NFFT);
magY = 20*log10(2*abs(Y));        
plot(magY)
title("MATLAB simulation")
xlabel("Frequencies")
ylabel("Magnitude")
for j=1:length(TimeData)
    constant_input = TimeData(j);
    input_raw= constant_input;
    
    if generics.C_USE_FLT_PT == 0
        % Set up quantizer for correct twos's complement, fixed-point format: one sign bit, C_INPUT_WIDTH-1 fractional bits
         q = quantizer([generics.C_INPUT_WIDTH, generics.C_TWIDDLE_WIDTH], 'fixed', 'convergent', 'saturate');
        % Format data for fixed-point input
      input = num2bin(q,input_raw);
    else
       % Floating point interface - use data directly
      input = input_raw;
    end
    fprintf(fileID,input);
    fprintf(fileID,"\n");
    % Set point size for this transform
    nfft = generics.C_NFFT_MAX;

    % The below code is for scaling, if required
    % 
    % Set up scaling schedule: scaling_sch[1] is the scaling for the first stage
    % Scaling schedule to 1/N: 
    %    2 in each stage for Radix-4/Pipelined, Streaming I/O
    %    1 in each stage for Radix-2/Radix-2 Lite
    % if generics.C_ARCH == 1 || generics.C_ARCH == 3
    %   scaling_sch = ones(1,floor(nfft/2)) * 2;
    %   if mod(nfft,2) == 1
    %     scaling_sch = [scaling_sch 1];
    %   end
    % else
    %   scaling_sch = ones(1,nfft);
    % end
  end
  fclose(fileID);
end

function TimeData = sine_fn
   Fs = 16384;                   % samples per second
   dt = 1/Fs;                   % seconds per sample
   StopTime = 2;             % seconds
   t = (0:dt:StopTime-dt)';     % seconds
   %%Sine wave:
   Fc = 2400;                     % hertz
   Fc2 = 4800;
   TimeData = sin(2*pi*Fc*t)+sin(2*pi*Fc2*t);
end
