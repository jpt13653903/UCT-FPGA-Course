import sys
import subprocess
#-------------------------------------------------------------------------------

class SystemConsole:
    def __init__(self):
        command = 'C:/altera_lite/25.1std/quartus/sopc_builder/bin/system-console.exe --cli --disable_readline'
        sys.stdout.flush()
        self.console = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        sys.stdout.flush()

    def __del__(self):
        self.console.kill()

    def dump_output(self):
        self.console.stdout.read1()

    def print_output(self):
        print(self.read_output()); sys.stdout.flush()

    def read_output(self):
        result = b''
        while True:
            out = self.console.stdout.read1(1)
            if out == b'%':
                # Read the space and exit
                out = self.console.stdout.read1(1)
                return bytes.decode(result, 'utf-8')
            else:
                result = result + out

    def cmd(self, cmd_string, verbose=True):
        if verbose:
            print(f'% {cmd_string}')
        self.console.stdin.write(bytes(f'{cmd_string}\n', 'utf-8'))
        self.console.stdin.flush()
#-------------------------------------------------------------------------------

