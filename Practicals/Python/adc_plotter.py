import time
from registers import *
from Jtag import *

import matplotlib.pyplot as plt
#-------------------------------------------------------------------------------

print('Starting data log');
write_register(Regs.Logger.ADC_Go, 0)
write_register(Regs.Logger.ADC_Go, 1)

while not read_register(Regs.Logger.ADC_Busy):
    time.sleep(0.1)

print('Data log in progress');
write_register(Regs.Logger.ADC_Go, 0)

while read_register(Regs.Logger.ADC_Busy):
    time.sleep(0.1)

print('Data log done');
#-------------------------------------------------------------------------------

jtag = Jtag()
jtag.open()
data = jtag.read(97656 * 8) # one second of raw ADC samples

data = [ part for x in data for part in (x & 0xFFFF, (x >> 16) & 0xFFFF) ]

for n in range(len(data)):
    if data[n] >= 0x8000:
        data[n] -= 0x10000;

data = [ data[n:n+16] for n in range(0, len(data), 16) ]

print('Done')
#-------------------------------------------------------------------------------

plt.figure()

for ch in range(16):
    channel = [sample[ch] for sample in data]
    plt.plot(channel, label=f'Ch {ch+1}')

plt.xlabel("Sample")
plt.ylabel("Value")
plt.title("16 Channel Data")
plt.grid(True)
plt.legend(ncol=2)
plt.tight_layout()
plt.show()
#-------------------------------------------------------------------------------

