import matplotlib.pyplot as plt
import numpy as np
import argparse
import re

logs="output.txt"
(model1, model2) = ([], [])
#grab number of boosts

# rows = open(logs).read().strip()
# epochs = str(re.findall(r"num_boost: \d+", rows))
# epochs = re.sub('\',','',int(s) for s in epochs.split())
# print(epochs.split())
# epochs = [int(s) for s in epochs.split() if s.isdigit()]
file1 = open(logs, 'r') 
Lines = file1.readlines() 
# # epochs = sorted([int(e) for e in epochs])
# mod1 = str(re.findall(r"selected model: [-+]?\d*\.\d+|\d+", rows))
# mod2 = set(re.findall(r"selected model 2: [-+]?\d*\.\d+|\d+", rows))
# plot the accuracies
k = 2
for line in Lines: 
    z=line.strip()
    model1.append(z)
#    k = k+1
#    if(k==3):
#        k=0
#    elif(k==1):
#        model1.append(z)
#    elif(k==2):
#        model2.append(z)

#print(model1)

    
plt.style.use("seaborn-paper")
plt.figure()
plt.plot(np.arange(0, len(model1)), model1,
	label="Top-1")
plt.title("FFT-Transform of input time signal".format(
	1,2))
plt.xlabel("Frequencies")
plt.ylabel("Magnitude")
plt.legend(loc="lower right")
plt.show()


        


