"""
Python based abstraction for the Altera System Console interface
-----------------------------------------------------------------------------"""

import sys
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
#-------------------------------------------------------------------------------

def read_register(address):
    fpga.cmd(f'master_read_32 $master {0x04000000 + address*4} 1', verbose=False)
    return int(fpga.read_output().strip(), 0)

def write_register(address, value):
    fpga.cmd(f'master_write_32 $master {0x04000000 + address*4} {value}', verbose=False)
    fpga.dump_output()
#-------------------------------------------------------------------------------

print('\nRunning electronic level...'); sys.stdout.flush()
while True:
    X = read_register(0x10)
    Y = read_register(0x11)
    Z = read_register(0x12)

    if X & 0x80000000: X -= 0x100000000
    if Y & 0x80000000: Y -= 0x100000000
    if Z & 0x80000000: Z -= 0x100000000

    X //= 10;
    if X < -5: X = -5
    if X >  5: X =  5

    if X > 0: write_register(0x01, 0x30 >>  X)
    else:     write_register(0x01, 0x30 << -X)
#-------------------------------------------------------------------------------

