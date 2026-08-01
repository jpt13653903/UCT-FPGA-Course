module Filter( // TODO: Change from sub-sampler to FIR filter
  input ipClk,

  input      [15:0]ipI,
  input      [15:0]ipQ,
  input            ipValid,

  output reg [15:0]opI,
  output reg [15:0]opQ,
  output reg       opValid
);
//------------------------------------------------------------------------------

reg [7:0]Count = 0;

always @(posedge ipClk) begin
  opI <= ipI;
  opQ <= ipQ;

  if(~|Count) opValid <= ipValid;
  else        opValid <= 1'b0;

  if(ipValid) Count <= Count + 1'b1;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

