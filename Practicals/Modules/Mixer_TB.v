`timescale 1ns/1ps
module Mixer_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

reg  [13:0]ipSamples;
reg        ipValid;

reg  [ 8:0]ipSin;
reg  [ 8:0]ipCos;

wire [15:0]opI;
wire [15:0]opQ;
wire       opValid;

Mixer DUT(
  .ipClk    (ipClk),

  .ipSamples(ipSamples),
  .ipValid  (ipValid  ),

  .ipSin    (ipSin),
  .ipCos    (ipCos),

  .opI      (opI    ),
  .opQ      (opQ    ),
  .opValid  (opValid)
);
//------------------------------------------------------------------------------

task Test(input int x, cos, sin, I, Q);
  begin
    @(posedge ipClk);
    ipSamples <= x;
    ipValid   <= 0;
    ipSin     <= sin;
    ipCos     <= cos;
    ipValid <= 1'b1;

    @(posedge ipClk);
    ipValid <= 1'b0;

    @(posedge opValid);
    assert (opI == I) else $error("Invalid I result, expecting %d", I);
    assert (opQ == Q) else $error("Invalid Q result, expecting %d", Q);
  end
endtask

const real pi = 3.1415926535898;

initial begin
  $display("Time: %1d ns  Edge cases", $time);
  Test(0, 0, 0, 0, 0);
  Test(0, 'h0ff, 'h0ff, 0, 0);
  Test('h1fff, 'h0ff, 'h0ff, 'h7f7c, 'h7f7c);
  Test('h1fff, 'h0ff, 'h100, 'h7f7c, 'h8004);
  Test('h2000, 'h0ff, 'h100, 'h8080, 'h7fff);

  $display("Time: %1d ns  11 kHz mixed with 10 kHz", $time);
  repeat(1000) begin
    int x, cos, sin;
    real I, Q;
    x   = int'((2**13-1) * $sin(2*pi*11e3*$time*1e-9));
    cos = int'((2** 8-1) * $cos(2*pi*10e3*$time*1e-9));
    sin = int'((2** 8-1) * $sin(2*pi*10e3*$time*1e-9));
    I   = x * cos / 2.0**6;
    Q   = x * sin / 2.0**6;

    if(I < 0) I += 2**16;
    if(Q < 0) Q += 2**16;

    I = $floor(I);
    Q = $floor(Q);

    Test(x, cos, sin, I, Q);
    #10220;
  end

  $display("Time: %1d ns  Simulation Complete", $time);
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------


