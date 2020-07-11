import os 
import argparse
import numpy as np
import glob
import fnmatch
from math import *
import pandas as pd
from scipy.signal import find_peaks


class before_inference_sim: 
    def __init__(self,rootdir,pressure):
        try:
            pressure_exception = pressure>=-1 & pressure<=7
        except Exception as ex:
            print("Parser inputs incorrect ",ex)

        #####
        #  For Tb - remove this case & update try statement.
        if pressure == -1: 
            i = 0
            n = 0
        #####
        if pressure == 0:
            output = [0,0,0,0,0,1] 
            i = 0 
            n = 350 
        elif pressure == 1:
            output = [0,0,0,0,1,0]
            i = 352 
            n = 1050
        elif pressure == 2:
            output = [0,0,0,1,0,0]
            i = 1052 
            n = 1750
        elif pressure == 3:
            output = [0,0,1,0,0,0]
            i = 1752 
            n = 2450
        elif pressure == 4:
            output = [0,1,0,0,0,0] 
            i = 2452 
            n = 3150
        elif pressure == 5:
            output = [1,0,0,0,0,0]
            i = 3152 
            n = 3850
        elif pressure == 6:
            output = [1,0,1] #=6mbar
        elif pressure == 7:
            output = [1,0,1] #=7mbar

        self.i,self.n,self.pressure, self.rootdir=i,n,pressure,rootdir

        
    def FFTpeaks(self,Fs,win1,win2):
        i,n,pressure,rootdir=self.i,self.n,self.pressure,self.rootdir
        while i<=n:
            FileName=rootdir+"/"+str(i)+"m.txt"
            if (pressure==0):
                i+=2
            else:
                i+=2
            
            TimeData=np.genfromtxt(FileName, delimiter='\n')
            Y,f = self.FFT(TimeData,Fs,i,win1,win2)
            self.peaks, _ = find_peaks(Y, distance=1)
            self.peaks2, _ = find_peaks(Y, prominence=1)      # BEST!
            self.peaks3, _ = find_peaks(Y, width=20)
            self.peaks4, _ = find_peaks(Y, threshold=-0.4)     # Required vertical distance to its direct neighbouring samples, pretty useless
            



            

    def FFT(self,TimeData,Fs,n,win1,win2):
        Ts=1/Fs
        NFFT=2^ceil(log2(abs(len(TimeData))))
        Y = np.fft.fft(TimeData,NFFT)
        f = Fs/2*np.linspace(0,1,ceil(NFFT/2))
        magY = 20*np.log10(2*abs(Y[0:ceil(NFFT/2)]))

        #windowing
        f = f[win1:win2]
        magY = magY[win1:win2]

        return magY,f

parser = argparse.ArgumentParser()
parser.add_argument('--root_dir', action='store', default='../InitialTrainingData/Comb3',
	help='Source dir for retrieving *m.txt files',type=str)
parser.add_argument('--pressure', action='store', default=-1,
	help='Pressure window',type=int)

args = parser.parse_args()
print('==> Options:',args)

if __name__=='__main__':
    x = before_inference_sim(args.root_dir,args.pressure)
    x.FFTpeaks(156e6*2,200,1100)

    





            

            





