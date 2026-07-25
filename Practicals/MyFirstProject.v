module MyFirstProject(
  input  ipClk_50M,
  input  ipnReset,

  input  [ 9:0]ipSwitch,
  output [ 9:0]opLED,

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
  inout  [15:0]bpSDRAM_DQ
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
wire       Master_Write = 0;
wire       Master_Read  = 0;
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

wire [24:0]SDRAM_Address;
wire [ 1:0]SDRAM_ByteEnable;
wire       SDRAM_WaitRequest;
wire [15:0]SDRAM_WriteData;
wire       SDRAM_Write;
wire       SDRAM_Read;
wire [15:0]SDRAM_ReadData;
wire       SDRAM_ReadDataValid;

QSys QSys_Inst (
  .clk_clk                (Clk_100M               ), // In
  .reset_reset_n          (~Reset                 ), // In

  .master_address         (Master_Address         ), // In
  .master_byteenable      (Master_ByteEnable      ), // In
  .master_burstcount      (1                      ), // In
  .master_waitrequest     (Master_WaitRequest     ), // Out
  .master_writedata       (Master_WriteData       ), // In
  .master_write           (Master_Write           ), // In
  .master_read            (Master_Read            ), // In
  .master_readdata        (Master_ReadData        ), // Out
  .master_readdatavalid   (Master_ReadDataValid   ), // Out
  .master_debugaccess     (0                      ), // In

  .registers_address      (Registers_Address      ), // Out
  .registers_byteenable   (Registers_ByteEnable   ), // Out
  .registers_burstcount   (                       ), // Out
  .registers_waitrequest  (Registers_WaitRequest  ), // In
  .registers_writedata    (Registers_WriteData    ), // Out
  .registers_write        (Registers_Write        ), // Out
  .registers_read         (Registers_Read         ), // Out
  .registers_readdata     (Registers_ReadData     ), // In
  .registers_readdatavalid(Registers_ReadDataValid), // In
  .registers_debugaccess  (                       ), // Out

  .sdram_address          (SDRAM_Address          ), // Out
  .sdram_byteenable       (SDRAM_ByteEnable       ), // Out
  .sdram_burstcount       (                       ), // Out
  .sdram_waitrequest      (SDRAM_WaitRequest      ), // In
  .sdram_writedata        (SDRAM_WriteData        ), // Out
  .sdram_write            (SDRAM_Write            ), // Out
  .sdram_read             (SDRAM_Read             ), // Out
  .sdram_readdata         (SDRAM_ReadData         ), // In
  .sdram_readdatavalid    (SDRAM_ReadDataValid    ), // In
  .sdram_debugaccess      (                       )  // Out
);
//------------------------------------------------------------------------------

wire [15:0]G_Sensor_X;
wire [15:0]G_Sensor_Y;
wire [15:0]G_Sensor_Z;

ADXL345 #(
  .Clock_kHz(50_000),
  .Baud_kHz ( 5_000)
) G_Sensor (
  .ipClk  (ipClk_50M),
  .ipReset(Reset    ),

  .opX    (G_Sensor_X),
  .opY    (G_Sensor_Y),
  .opZ    (G_Sensor_Z),

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

assign Registers_WaitRequest = 0;

always @(posedge Clk_100M) begin
  if(Reset) begin
    opLED <= 0;

  end else if(Registers_Write) begin
    case(Registers_Address)
      8'h01: begin
        if(Registers_ByteEnable[0]) opLED[7:0] <= Registers_WriteData[7:0];
        if(Registers_ByteEnable[1]) opLED[9:8] <= Registers_WriteData[9:8];
      end
    endcase
  end

  case(Registers_Address)
    8'h00: Registers_ReadData <= ipSwitch;
    8'h01: Registers_ReadData <= opLED;

    8'h10: Registers_ReadData <= { {16{G_Sensor_X[15]}}, G_Sensor_X };
    8'h11: Registers_ReadData <= { {16{G_Sensor_Y[15]}}, G_Sensor_Y };
    8'h12: Registers_ReadData <= { {16{G_Sensor_Z[15]}}, G_Sensor_Z };
  endcase
  Registers_ReadDataValid <= Registers_Read;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

