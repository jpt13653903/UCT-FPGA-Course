`timescale 1ns/1ps
module PWM_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

reg signed [15:0]Data;
reg              DataValid;

localparam real pi = 3.14159265358979323846;
always begin
  @(negedge ipReset)

  while(1) begin
    @(posedge ipClk);
    Data <= int'($sin(2*pi * 1e3 * ($time * 1e-9)) * 2**14);
    DataValid <= 1;

    @(posedge ipClk);
    DataValid <= 0;

    for(integer n = 0; n < 2046; n++) // 48.828 125 kSps
      @(posedge ipClk);
  end
end
//------------------------------------------------------------------------------

wire [7:0]DutyCycle;
wire      DutyCycleValid;

NoiseShaper #(
  .InputN (16),
  .OutputN( 8),
  .N      ( 4)  // Order of the noise shaper
)NoiseShaper_Inst(
  .ipClk  (ipClk),
  .ipReset(ipReset),

  .ipData ({ ~Data[15], Data[14:0] }), // Signed to unsigned
  .ipValid(DataValid),

  .opData (DutyCycle),
  .opValid(DutyCycleValid)
);
//------------------------------------------------------------------------------

wire opOutput;

PWM PWM_Inst(
  .ipClk  (ipClk),

  .ipData (DutyCycle),
  .ipValid(DutyCycleValid),

  .opOutput(opOutput)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

