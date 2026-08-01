module RampGenerator(
  input ipClk,
  input ipClkEnable,
  input ipReset,

  input      [23:0]ipStart,
  input      [23:0]ipStop,
  input      [23:0]ipStep,

  output reg [23:0]opFrequency,
  output reg       opStartStrobe
);
//------------------------------------------------------------------------------

reg       Reset;
reg [13:0]Count;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opFrequency   <= ipStart;
    opStartStrobe <= 1'b0;

    Count <= 0;

  end else if(ipClkEnable) begin
    if(Count == 9727) begin // exactly 38 LPF samples
      Count <= 0;
      opFrequency   <= ipStart;
      opStartStrobe <= 1'b1;

    end else begin
      Count <= Count + 1'b1;
      if(opFrequency < ipStop)
        opFrequency <= opFrequency + ipStep;
      opStartStrobe <= 1'b0;
    end

  end else begin
    opStartStrobe <= 1'b0;
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------


