import matplotlib.pyplot as plt
import numpy as np
import argparse
import re
import IEEE754 

DATA_WIDTH = 14
logs="output32.txt"
model1,model2 = ([],[])

file1 = open(logs, 'rb') 
Lines = file1.readlines() 

def andbytes(abytes, bbytes):
    return bytes([a & b for a, b in zip(abytes[::-1], bbytes[::-1])][::-1])
k = 2
i = 0
for line in Lines: 
    z=line.strip()
    if(z == 'x'.rjust(64,'x')):
        model1.append(0)
    elif(z == b'1234567890'):
        model2.append(model1)
    else:
        model1.append(IEEE754.ieee754_to_int(z.decode("utf-8")))
i =1
plt.figure()
plt.plot(np.arange(0, len(model1)), model1,
	label="FFT")
plt.title("FFT-Transform of input time signal".format(
	1,2))
plt.xlabel("Frequencies")
plt.ylabel("Magnitude")
plt.legend(loc="lower right")
plt.savefig("Fig%s.png" % i)
plt.clf()
i+=1
