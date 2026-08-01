import sys
from registers import *
#-------------------------------------------------------------------------------

print('\nRunning electronic level...'); sys.stdout.flush()

write_register(Regs.DE10.RegistersToLEDs, 1)
try:
    while True:
        X = read_register(Regs.G_Sensor.X)
        Y = read_register(Regs.G_Sensor.Y)
        Z = read_register(Regs.G_Sensor.Z)

        if X & 0x80000000: X -= 0x100000000
        if Y & 0x80000000: Y -= 0x100000000
        if Z & 0x80000000: Z -= 0x100000000

        print(f'{X}; {Y}; {Z}')

        X //= 10;
        if X < -5: X = -5
        if X >  5: X =  5

        if X > 0: write_register(Regs.DE10.LEDs, 0x30 >>  X)
        else:     write_register(Regs.DE10.LEDs, 0x30 << -X)

finally:
    write_register(Regs.DE10.RegistersToLEDs, 0)
#-------------------------------------------------------------------------------

