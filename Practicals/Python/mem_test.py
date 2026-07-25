"""
Python based abstraction for the Altera System Console interface
-----------------------------------------------------------------------------"""

import sys
import time
from SystemConsole import *
#-------------------------------------------------------------------------------

print("Starting System Console..."); sys.stdout.flush()
fpga = SystemConsole()
fpga.print_output()

fpga.cmd('set masters [get_service_paths master]')
fpga.print_output()
fpga.cmd('set master [ lindex $masters 0 ]')
fpga.print_output()
fpga.cmd('open_service master $master')
fpga.print_output()

start = time.time()
for n in range(64):
    fpga.cmd('master_read_32 $master 0x04000000 1')
    fpga.print_output()
    fpga.cmd(f'master_write_32 $master 0x04000004 {n}')
    fpga.print_output()
end = time.time()
print(f'Verbose interface took {end - start} seconds'); sys.stdout.flush()

start = time.time()
for n in range(1024):
    fpga.cmd(f'master_write_32 $master 0x04000004 {n}', verbose=False)
    fpga.dump_output()
end = time.time()
print(f'Quiet write took {end - start} seconds'); sys.stdout.flush()

fpga.cmd(f'master_write_32 $master 0x04000004 0x55555555', verbose=False)
fpga.dump_output()

start = time.time()
fpga.cmd(f'master_write_32 $master 0x0 {{ 1 2 3 4 5 6 7 8 }}')
fpga.print_output()
end = time.time()
print(f'Writing 8 words took {end - start} seconds'); sys.stdout.flush()

fpga.cmd(f'master_read_32 $master 0x0 8')
fpga.print_output()

a = list(range(1024))
start = time.time()
fpga.cmd(f'master_write_32 $master 0x0 {{ {" ".join(map(str, a))} }}', verbose=True)
fpga.print_output()
end = time.time()
print(f'Writing 1024 words took {end - start} seconds'); sys.stdout.flush()
#-------------------------------------------------------------------------------

def read_register(address):
    fpga.cmd(f'master_read_32 $master {0x04000000 + address*4} 1', verbose=False)
    return int(fpga.read_output().strip(), 0)

def write_register(address, value):
    fpga.cmd(f'master_write_32 $master {0x04000000 + address*4} {value}', verbose=False)
    fpga.dump_output()
#-------------------------------------------------------------------------------

