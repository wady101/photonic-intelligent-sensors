import numpy as np
import struct
import IEEE754_writer
import matplotlib.pyplot as plt
from math import *

DATA_WIDTH = 14
fs = 44100       # sampling rate, Hz, must be integer
duration = 1.0   # in seconds, may be float
f = 440.0        # sine frequency, Hz, may be float

def FFT(TimeData,Fs,n,win1,win2):
    Ts=1/Fs
    NFFT=2**ceil(log2(abs(len(TimeData))))
    Y = np.fft.fft(TimeData,NFFT)
    f = Fs/2*np.linspace(0,1,ceil(NFFT/2))
    magY = 20*np.log10(2*abs(Y[0:ceil(NFFT/2)]))

    #windowing
    f = f[win1:win2]
    magY = magY[win1:win2]

    return magY,f

# generate samples, note conversion to float32 array
samples = (np.sin(2*np.pi*np.arange(fs*duration)*f/fs)).astype(np.float32)
vec754=np.vectorize(IEEE754_writer.IEEE754)
approx=(vec754(samples))
x,y=FFT(samples,fs,f,0,2000)
plt.plot(x)
plt.show()
np.savetxt('./0m.txt',approx,delimiter='\n',fmt='%s')
