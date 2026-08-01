import quartustcl

class Jtag():
    def __init__(self):
        self.quartus = quartustcl.QuartusTcl()
        self.hardware_name  = None # Blaster name
        self.device_name    = None # Device  name
    #---------------------------------------------------------------------------

    def open(self): #-- Open connection to the usb blaster and the target device
        try:
            hardware_names =self.quartus.parse(self.quartus.get_hardware_names(""))
            self.hardware_name = hardware_names[0]
            print("Taking first hardware found: ",self.hardware_name)
            #-------------------------------------------------------------------

            try:
                device_names     = self.quartus.parse(self.quartus.get_device_names(hardware_name=self.hardware_name))
                self.device_name = device_names[0]
                print("Taking first device found  : ",self.device_name)
                # Open Connection

                self.quartus.open_device(hardware_name=self.hardware_name, device_name=self.device_name)
            except:
                print("No Device found")
        except:
            print("No USB Blaster")
    #---------------------------------------------------------------------------

    def write(self, data_dwords):
        """ Write an array of d-words """

        print(f'Converting data to hex string')
        data = [ f'{data_dwords[n]:08X}' for n in reversed(range(len(data_dwords))) ]
        data = ''.join(data)

        length     = len(data)
        length     = length // 2
        bit_length = length * 8
        print(f'Writing {length} bytes ({bit_length} bits)')

        try:
            self.quartus.device_lock(timeout = 1) #- Lock access to device
            self.quartus.eval( 'device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value')
            self.quartus.eval(f'device_virtual_dr_shift -dr_value {data} -instance_index 0 -length {bit_length} -value_in_hex -no_captured_dr_value')
            self.quartus.eval( 'device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value')

        finally:
            self.quartus.device_unlock() #- Unlock device
    #---------------------------------------------------------------------------

    def read(self, length, source=1):
        """ Return an array of {length} d-words

        source:
            1 => SDRAM
            2 => LPF Logger
        """

        assert source >= 1 and source <= 2

        data = '00000000' * length
        bit_length = length * 32
        print(f'Reading {length} d-words ({bit_length} bits) from source {source}')

        # The first nibble is junk due to the read latency of the buffers
        data       += '0'
        bit_length += 4

        try:
            self.quartus.device_lock(timeout = 1) #- Lock access to device
            self.quartus.eval(f'device_virtual_ir_shift -instance_index 0 -ir_value {source} -no_captured_ir_value')
            data = self.quartus.eval(f'device_virtual_dr_shift -instance_index 0 -length {bit_length} -value_in_hex -dr_value {data}')

        finally:
            self.quartus.device_unlock() #- Unlock device

        print(f'Converting hex string to d-word array')
        data = data[0:-1]
        data = [ int(data[n:n+8], 16) for n in reversed(range(0, len(data), 8)) ]

        return data
    #---------------------------------------------------------------------------

    def close(self):
        self.quartus.close_device()

    def __del__(self):
        self.quartus.close_device()
#-------------------------------------------------------------------------------

