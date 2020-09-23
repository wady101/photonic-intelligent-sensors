
clc;  % Clear command window.
clear;  % Delete all variables.
  % Close all figure windows except those created by imtool.
Filtername = "/home/kogami/workspace/InPhoSS-RA/FFT/dblclockfft/Vivadozipcpufft/Vivadozipcpufft.sim/sim_1/behav/xsim/output.txt"; 
temp = regexp( fileread(Filtername), '\r?\n', 'split');
if isempty(temp{end}); temp(end) = []; end         %empty after final \n
 
%   fftmax = max(TimeData);
%   for j=1:length(TimeData)
%       a=fi(0.1,1,48,25);
%        a.bin=extractAfter(temp{j},16);
%     img=sfi(0.1,32,29);
q = quantizer([32, 0], 'fixed', 'convergent', 'saturate');
a=bin2num(q,temp);
%      a.bin=extractAfter(temp{j},32); 
%  fft=[fft,a];
%     fft=[fft, 20*log10(2*abs(double(a)))];
%     fft = [fft,20*log10(abs(2*(sqrt(double(a)^2+double(img)^2))))]; 
%   end
Filtername2 = "/home/kogami/workspace/InPhoSS-RA/InitialTrainingData/Comb3/2m.txt"; 

 TimeData2 = importdata(Filtername2,'\n');
%     TimeData = sine_fn;

NFFT = 8192;
 Y = fft(TimeData2,NFFT);
 FFTmatlab = 20*log10(2*abs(Y));        % Magnitude of the FFT in dB
 hold on
   plot(FFTmatlab);
 FFTfpga = abs(20*log10(2*abs(cell2mat(a))))-150; 
plot(FFTfpga);

legend('Matlab','FPGA');
hold off 
% plot(fft)
title("FPGA simulation with FPGA y-shifted by 150 units")
xlabel("Frequency") 
ylabel("Magnitude (dB)")
% nums = bin2dec(extractAfter(temp,32));
%     nums_signed = typecast(uint32(bin2dec(regexprep(extractAfter(temp,32), {'^1', '^0'}, {'11111111', '00000000'}))),'int32');
%     plot(sign(nums_signed.*nums)
    %   end
