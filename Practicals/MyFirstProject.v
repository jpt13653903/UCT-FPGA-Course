module MyFirstProject(
  input  ipClk_50M,
  input  ipnReset,

  input      [ 9:0]ipSwitch,
  output reg [ 9:0]opLED,

  output opADXL345_nCS,
  output opADXL345_SClk,
  output opADXL345_SDI,
  input  ipADXL345_SDO,

  output       opClk_SDRAM,
  output       opSDRAM_CKE,
  output       opSDRAM_nCS,
  output       opSDRAM_nRAS,
  output       opSDRAM_nCAS,
  output       opSDRAM_nWE,
  output [12:0]opSDRAM_A,
  output [ 1:0]opSDRAM_BA,
  output [ 1:0]opSDRAM_DQM,
  inout  [15:0]bpSDRAM_DQ,

  output [11:1]opDebug,
  output       opPA_Enable,
  output       opPWM,

  output [ 2:1]opADC_nCS,
  inout  [ 3:0]bpADC_CR_DB,
  output       opADC_nWR,
  output       opADC_nRD,
  output       opADC_CONVST,
  input  [ 2:1]ipADC_nEOC,
  input  [13:2]ipADC_DB,

  inout  [15:0]bpArduino_IO
);
//------------------------------------------------------------------------------

assign bpArduino_IO = 'hZ;
//------------------------------------------------------------------------------

assign opDebug     = 0;
assign opPA_Enable = ipSwitch[0];
//------------------------------------------------------------------------------

RdRegisters_Struct RdRegisters;
WrRegisters_Struct WrRegisters;

Registers Registers_Inst(
  .ipClk          (Clk_100M),
  .ipReset        (Reset),

  .ipRdRegisters  (RdRegisters),
  .opWrRegisters  (WrRegisters),

  .ipAddress      (Registers_Address      ),
  .ipByteEnable   (Registers_ByteEnable   ),
  .opWaitRequest  (Registers_WaitRequest  ),
  .ipWriteData    (Registers_WriteData    ),
  .ipWrite        (Registers_Write        ),
  .ipRead         (Registers_Read         ),
  .opReadData     (Registers_ReadData     ),
  .opReadDataValid(Registers_ReadDataValid)
);
//------------------------------------------------------------------------------

wire Clk_100M;
wire PLL_Locked;

SDRAM_PLL SDRAM_PLL_Inst(
  .inclk0(ipClk_50M),
  .c0    (Clk_100M),
  .c1    (opClk_SDRAM),
  .locked(PLL_Locked)
);
//------------------------------------------------------------------------------

reg Reset;
always @(posedge Clk_100M) Reset <= ~PLL_Locked || ~ipnReset;
//------------------------------------------------------------------------------

wire [29:0]Master_Address;
wire [ 3:0]Master_ByteEnable;
wire       Master_WaitRequest;
wire [31:0]Master_WriteData;
wire       Master_Write;
wire       Master_Read;
wire [31:0]Master_ReadData;
wire       Master_ReadDataValid;

wire [ 7:0]Registers_Address;
wire [ 3:0]Registers_ByteEnable;
wire       Registers_WaitRequest;
wire [31:0]Registers_WriteData;
wire       Registers_Write;
wire       Registers_Read;
wire [31:0]Registers_ReadData;
wire       Registers_ReadDataValid;

wire [24:0]Injection_Address;
wire [ 1:0]Injection_ByteEnable;
wire       Injection_WaitRequest;
wire [15:0]Injection_WriteData;
wire       Injection_Write;
wire       Injection_Read;
wire [15:0]Injection_ReadData;
wire       Injection_ReadDataValid;

wire [23:0]ADC_Logger_Address;
wire [ 3:0]ADC_Logger_ByteEnable;
wire       ADC_Logger_WaitRequest;
wire [31:0]ADC_Logger_WriteData;
wire       ADC_Logger_Write;
wire       ADC_Logger_Read;
wire [31:0]ADC_Logger_ReadData;
wire       ADC_Logger_ReadDataValid;

wire [ 9:0]LPF_Logger_Address;
wire [ 3:0]LPF_Logger_ByteEnable;
wire       LPF_Logger_WaitRequest;
wire [31:0]LPF_Logger_WriteData;
wire       LPF_Logger_Write;
wire       LPF_Logger_Read;
wire [31:0]LPF_Logger_ReadData;
wire       LPF_Logger_ReadDataValid;

wire [24:0]SDRAM_Address;
wire [ 1:0]SDRAM_ByteEnable;
wire       SDRAM_WaitRequest;
wire [15:0]SDRAM_WriteData;
wire       SDRAM_Write;
wire       SDRAM_Read;
wire [15:0]SDRAM_ReadData;
wire       SDRAM_ReadDataValid;

