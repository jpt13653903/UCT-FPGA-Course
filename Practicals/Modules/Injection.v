module Injection(
  input  ipClk,
  input  ipReset,

  output reg [24:0]opSDRAM_Address,
  output     [ 1:0]opSDRAM_ByteEnable,
  input            ipSDRAM_WaitRequest,
  output     [15:0]opSDRAM_WriteData,
  output           opSDRAM_Write,
  output reg       opSDRAM_Read,
  input      [15:0]ipSDRAM_ReadData,
  input            ipSDRAM_ReadDataValid,

  output reg [15:0]opData,
  output reg       opValid
);
//------------------------------------------------------------------------------

reg  [ 9:0]RdAddress;
wire       RdReady;
wire [15:0]RdData;

ReadCache #(16) InjectionBuffer(
  .ipClk                 (ipClk  ),
  .ipReset               (ipReset),

  .opMemory_Address      (opSDRAM_Address      ),
  .opMemory_ByteEnable   (opSDRAM_ByteEnable   ),
  .ipMemory_WaitRequest  (ipSDRAM_WaitRequest  ),
  .opMemory_WriteData    (opSDRAM_WriteData    ),
  .opMemory_Write        (opSDRAM_Write        ),
  .opMemory_Read         (opSDRAM_Read         ),
  .ipMemory_ReadData     (ipSDRAM_ReadData     ),
  .ipMemory_ReadDataValid(ipSDRAM_ReadDataValid),

  .ipRdAddress           (RdAddress),
  .opRdReady             (RdReady  ),
  .opRdData              (RdData   )
);
//------------------------------------------------------------------------------

reg       Reset;
reg [10:0]Count = 0;

always @(posedge ipClk) begin: Output
  Reset <= ipReset;
  Count <= Count + 1'b1;

  if(Reset) begin
    opData    <= 0;
    opValid   <= 0;

    RdAddress <= 16'h0;

  end else if(RdReady && ~|Count) begin
    opData    <= RdData;
    opValid   <= 1'b1;
    RdAddress <= RdAddress + 1'b1;

  end else begin
    opValid <= 1'b0;
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

