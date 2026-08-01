`timescale 1ns/1ps
module ADC_Logger_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #5 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

reg  ipGo;
wire opBusy;

reg  [13:0]ipSamples[15:0];
reg        ipValid;

wire [23:0]opAvalon_Address;
wire [ 3:0]opAvalon_ByteEnable;
wire       ipAvalon_WaitRequest = 0;
wire [31:0]opAvalon_WriteData;
wire       opAvalon_Write;
wire       opAvalon_Read;
wire [31:0]ipAvalon_ReadData      = 0;
wire       ipAvalon_ReadDataValid = 0;

ADC_Logger DUT(
  .ipClk                 (ipClk  ),
  .ipReset               (ipReset),

  .ipGo                  (ipGo  ),
  .opBusy                (opBusy),

  .ipSamples             (ipSamples),
  .ipValid               (ipValid  ),

  .opAvalon_Address      (opAvalon_Address      ),
  .opAvalon_ByteEnable   (opAvalon_ByteEnable   ),
  .ipAvalon_WaitRequest  (ipAvalon_WaitRequest  ),
  .opAvalon_WriteData    (opAvalon_WriteData    ),
  .opAvalon_Write        (opAvalon_Write        ),
  .opAvalon_Read         (opAvalon_Read         ),
  .ipAvalon_ReadData     (ipAvalon_ReadData     ),
  .ipAvalon_ReadDataValid(ipAvalon_ReadDataValid)
);
//------------------------------------------------------------------------------

initial begin
  ipGo <= 0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);

  ipGo <= 1;
  @(opBusy);
  @(posedge ipClk);
  ipGo <= 0;
end
//------------------------------------------------------------------------------

int n = 0;
always begin
  @(posedge ipGo);

  forever begin
    @(posedge ipClk);

    for(int i = 0; i < 16; i++) begin
      ipSamples[i] <= n++;
    end
    ipValid <= 1;

    @(posedge ipClk);
    ipValid <= 0;

    #980; // about 1 MSps, so that the simulation runs faster
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

