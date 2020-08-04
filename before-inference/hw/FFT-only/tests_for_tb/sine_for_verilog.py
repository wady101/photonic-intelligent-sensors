import numpy as np
import struct

DATA_WIDTH = 14
fs = 44100       # sampling rate, Hz, must be integer
duration = 1.0   # in seconds, may be float
f = 440.0        # sine frequency, Hz, may be float

# generate samples, note conversion to float32 array
samples = (np.sin(2*np.pi*np.arange(fs*duration)*f/fs)).astype(np.float32)
def float_to_bin(num):
    bits, = struct.unpack('!I', struct.pack('!f', num))
    return "{:032b}".format(bits)
#integer=np.multiply(samples,2**DATA_WIDTH)
float_to_bin_vec = np.vectorize(float_to_bin)
approx = float_to_bin_vec(samples)


np.savetxt('./0m.txt',approx,delimiter='\n',fmt='%s')