QSys QSys_Inst (
  .clk_clk                 (Clk_100M                ), // In
  .reset_reset_n           (~Reset                  ), // In

  .master_address          (Master_Address          ), // In
  .master_byteenable       (Master_ByteEnable       ), // In
  .master_burstcount       (1                       ), // In
  .master_waitrequest      (Master_WaitRequest      ), // Out
  .master_writedata        (Master_WriteData        ), // In
  .master_write            (Master_Write            ), // In
  .master_read             (Master_Read             ), // In
  .master_readdata         (Master_ReadData         ), // Out
  .master_readdatavalid    (Master_ReadDataValid    ), // Out
  .master_debugaccess      (0                       ), // In

  .registers_address       (Registers_Address       ), // Out
  .registers_byteenable    (Registers_ByteEnable    ), // Out
  .registers_burstcount    (                        ), // Out
  .registers_waitrequest   (Registers_WaitRequest   ), // In
  .registers_writedata     (Registers_WriteData     ), // Out
  .registers_write         (Registers_Write         ), // Out
  .registers_read          (Registers_Read          ), // Out
  .registers_readdata      (Registers_ReadData      ), // In
  .registers_readdatavalid (Registers_ReadDataValid ), // In
  .registers_debugaccess   (                        ), // Out

  .injection_address       (Injection_Address       ), // In
  .injection_byteenable    (Injection_ByteEnable    ), // In
  .injection_burstcount    (1                       ), // In
  .injection_waitrequest   (Injection_WaitRequest   ), // Out
  .injection_writedata     (Injection_WriteData     ), // In
  .injection_write         (Injection_Write         ), // In
  .injection_read          (Injection_Read          ), // In
  .injection_readdata      (Injection_ReadData      ), // Out
  .injection_readdatavalid (Injection_ReadDataValid ), // Out
  .injection_debugaccess   (0                       ), // In

  .adc_logger_address      (ADC_Logger_Address      ), // In
  .adc_logger_byteenable   (ADC_Logger_ByteEnable   ), // In
  .adc_logger_burstcount   (1                       ), // In
  .adc_logger_waitrequest  (ADC_Logger_WaitRequest  ), // Out
  .adc_logger_writedata    (ADC_Logger_WriteData    ), // In
  .adc_logger_write        (ADC_Logger_Write        ), // In
  .adc_logger_read         (ADC_Logger_Read         ), // In
  .adc_logger_readdata     (ADC_Logger_ReadData     ), // Out
  .adc_logger_readdatavalid(ADC_Logger_ReadDataValid), // Out
  .adc_logger_debugaccess  (0                       ), // In

  .lpf_logger_address      (LPF_Logger_Address      ), // Out
  .lpf_logger_byteenable   (LPF_Logger_ByteEnable   ), // Out
  .lpf_logger_burstcount   (                        ), // Out
  .lpf_logger_waitrequest  (LPF_Logger_WaitRequest  ), // In
  .lpf_logger_writedata    (LPF_Logger_WriteData    ), // Out
  .lpf_logger_write        (LPF_Logger_Write        ), // Out
  .lpf_logger_read         (LPF_Logger_Read         ), // Out
  .lpf_logger_readdata     (LPF_Logger_ReadData     ), // In
  .lpf_logger_readdatavalid(LPF_Logger_ReadDataValid), // In
  .lpf_logger_debugaccess  (                        ), // Out

  .sdram_address           (SDRAM_Address           ), // Out
  .sdram_byteenable        (SDRAM_ByteEnable        ), // Out
  .sdram_burstcount        (                        ), // Out
  .sdram_waitrequest       (SDRAM_WaitRequest       ), // In
  .sdram_writedata         (SDRAM_WriteData         ), // Out
  .sdram_write             (SDRAM_Write             ), // Out
  .sdram_read              (SDRAM_Read              ), // Out
  .sdram_readdata          (SDRAM_ReadData          ), // In
  .sdram_readdatavalid     (SDRAM_ReadDataValid     ), // In
  .sdram_debugaccess       (                        )  // Out
);
//------------------------------------------------------------------------------

ADXL345 #(
  .Clock_kHz(50_000),
  .Baud_kHz ( 5_000)
) G_Sensor (
  .ipClk  (ipClk_50M),
  .ipReset(Reset    ),

  .opValue(RdRegisters.G_Sensor),

  .opnCS  (opADXL345_nCS ),
  .opSClk (opADXL345_SClk),
  .opSDI  (opADXL345_SDI ),
  .ipSDO  (ipADXL345_SDO )
);
//------------------------------------------------------------------------------

