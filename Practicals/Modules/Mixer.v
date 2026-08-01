module Mixer(
  input ipClk,

  input      [13:0]ipSamples,
  input            ipValid,

  input      [ 8:0]ipSin,
  input      [ 8:0]ipCos,

  output reg [15:0]opI,
  output reg [15:0]opQ,
  output reg       opValid
);
//------------------------------------------------------------------------------

reg signed [22:0]Product_I;
reg signed [22:0]Product_Q;
reg              Valid;

always @(posedge ipClk) begin
  Product_I <= $signed(ipSamples) * $signed(ipCos);
  Product_Q <= $signed(ipSamples) * $signed(ipSin);
  Valid     <= ipValid;

  if(Product_I[22] == Product_I[21]) begin
    opI <= Product_I[21:6];
  end else begin
    if(Product_I[22]) opI <= 16'h8000;
    else              opI <= 16'h7FFF;
  end
  if(Product_Q[22] == Product_Q[21]) begin
    opQ <= Product_Q[21:6];
  end else begin
    if(Product_Q[22]) opQ <= 16'h8000;
    else              opQ <= 16'h7FFF;
  end
  opValid <= Valid;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

