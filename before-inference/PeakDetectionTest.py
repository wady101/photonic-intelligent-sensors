import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks
import scipy.fftpack

# Number of samplepoints
N = 500
# sample spacing
T = 1.0 / 200.0
x = np.linspace(0.0, N*T, N)
y = np.random.randint(1,101)*np.sin(10.0 * 2.0*np.pi*x) + np.random.randint(1,101)*np.sin(20.0 * 2.0*np.pi*x) + np.random.randint(1,101)*np.sin(30.0 * 2.0*np.pi*x) + np.random.randint(1,101)*np.sin(40.0 * 2.0*np.pi*x) + np.random.randint(1,101)*np.sin(50.0 * 2.0*np.pi*x) + np.random.randint(1,101)*np.sin(60.0 * 2.0*np.pi*x)+ np.random.randint(1,101)*np.sin(70.0 * 2.0*np.pi*x) + np.random.randint(1,101)*np.sin(80.0 * 2.0*np.pi*x) + np.random.randint(1,101)*np.sin(90.0 * 2.0*np.pi*x)
plt.plot(x, y)
plt.show()

yf = scipy.fftpack.fft(y)
xf = np.linspace(0.0, 1.0/(2.0*T), N/2)

yfft = 2.0/N*np.abs(yf[:N//2])

fig, ax = plt.subplots()
ax.plot(xf, yfft)
plt.show()


peaks, _ = find_peaks(yfft, distance= 50)
peaks2, _ = find_peaks(yfft, prominence=0.4)      # BEST!
peaks3, _ = find_peaks(yfft, width=20)
peaks4, _ = find_peaks(yfft, threshold=0.4)     # Required vertical distance to its direct neighbouring samples, pretty useless


plt.subplot(2, 2, 1)
plt.plot(peaks, yfft[peaks], "xr"); plt.plot(yfft); plt.legend(['distance'])
plt.subplot(2, 2, 2)
plt.plot(peaks2, yfft[peaks2], "ob"); plt.plot(yfft); plt.legend(['prominence'])
plt.subplot(2, 2, 3)
plt.plot(peaks3, yfft[peaks3], "vg"); plt.plot(yfft); plt.legend(['width'])
plt.subplot(2, 2, 4)
plt.plot(peaks4, yfft[peaks4], "xk"); plt.plot(yfft); plt.legend(['threshold'])

plt.show()


x = np.sin(2*np.pi*(2**np.linspace(2,10,1000))*np.arange(1000)/48000) + np.random.normal(0, 1, 1000) * 0.15
peaks, _ = find_peaks(x, distance=1)
peaks2, _ = find_peaks(x, prominence=1)      # BEST!
peaks3, _ = find_peaks(x, width=20)
peaks4, _ = find_peaks(x, threshold=-0.4)     # Required vertical distance to its direct neighbouring samples, pretty useless


plt.subplot(2, 2, 1)
plt.plot(peaks, x[peaks], "xr"); plt.plot(x); plt.legend(['distance'])
plt.subplot(2, 2, 2)
plt.plot(peaks2, x[peaks2], "ob"); plt.plot(x); plt.legend(['prominence'])
plt.subplot(2, 2, 3)
plt.plot(peaks3, x[peaks3], "vg"); plt.plot(x); plt.legend(['width'])
plt.subplot(2, 2, 4)
plt.plot(peaks4, x[peaks4], "xk"); plt.plot(x); plt.legend(['threshold'])
plt.show()