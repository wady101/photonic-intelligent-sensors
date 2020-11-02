
clc;  % Clear command window.
clear;  % Delete all variables.
  % Close all figure windows except those created by imtool.
FreqFileName = "/home/kogami/workspace/InPhoSS-RA/FFT/dblclockfft/Vivadozipcpufft/Vivadozipcpufft.sim/sim_1/behav/xsim/output.txt"; 
temp = regexp( fileread(FreqFileName), '\r?\n', 'split');
if isempty(temp{end}); temp(end) = []; end         %empty after final \n
 
q = quantizer([32, 0], 'fixed', 'convergent', 'saturate');
a=bin2num(q,temp);
TimeFilename = "/home/kogami/workspace/InPhoSS-RA/InitialTrainingData/Comb3/2m.txt"; 

TimeData = importdata(TimeFilename,'\n');

NFFT = 8192;
Y = fft(TimeData,NFFT);
FFTmatlab = 20*log10(2*abs(Y));        % Magnitude of the FFT in dB
hold on
plot(FFTmatlab);
FFTfpga = abs(20*log10(2*abs(cell2mat(a))))-150; 
plot(FFTfpga);

legend('Matlab','FPGA');
hold off 
title("FPGA simulation with FPGA y-shifted by 150 units")
xlabel("Frequency") 
ylabel("Magnitude (dB)")