IS42S16320D SDRAM_Inst(
  .ipClk          (Clk_100M),
  .ipReset        (Reset   ),

  .ipAddress      (SDRAM_Address      ),
  .ipByteEnable   (2'b11               ),
  .opWaitRequest  (SDRAM_WaitRequest  ),

  .ipWriteData    (SDRAM_WriteData    ),
  .ipWrite        (SDRAM_Write        ),

  .ipRead         (SDRAM_Read         ),
  .opReadData     (SDRAM_ReadData     ),
  .opReadDataValid(SDRAM_ReadDataValid),

  .opCKE          (opSDRAM_CKE ),
  .opnCS          (opSDRAM_nCS ),
  .opnRAS         (opSDRAM_nRAS),
  .opnCAS         (opSDRAM_nCAS),
  .opnWE          (opSDRAM_nWE ),
  .opA            (opSDRAM_A   ),
  .opBA           (opSDRAM_BA  ),
  .opDQM          (opSDRAM_DQM ),
  .bpDQ           (bpSDRAM_DQ  )
);
//------------------------------------------------------------------------------

assign RdRegisters.DE10.Switches = ipSwitch;

always_comb begin
  if(JTAG_Busy)
    opLED <= Master_Address[23:14];

  else if(WrRegisters.DE10.RegistersToLEDs)
    opLED <= WrRegisters.DE10.LEDs;

  else if(RdRegisters.Logger.ADC_Busy)
    opLED <= ADC_Logger_Address[23:14];

  else
    opLED <= Injection_Address[24:15];
end
//------------------------------------------------------------------------------

wire JTAG_Busy;

VirtualJTAG_MM VirtualJTAG_MM_Inst(
  .ipClk                 (Clk_100M),
  .ipReset               (Reset),

  .opBusy                (JTAG_Busy),

  .opAvalon_Address      (Master_Address      ),
  .opAvalon_ByteEnable   (Master_ByteEnable   ),
  .ipAvalon_WaitRequest  (Master_WaitRequest  ),

  .opAvalon_WriteData    (Master_WriteData    ),
  .opAvalon_Write        (Master_Write        ),

  .opAvalon_Read         (Master_Read         ),
  .ipAvalon_ReadData     (Master_ReadData     ),
  .ipAvalon_ReadDataValid(Master_ReadDataValid)
);
//------------------------------------------------------------------------------

wire [15:0]Injection_Data;
wire       Injection_Valid;

// Injection Injection_Inst(
//   .ipClk  (Clk_100M),
//   .ipReset(Reset | JTAG_Busy),
//
//   .opSDRAM_Address      (Injection_Address      ),
//   .opSDRAM_ByteEnable   (Injection_ByteEnable   ),
//   .ipSDRAM_WaitRequest  (Injection_WaitRequest  ),
//   .opSDRAM_WriteData    (Injection_WriteData    ),
//   .opSDRAM_Write        (Injection_Write        ),
//   .opSDRAM_Read         (Injection_Read         ),
//   .ipSDRAM_ReadData     (Injection_ReadData     ),
//   .ipSDRAM_ReadDataValid(Injection_ReadDataValid),
//
//   .opData (Injection_Data),
//   .opValid(Injection_Valid)
// );

assign Injection_Address     = 0;
assign Injection_ByteEnable  = 0;
assign Injection_WaitRequest = 0;
assign Injection_WriteData   = 0;
assign Injection_Write       = 0;
assign Injection_Read        = 0;

assign Injection_Data  = 0;
assign Injection_Valid = 0;
//------------------------------------------------------------------------------

wire [13:0]ADC_Samples[15:0];
wire       ADC_Valid;

wire [ 3:0]opADC_CR;
wire       enADC_CR;

assign bpADC_CR_DB = enADC_CR ? opADC_CR : 4'hZ;

MAX11059 #(
  .Clock_kHz       (100_000),
  .SamplingRate_kHz(97.656_250)
)ADC_Inst(
  .ipClk    (Clk_100M),
  .ipReset  (Reset),

  .opSamples(ADC_Samples),
  .opValid  (ADC_Valid  ),

  .opnCS    (opADC_nCS   ),
  .opCR     (opADC_CR    ),
  .enCR     (enADC_CR    ),
  .opnWR    (opADC_nWR   ),
  .opnRD    (opADC_nRD   ),
  .opCONVST (opADC_CONVST),
  .ipnEOC   (ipADC_nEOC  ),
  .ipDB     ({ ipADC_DB, bpADC_CR_DB[3:2] })
);
//------------------------------------------------------------------------------

wire [23:0]NCO_Frequency;
wire       RampStart;

RampGenerator RampGenerator_Inst(
  .ipClk        (Clk_100M ),
  .ipClkEnable  (ADC_Valid),
  .ipReset      (Reset    ),

  .ipStart      (WrRegisters.DSP.RampStart),
  .ipStop       (WrRegisters.DSP.RampStop ),
  .ipStep       (WrRegisters.DSP.RampStep ),

  .opFrequency  (NCO_Frequency),
  .opStartStrobe(RampStart)
);
//------------------------------------------------------------------------------

