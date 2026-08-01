`timescale 1ns/1ps
module Filter_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

reg  [15:0]ipI     = 0;
reg  [15:0]ipQ     = 0;
reg        ipValid = 0;

wire [15:0]opI;
wire [15:0]opQ;
wire       opValid;

Filter DUT(
  .ipClk,

  .ipI,
  .ipQ,
  .ipValid,

  .opI,
  .opQ,
  .opValid
);
//------------------------------------------------------------------------------

always begin
  @(posedge ipClk);
  ipI     <= ipI + 1'b1;
  ipQ     <= ipQ + 1'b1;
  ipValid <= 1'b1;

  @(posedge ipClk);
  ipValid <= 1'b0;

  #980;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------


