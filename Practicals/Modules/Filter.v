module Filter( // TODO: Change from sub-sampler to FIR filter
  input ipClk,
  input ipReset,

  input      [15:0]ipI,
  input      [15:0]ipQ,
  input            ipValid,

  output reg [15:0]opI,
  output reg [15:0]opQ,
  output reg       opValid
);
//------------------------------------------------------------------------------

reg      Reset;
reg [7:0]Count;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset)
    Count <= 0;
  else if(ipValid)
    Count <= Count + 1'b1;

  opI <= ipI;
  opQ <= ipQ;

  if(~|Count) opValid <= ipValid;
  else        opValid <= 1'b0;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

