clc;  % Clear command window.
clear;  % Delete all variables.
  % Close all figure windows except those created by imtool.
workspace;  % Make sure the workspace panel is showing.

i = 352;
k=1;
itr = 0.5;
o = 1:itr:5;    
o_index = 1:(1/itr)*5;
o_encoded = bsxfun(@eq, o_index(:), 1:max(o_index));
for pressure=1:itr:5
    j= 1;

    clear TrainingInputs;
clear TrainingOutputs;
n = i+450;
if i>4534
    break;
end
k=k+1;
output = o_encoded(k,:);

while i <= n  
    if i==4534
        break;
    end
    Filtername = "/home/kogami/workspace/InPhoSS-RA/InitialTrainingData/Comb3/"+ i + "m.txt";
    i=i+2;
    %Imports the data using the below function
    TimeData = importfile(Filtername, [2, Inf]);

    %Sampling Frequency needs to be rectified. This section computes the SS FFT
    Fs = 156e6*2; % Sampling frequency
    T = 1/Fs;   % Sample time
    NFFT = 8192;
    Y = fft(TimeData,NFFT)/(length(TimeData));
    f = Fs/2*linspace(0,1,NFFT/2+1);
    magY = 20*log10(2*abs(Y(1:NFFT/2+1)));        % Magnitude of the FFT in dB
    
    %magY = (2*abs(Y(1:NFFT/2+1)));        % Magnitude of the FFT
    %in linear scale
    
    %These decide the points of interest
    magYinterest = magY(1:3048,1);
    finterset = f(1,1:3048);
    %This finds the peaks
%     findpeaks(magYinterest, finterset, 'MinPeakProminence',0.00012, 'MinPeakDistance', 0.75e6);
    [pks,locs] = findpeaks(magYinterest, finterset, 'MinPeakProminence',0.00012, 'MinPeakDistance', 0.75e6);

    %This value will need to be increased in the loop. Saving to a new row each
    %time
    TrainingInputs(:,j) = pks(115,1);
    TrainingOutputs(:,j) = output';
    j=j+1;
%     hold 'on'
end


%Have this at the very end,  need to save the files are .mat due to the
%boundary conditions of excel i.e. too many columns

save("TrainingInputsDecimal"+pressure+".mat",'TrainingInputs') 
save("TrainingOutputsDecimal"+pressure+".mat",'TrainingOutputs') 
%writematrix(TrainingInputs,"TrainingInputs"+pressure+"mbardB3.xls",'WriteMode','append')
%writematrix(TrainingOutputs,"TrainingOutputs" +pressure+ "mbardB3.xls",'WriteMode','append')

%Normalised Data
Max = max(TrainingInputs, [], 'all');
Min = min(TrainingInputs, [], 'all');
TraininingInputNorm = (TrainingInputs-Min)/(Max-Min);
%writematrix(TrainingInputs,"TrainingInputs"+pressure+"mbardBNorm.xls",'WriteMode','append')

%Plot single-sided amplitude spectrum.
% title('Single-Sided Amplitude Spectrum of y(t)')
% xlabel('Frequency')
% ylabel('|Y(f)|') 
end
   
