import os 
import numpy as np

MAX_SAMPLES = 8192 
IP_WIDTH = 16
DATA_WIDTH = 14

input = np.loadtxt('./Comb3/0m.txt',delimiter="\n")

# Other Transforms 
#
#output = np.multiply(np.around(input,6),1000) #Signifcant digits
#
#output = np.multiply(input,1000_000) #Signifcant digits

"""remove decimals output """
input = np.multiply(input,1000_000)
"""First scale to DATA_WIDTH"""
integer = np.around(np.multiply(input,2**DATA_WIDTH))
integer=integer.astype(np.int64)

"""Convert to Binary"""
binary_repr_vec = np.vectorize(np.binary_repr)
binary = binary_repr_vec(integer,width=IP_WIDTH)

"""Required to get signed input.""" 
#transform = lambda x: 1 if(x>0) else  0
#vtransform = np.vectorize(transform)
#sign = vtransform(np.sign(integer))# (0<<IP_WIDTH)
#print(binary.dtype)
#sign= sign.astype(np.int64)
#output =  np.add((sign<<IP_WIDTH),binary)

""" If hex neeeded """
#int(format(hex(),'x')
output = binary

np.savetxt('./0m.txt',output,delimiter='\n', fmt='%s')
