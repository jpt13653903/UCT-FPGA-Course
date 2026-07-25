module MyFirstProject(
  input  ipClk_50M,
  input  ipnReset,

  input  [ 9:0]ipSwitch,
  output [ 9:0]opLED,

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

  output reg [15:0]opReadData
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

wire [24:0]Avalon_Address;
wire       Avalon_WaitRequest;

wire [15:0]Avalon_WriteData;
wire       Avalon_Write;

wire       Avalon_Read;
wire [15:0]Avalon_ReadData;
wire       Avalon_ReadDataValid;

IS42S16320D SDRAM_Inst(
  .ipClk          (Clk_100M),
  .ipReset        (Reset   ),

  .ipAddress      (Avalon_Address      ),
  .ipByteEnable   (2'b11               ),
  .opWaitRequest  (Avalon_WaitRequest  ),

  .ipWriteData    (Avalon_WriteData    ),
  .ipWrite        (Avalon_Write        ),

  .ipRead         (Avalon_Read         ),
  .opReadData     (Avalon_ReadData     ),
  .opReadDataValid(Avalon_ReadDataValid),

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

typedef enum { Write, Read, Done } STATE;
STATE State;

always @(posedge Clk_100M) begin
  if(Reset) begin
    Avalon_Address   <= 0;
    Avalon_WriteData <= 0;
    Avalon_Write     <= 0;
    Avalon_Read      <= 0;

    State <= Write;

  end else if(~Avalon_WaitRequest) begin
    case(State)
      Write: begin
        if(Avalon_Address == 25'h1FF_FFFE) State <= Read;
        if(Avalon_Write) begin
          Avalon_Address   <= Avalon_Address + 1;
          Avalon_WriteData <= Avalon_Address[15:0] + 1;
        end
        Avalon_Write <= 1;
      end

      Read: begin
        Avalon_Write <= 0;
        if(Avalon_Address == 25'h1FF_FFFE) State <= Done;
        Avalon_Address <= Avalon_Address + 1;
        Avalon_Read <= 1;
      end

      Done: begin
        Avalon_Read  <= 0;
        Avalon_Write <= 0;
      end

      default:;
    endcase
  end

  if(Avalon_ReadDataValid) opReadData <= Avalon_ReadData;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

