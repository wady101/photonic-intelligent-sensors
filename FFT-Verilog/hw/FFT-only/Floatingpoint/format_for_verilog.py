import os 
import numpy as np
import struct
import IEEE754_writer

MAX_SAMPLES = 8192 
IP_WIDTH = 32
DATA_WIDTH = 14

input = np.loadtxt('./Comb3/0m.txt',delimiter="\n")

# Basic Test Transform
#
#output = np.multiply(np.around(input,6),1000) #Signifcant digits
#
#output = np.multiply(input,1000_000) #Signifcant digits
"""Conversion to IEEE 754"""
vec754=np.vectorize(IEEE754_writer.IEEE754)
approx=(vec754(input))
""""""""""""""""""""""""""""""""""""
""" Below talks about the scaling method - not applicable for FFT's Xilinx Core"""
"""remove decimals output """
#input = np.multiply(input,1_0_000)
"""First scale to DATA_WIDTH"""
#integer = np.around(np.multiply(input,2**DATA_WIDTH))
#integer=integer.astype(np.int64)
#integer=np.multiply(input,2**DATA_WIDTH)
#integer=  input
#format_float_pos_vec = np.vectorize(np.format_float_positional)
#approx = format_float_pos_vec(integer,fractional=False,precision=int(IP_WIDTH/4))

"""Convert to Binary"""
#binary_repr_vec = np.vectorize(np.binary_repr)
#binary = binary_repr_vec(integer,width=IP_WIDTH)

"""Required to get signed input.""" 
#transform = lambda x: 1 if(x>0) else  0
#vtransform = np.vectorize(transform)
#sign = vtransform(np.sign(integer))# (0<<IP_WIDTH)
#print(binary.dtype)
#sign= sign.astype(np.int64)
#output =  np.add((sign<<IP_WIDTH),binary)

""" If hex neeeded """
#int(format(hex(),'x')
output = approx

""""""""""""""""""""""""""""""""""""""
np.savetxt('./0m.txt',output,delimiter='\n', fmt='%s')
