import os 
import numpy as np
input = np.loadtxt('./Comb3/0m.txt',delimiter="\n")
#output = np.multiply(np.around(input,6),1000) #Signifcant digits
output = np.multiply(input,1000_000) #Signifcant digits
np.savetxt('./0m.txt',output,delimiter='\n', fmt='%f')
