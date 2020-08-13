% $RCSfile: run_xfft_v9_1_mex.m,v $ $Version: $ $Date: 2010/09/08 12:33:21 $
%
%  (c) Copyright 2008-2009 Xilinx, Inc. All rights reserved.
%
%  This file contains confidential and proprietary information
%  of Xilinx, Inc. and is protected under U.S. and
%  international copyright and other intellectual property
%  laws.
%
%  DISCLAIMER
%  This disclaimer is not a license and does not grant any
%  rights to the materials distributed herewith. Except as
%  otherwise provided in a valid license issued to you by
%  Xilinx, and to the maximum extent permitted by applicable
%  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
%  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
%  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
%  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
%  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
%  (2) Xilinx shall not be liable (whether in contract or tort,
%  including negligence, or under any other theory of
%  liability) for any loss or damage of any kind or nature
%  related to, arising under or in connection with these
%  materials, including for any direct, or any indirect,
%  special, incidental, or consequential loss or damage
%  (including loss of data, profits, goodwill, or any type of
%  loss or damage suffered as a result of any action brought
%  by a third party) even if such damage or loss was
%  reasonably foreseeable or Xilinx had been advised of the
%  possibility of the same.
%
%  CRITICAL APPLICATIONS
%  Xilinx products are not designed or intended to be fail-
%  safe, or for use in any application requiring fail-safe
%  performance, such as life-support or safety devices or
%  systems, Class III medical devices, nuclear facilities,
%  applications related to the deployment of airbags, or any
%  other applications that could lead to death, personal
%  injury, or severe property or environmental damage
%  (individually and collectively, "Critical
%  Applications"). Customer assumes the sole risk and
%  liability of any use of Xilinx products in Critical
%  Applications, subject only to applicable laws and
%  regulations governing limitations on product liability.
%
%  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
%  PART OF THIS FILE AT ALL TIMES. 
%-------------------------------------------------------------------
%
% Example code for FFT v8.0 MEX function
%
%-------------------------------------------------------------------

clc;  % Clear command window.
clear;  % Delete all variables.
  % Close all figure windows except those created by imtool.

  
% Generics for this smoke test
generics.C_NFFT_MAX = 13;
generics.C_ARCH = 3;
generics.C_HAS_NFFT = 0;
generics.C_USE_FLT_PT = 0;
generics.C_INPUT_WIDTH = 32; % Must be 32 if C_USE_FLT_PT = 1
generics.C_TWIDDLE_WIDTH = 30; % Must be 24 or 25 if C_USE_FLT_PT = 1
generics.C_HAS_SCALING = 0; % Set to 0 if C_USE_FLT_PT = 1
generics.C_HAS_BFP = 0; % Set to 0 if C_USE_FLT_PT = 1
generics.C_HAS_ROUNDING = 1; % Set to 0 if C_USE_FLT_PT = 1

channels = 1;

samples = 2^generics.C_NFFT_MAX;

% Handle multichannel FFTs if required
for channel = 1:channels
    fft=[];
  Filtername = "/home/kogami/workspace/InPhoSS-RA/InitialTrainingData/Comb3/0m.txt"; 
  fileID = fopen('exp.txt','w');
  
TimeData = importdata(Filtername,'\n');
% TimeData = sine_fn;

  
  for j=1:length(TimeData)
    constant_input = TimeData(j);
    input_raw(1:samples) = constant_input;
    
    if generics.C_USE_FLT_PT == 0
        % Set up quantizer for correct twos's complement, fixed-point format: one sign bit, C_INPUT_WIDTH-1 fractional bits
        q = quantizer([generics.C_INPUT_WIDTH, generics.C_INPUT_WIDTH-1], 'fixed', 'convergent', 'saturate');
        % Format data for fixed-point input
        input = quantize(q,input_raw);
      else
        % Floating point interface - use data directly
        input = input_raw;
      end
        fprintf(fileID,sfi(input(1),generics.C_INPUT_WIDTH ,generics.C_TWIDDLE_WIDTH).bin);
        fprintf(fileID,"\n");
      % Set point size for this transform
      nfft = generics.C_NFFT_MAX;

      % Set up scaling schedule: scaling_sch[1] is the scaling for the first stage
      % Scaling schedule to 1/N: 
      %    2 in each stage for Radix-4/Pipelined, Streaming I/O
      %    1 in each stage for Radix-2/Radix-2 Lite
      if generics.C_ARCH == 1 || generics.C_ARCH == 3
        scaling_sch = ones(1,floor(nfft/2)) * 2;
        if mod(nfft,2) == 1
          scaling_sch = [scaling_sch 1];
        end
      else
        scaling_sch = ones(1,nfft);
      end

      % Set FFT (1) or IFFT (0)
      direction = 1;

      if channels > 1
         fprintf('Running the MEX function for channel %d...\n',channel)
      else
         fprintf('Running the MEX function...\n')      
      end

  end
  fclose(fileID);
%   plot(fft)
end


function TimeData = sine_fn
   Fs = 8192;                   % samples per second
   dt = 1/Fs;                   % seconds per sample
   StopTime = 0.25;             % seconds
   t = (0:dt:StopTime-dt)';     % seconds
   %%Sine wave:
   Fc = 60;                     % hertz
   TimeData = cos(2*pi*Fc*t);
end