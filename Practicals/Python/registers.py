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

class Regs:
    class DE10:
        Switches        = 0x00
        RegistersToLEDs = 0x01
        LEDs            = 0x02

    class G_Sensor:
        X = 0x10
        Y = 0x11
        Z = 0x12

    class DSP:
        NCO_Frequency = 0x20

    class Logger:
        ADC_Go   = 0x30
        ADC_Busy = 0x31
        LPF_Go   = 0x32
        LPF_Busy = 0x33
#-------------------------------------------------------------------------------

