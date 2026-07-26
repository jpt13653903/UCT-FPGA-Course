module PWM(
  input      ipClk,

  input [7:0]ipData, // Unsigned duty-cycle
  input      ipValid,

  output reg opOutput
);
//------------------------------------------------------------------------------

reg [7:0]D;
reg [7:0]Count = 0; // Initialisation for simulation only
//------------------------------------------------------------------------------

always @(posedge ipClk) begin
  if(ipValid) begin // Synchronise to the input data
    Count <= 0;
    D     <= ipData;
  end else begin
    Count <= Count + 1'b1;
  end

  opOutput <= (D > Count);
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

