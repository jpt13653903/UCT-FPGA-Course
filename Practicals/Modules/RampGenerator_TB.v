`timescale 1ns/1ps
module RampGenerator_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

reg ipClkEnable;

reg  [23:0]ipStart = 24'h1A36E3;
reg  [23:0]ipStop  = 24'h23A6CE;
reg  [23:0]ipStep  = 24'h40;

wire [23:0]opFrequency;
wire       opStartStrobe;

RampGenerator DUT(
  .ipClk        (ipClk      ),
  .ipClkEnable  (ipClkEnable),
  .ipReset      (ipReset    ),

  .ipStart      (ipStart),
  .ipStop       (ipStop ),
  .ipStep       (ipStep ),

  .opFrequency  (opFrequency),
  .opStartStrobe(opStartStrobe)
);
//------------------------------------------------------------------------------

always begin
  @(posedge ipClk);
  ipClkEnable <= 1'b1;

  @(posedge ipClk);
  ipClkEnable <= 1'b0;

  repeat(1022) @(posedge ipClk);
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------


