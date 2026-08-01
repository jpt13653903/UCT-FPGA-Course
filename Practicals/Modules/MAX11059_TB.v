`timescale 1ns/1ps
module MAX11059_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

// DUT
wire [13:0]opSamples[15:0];
wire       opValid;

wire [ 2:1]opnCS;
wire [ 3:0]opCR;
wire       enCR;
wire       opnWR;
wire       opnRD;
wire       opCONVST;
reg  [ 2:1]ipnEOC;
reg  [13:0]ipDB;

MAX11059 #(
  .Clock_kHz       (100_000),
  .SamplingRate_kHz(97.656_250)
)DUT(
  .ipClk    (ipClk    ),
  .ipReset  (ipReset  ),

  .opSamples(opSamples),
  .opValid  (opValid  ),

  .opnCS    (opnCS    ),
  .opCR     (opCR     ),
  .enCR     (enCR     ),
  .opnWR    (opnWR    ),
  .opnRD    (opnRD    ),
  .opCONVST (opCONVST ),
  .ipnEOC   (ipnEOC   ),
  .ipDB     (ipDB     )
);
//------------------------------------------------------------------------------

integer Data = 0;
always begin
  ipnEOC <= 2'b00;
  ipDB   <= 1'hZ;
  @(posedge opCONVST);
  #65;
  ipnEOC <= 2'b01;
  #(140-65);
  ipnEOC <= 2'b11;

  #(3000-140);
  ipnEOC <= 2'b00;

  @(negedge opnCS[1])
  for(integer n = 0; n < 8; n++) begin
    @(negedge opnRD);
    #35;
    ipDB <= Data;
    Data <= Data + 1;
    @(posedge opnRD);
    #5;
    ipDB <= 'hZ;
  end

  @(negedge opnCS[2])
  for(integer n = 0; n < 8; n++) begin
    @(negedge opnRD);
    #35;
    ipDB <= Data;
    Data <= Data + 1;
    @(posedge opnRD);
    #5;
    ipDB <= 'hZ;
  end
end

endmodule
//------------------------------------------------------------------------------


