import matplotlib.pyplot as plt
import numpy as np
import argparse
import re
import IEEE754 
import math

DATA_WIDTH = 14
logs="output.txt"
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
        real=andbytes(z, b'11111111111111111111111111111111')
        img=andbytes(z, b'1111111111111111111111111111111100000000000000000000000000000000')
        real_f=IEEE754.ieee754_to_int(real.decode("utf-8"))
        img_f=IEEE754.ieee754_to_int(img.decode("utf-8"))
        model1.append(math.sqrt((img_f**2)+(real_f**2)))
i=0
x=model1
plt.figure()
plt.plot(np.arange(0, len(x)), x,
	label="FFT")
plt.title("FFT-Transform of input time signal".format(
	1,2))
plt.xlabel("Frequencies")
plt.ylabel("Magnitude")
plt.legend(loc="lower right")
plt.savefig("Fig%s.png" % i)
plt.clf()
i+=1

