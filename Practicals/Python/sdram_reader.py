import sys
from Jtag import *
#-------------------------------------------------------------------------------

if len(sys.argv) < 2:
    print()
    print('Usage: python sdram_reader <number_of_dwords>')
    print()
    sys.exit(1)
#-------------------------------------------------------------------------------

N = int(sys.argv[1])

jtag = Jtag()
jtag.open()
data = jtag.read(N)

for n in range(N):
    print(f'0x{n:08x}: 0x{data[n]:08x}')

print('Done')
#-------------------------------------------------------------------------------

