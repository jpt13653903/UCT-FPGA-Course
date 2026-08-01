import time
from registers import *
#-------------------------------------------------------------------------------


chromatic_scale = [ 220 * 2**(n/12) for n in range(13) ]
major_scale = [ chromatic_scale[n] for n in [0, 2, 4, 5, 7, 9, 11, 12, 12, 11, 9, 7, 5, 4, 2, 0] ]
minor_scale = [ chromatic_scale[n] for n in [0, 2, 3, 5, 7, 9, 10, 12, 12, 10, 9, 7, 5, 3, 2, 0] ]

major_apejo = [ chromatic_scale[n] for n in [0, 4, 7, 12, 7, 4, 0] ]
minor_apejo = [ chromatic_scale[n] for n in [0, 3, 7, 12, 7, 3, 0] ]

tune = [ major_scale[n] for n in [4, 3, 3, 4, 1, 1, 0, 1, 2, 3, 4, 4, 4, 4, 2, 2, 3, 1, 1, 0, 2, 4, 4, 0] ]

write_register(Regs.DSP.RampStep, 0)
def set_frequency(f):
    write_register(Regs.DSP.RampStart, round(f*10.24e-6*2**24))
    write_register(Regs.DSP.RampStop,  round(f*10.24e-6*2**24))

for note in chromatic_scale:
    set_frequency(note)
    time.sleep(0.5)

time.sleep(2)

for note in minor_scale:
    set_frequency(note)
    time.sleep(0.5)

time.sleep(2)

for note in major_scale:
    set_frequency(note)
    time.sleep(0.5)

time.sleep(2)

for note in minor_apejo:
    set_frequency(note)
    time.sleep(0.5)

time.sleep(2)

for note in major_apejo:
    set_frequency(note)
    time.sleep(0.5)

time.sleep(2)

for note in tune:
    set_frequency(note)
    time.sleep(0.5)

time.sleep(2)
#-------------------------------------------------------------------------------

