import time
from registers import *
from Jtag import *

import numpy as np
import matplotlib.pyplot as plt
#-------------------------------------------------------------------------------

def take_log():
    print('Starting data log');
    write_register(Regs.Logger.LPF_Go, 0)
    write_register(Regs.Logger.LPF_Go, 1)

    while not read_register(Regs.Logger.LPF_Busy):
        time.sleep(0.1)

    print('Data log in progress');
    write_register(Regs.Logger.LPF_Go, 0)

    while read_register(Regs.Logger.LPF_Busy):
        time.sleep(0.1)

    print('Data log done');
#-------------------------------------------------------------------------------

jtag = Jtag()
jtag.open()
#-------------------------------------------------------------------------------

plt.ion()
fig, ax = plt.subplots()
line, = ax.plot([], [])

ax.set_xlabel("Frequency [Hz]")
ax.set_ylabel("Magnitude [dB]")
ax.set_title("Range FFT")
ax.grid(True)

f = np.linspace(0, 100e6/1024/256, 129)
f = f[0:-1]
f -= f[64]
line.set_xdata(f)
ax.set_xlim(f[0], f[-1])
ax.set_ylim(-50, 0)
#-------------------------------------------------------------------------------

while True:
    take_log()

    data = jtag.read(256, source=2) # one second of raw LPF samples

    for n in range(len(data)):
        if data[n] >= 0x80000000:
            data[n] -= 0x100000000;

    data = np.array(data)
    data = (data[0::2] + 1j*data[1::2]) / 2**23

    data = [ data[n:n+32] for n in range(0, len(data), 32) ]
    sweep = data[0]
    sweep -= np.mean(sweep)

    X = np.fft.fftshift(np.fft.fft(sweep, n=128)) / 32

    line.set_ydata(20*np.log10(np.abs(X)))

    fig.canvas.draw()
    fig.canvas.flush_events()
    plt.pause(0.001)
#-------------------------------------------------------------------------------