wire [8:0]NCO_Sin;
wire [8:0]NCO_Cos;

NCO NCO_Inst(
  .ipClk      (Clk_100M),
  .ipClkEnable(ADC_Valid),
  .ipReset    (Reset),

  .ipFrequency(NCO_Frequency),

  .opSin      (NCO_Sin),
  .opCos      (NCO_Cos)
);
//------------------------------------------------------------------------------

wire [15:0]Mixer_I;
wire [15:0]Mixer_Q;
wire       Mixer_Valid;

Mixer Mixer_Inst(
  .ipClk    (Clk_100M),

  .ipSamples(ADC_Samples[7]), // The microphone channel
  .ipValid  (ADC_Valid     ),

  .ipSin    (NCO_Sin),
  .ipCos    (NCO_Cos),

  .opI      (Mixer_I    ),
  .opQ      (Mixer_Q    ),
  .opValid  (Mixer_Valid)
);
//------------------------------------------------------------------------------

wire [23:0]Filter_I;
wire [23:0]Filter_Q;
wire       Filter_Valid;

Filter Filter_I_Inst(
  .ipClk  (Clk_100M),
  .ipReset(Reset   ),

  .ipData (Mixer_I    ),
  .ipValid(Mixer_Valid),

  .opData (Filter_I    ),
  .opValid(Filter_Valid)
);

Filter Filter_Q_Inst(
  .ipClk  (Clk_100M),
  .ipReset(Reset   ),

  .ipData (Mixer_Q    ),
  .ipValid(Mixer_Valid),

  .opData (Filter_Q),
  .opValid()
);
//------------------------------------------------------------------------------

wire [7:0]DutyCycle;
wire      DutyCycleValid;

NoiseShaper #(
  .InputN (9),
  .OutputN(8),
  .N      (2)  // Order of the noise shaper
)NoiseShaper_Inst(
  .ipClk  (Clk_100M),
  .ipReset(Reset),

  // .ipData ({ ~Injection_Data[15], Injection_Data[14:0] }), // Signed to offset-binary
  // .ipValid(Injection_Valid),

  .ipData ({ ~NCO_Sin[8], NCO_Sin[7:0] }), // Signed to offset-binary
  .ipValid(ADC_Valid),

  .opData (DutyCycle),
  .opValid(DutyCycleValid)
);
//------------------------------------------------------------------------------

PWM PWM_Inst(
  .ipClk  (Clk_100M),

  .ipData (DutyCycle),
  .ipValid(DutyCycleValid),

  .opOutput(opPWM)
);
//------------------------------------------------------------------------------

ADC_Logger ADC_Logger_Inst(
  .ipClk  (Clk_100M),
  .ipReset(Reset),

  .ipGo                  (WrRegisters.Logger.ADC_Go  ),
  .opBusy                (RdRegisters.Logger.ADC_Busy),

  .ipSamples             (ADC_Samples),
  .ipValid               (ADC_Valid  ),

  .opAvalon_Address      (ADC_Logger_Address      ),
  .opAvalon_ByteEnable   (ADC_Logger_ByteEnable   ),
  .ipAvalon_WaitRequest  (ADC_Logger_WaitRequest  ),
  .opAvalon_WriteData    (ADC_Logger_WriteData    ),
  .opAvalon_Write        (ADC_Logger_Write        ),
  .opAvalon_Read         (ADC_Logger_Read         ),
  .ipAvalon_ReadData     (ADC_Logger_ReadData     ),
  .ipAvalon_ReadDataValid(ADC_Logger_ReadDataValid)
);
//------------------------------------------------------------------------------

LPF_Logger LPF_Logger_Inst(
  .ipClk      (Clk_100M),
  .ipReset    (Reset),
  .ipRampStart(RampStart),

  .ipGo                  (WrRegisters.Logger.LPF_Go  ),
  .opBusy                (RdRegisters.Logger.LPF_Busy),

  .ipI                   (Filter_I    ),
  .ipQ                   (Filter_Q    ),
  .ipValid               (Filter_Valid),

  .ipAvalon_Address      (LPF_Logger_Address      ),
  .ipAvalon_ByteEnable   (LPF_Logger_ByteEnable   ),
  .opAvalon_WaitRequest  (LPF_Logger_WaitRequest  ),
  .ipAvalon_WriteData    (LPF_Logger_WriteData    ),
  .ipAvalon_Write        (LPF_Logger_Write        ),
  .ipAvalon_Read         (LPF_Logger_Read         ),
  .opAvalon_ReadData     (LPF_Logger_ReadData     ),
  .opAvalon_ReadDataValid(LPF_Logger_ReadDataValid)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

