
clc;  % Clear command window.
clear;  % Delete all variables.
  % Close all figure windows except those created by imtool.
Filtername = "/home/kogami/workspace/InPhoSS-RA/FFT/FFT-only-tb/FFT-only-tb.sim/sim_1/behav/xsim/output.txt"; 
temp = regexp( fileread(Filtername), '\r?\n', 'split');
if isempty(temp{end}); temp(end) = []; end         %empty after final \n
  TimeData = importdata(Filtername,'\n');
  fft=[];
for j=1:length(TimeData)
%     temp = TimeData(j);
    a=sfi(0.1,32,30);
    a.bin=extractAfter(temp{j},32);
    fft=[fft, 20*log10(2*abs(double(a)))];    
end
plot(fft)
% nums = bin2dec(extractAfter(temp,32));
%     nums_signed = typecast(uint32(bin2dec(regexprep(extractAfter(temp,32), {'^1', '^0'}, {'11111111', '00000000'}))),'int32');
%     plot(sign(nums_signed.*nums)
    %   end
