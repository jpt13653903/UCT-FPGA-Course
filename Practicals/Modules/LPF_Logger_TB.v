`timescale 1ns/1ps
module LPF_Logger_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

reg  ipGo;
wire opBusy;

reg  [15:0]ipI;
reg  [15:0]ipQ;
reg        ipValid;

wire [ 9:0]ipAvalon_Address    = 0;
wire [ 3:0]ipAvalon_ByteEnable = 0;
wire       opAvalon_WaitRequest;
wire [31:0]ipAvalon_WriteData  = 0;
wire       ipAvalon_Write      = 0;
wire       ipAvalon_Read       = 0;
wire [31:0]opAvalon_ReadData;
wire       opAvalon_ReadDataValid;

LPF_Logger DUT(
  .ipClk                 (ipClk  ),
  .ipReset               (ipReset),

  .ipGo                  (ipGo  ),
  .opBusy                (opBusy),

  .ipI                   (ipI    ),
  .ipQ                   (ipQ    ),
  .ipValid               (ipValid),

  .ipAvalon_Address      (ipAvalon_Address      ),
  .ipAvalon_ByteEnable   (ipAvalon_ByteEnable   ),
  .opAvalon_WaitRequest  (opAvalon_WaitRequest  ),
  .ipAvalon_WriteData    (ipAvalon_WriteData    ),
  .ipAvalon_Write        (ipAvalon_Write        ),
  .ipAvalon_Read         (ipAvalon_Read         ),
  .opAvalon_ReadData     (opAvalon_ReadData     ),
  .opAvalon_ReadDataValid(opAvalon_ReadDataValid)
);
//------------------------------------------------------------------------------

initial begin
  ipGo <= 0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);

  ipGo <= 1;
  @(opBusy);
  @(posedge ipClk);
  ipGo <= 0;
end
//------------------------------------------------------------------------------

int n = 0;
always begin
  @(posedge ipGo);

  forever begin
    @(posedge ipClk);

    ipI     <= n++;
    ipQ     <= n++;
    ipValid <= 1;

    @(posedge ipClk);
    ipValid <= 0;

    #980; // about 1 MSps, so that the simulation runs faster
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

