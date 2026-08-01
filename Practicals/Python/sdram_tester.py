import random
from Jtag import *
#-------------------------------------------------------------------------------

N = 1 * 2**20 // 4

print(f'Generating {N} d-words of random data...')
wr_data = [ random.randint(0, 2**32-1) for _ in range(N) ]

jtag = Jtag()
jtag.open()

jtag.write(wr_data)
rd_data = jtag.read(N)

print()

for n in range(N):
    try:
        assert wr_data[n] == rd_data[n]
    except:
        print(f'Assertion Error -- Word 0x{n:08x}: 0x{wr_data[n]:08x} -> 0x{rd_data[n]:08x}')
        for k in range(n-20, n+21):
            print(f'    Word 0x{k:08x}: 0x{wr_data[k]:08x} -> 0x{rd_data[k]:08x}')
        exit()

print('Done')
#-------------------------------------------------------------------------------

