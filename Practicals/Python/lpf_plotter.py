import time
from registers import *
from Jtag import *

import numpy as np
import matplotlib.pyplot as plt
#-------------------------------------------------------------------------------

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
data = jtag.read(1024, source=2) # one second of raw LPF samples

data = [ part for x in data for part in (x & 0xFFFF, (x >> 16) & 0xFFFF) ]

for n in range(len(data)):
    if data[n] >= 0x8000:
        data[n] -= 0x10000;

data = np.array(data)
data = data[0::2] + 1j*data[1::2]

print('Done')
#-------------------------------------------------------------------------------

plt.figure()

plt.plot(np.real(data), label=f'Real')
plt.plot(np.imag(data), label=f'Imag')

plt.xlabel("Sample")
plt.ylabel("Value")
plt.title("Data")
plt.grid(True)
plt.legend(ncol=1)
plt.tight_layout()
plt.show()
#-------------------------------------------------------------------------------

