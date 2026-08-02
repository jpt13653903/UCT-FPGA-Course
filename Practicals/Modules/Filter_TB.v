`timescale 1ns/1ps
module Filter_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

reg  [15:0]ipData;
reg        ipValid;

wire [23:0]opData;
wire       opValid;

Filter DUT(
  .ipClk  (ipClk  ),
  .ipReset(ipReset),

  .ipData (ipData ),
  .ipValid(ipValid),

  .opData (opData ),
  .opValid(opValid)
);
//------------------------------------------------------------------------------

always begin
  @(posedge ipClk);
  if($time < 10_000_000) begin
    ipData <= 0;

  end else if($time < 20_000_000) begin
    ipData <= 16'h4000;

  end else if($time < 30_000_000) begin
    ipData <= 16'hC000;

  end else if($time < 40_000_000) begin
    ipData <= 16'h7FFF;

  end else if($time < 50_000_000) begin
    ipData <= 16'h8000;

  end else begin
    ipData <= 0;
  end

  ipValid <= 1'b1;

  @(posedge ipClk);
  ipValid <= 1'b0;

  #980;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------


