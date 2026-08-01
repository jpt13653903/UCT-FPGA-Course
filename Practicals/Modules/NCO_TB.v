`timescale 1ns/1ps
module NCO_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

reg ipClkEnable = 0;
always #10240 begin
  @(posedge(ipClk)) ipClkEnable <= 1;
  @(posedge(ipClk)) ipClkEnable <= 0;
end
//------------------------------------------------------------------------------

wire [23:0]ipFrequency = 24'h29F17; // 1 kHz

wire [ 8:0]opSin;
wire [ 8:0]opCos;

NCO DUT(
  .ipClk      (ipClk      ),
  .ipClkEnable(ipClkEnable),
  .ipReset    (ipReset    ),

  .ipFrequency(ipFrequency),

  .opSin      (opSin      ),
  .opCos      (opCos      )
);
//------------------------------------------------------------------------------


endmodule
//------------------------------------------------------------------------------

