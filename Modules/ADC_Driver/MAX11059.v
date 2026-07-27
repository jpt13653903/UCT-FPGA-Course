/*------------------------------------------------------------------------------

Abstraction of two MAX11059 ADCs

This module enforces the 500 ns quiet time.
The user must drop the sampling rate accordingly.

opCR and ipDB share pins.  enCR should be used to drive the
bidirectional CR/DB pin to high-impedance when disabled.
------------------------------------------------------------------------------*/

module MAX11059 #(
  parameter Clock_kHz,
  parameter SamplingRate_kHz // Max 220 (due to the read-out delay and quiet time)
)(
  input  ipClk, // Max 100 MHz
  input  ipReset,

  output reg [13:0]opSamples[15:0],
  output reg       opValid,

  output reg [ 2:1]opnCS,
  output reg [ 3:0]opCR,
  output reg       enCR,
  output reg       opnWR,
  output reg       opnRD,
  output reg       opCONVST,
  input      [ 2:1]ipnEOC,
  input      [13:0]ipDB
);
//------------------------------------------------------------------------------

localparam SampleRate = Clock_kHz / SamplingRate_kHz;
localparam Quiet      = Clock_kHz / 2000;
//------------------------------------------------------------------------------

reg      Reset;
reg [9:0]SampleRateCount = 0;
reg [5:0]QuietCount      = 0;
reg [2:0]ClockCount      = 0;
reg [3:0]ChannelCount    = 0;
//------------------------------------------------------------------------------

typedef enum {
  Setup,
  WriteConfig,
  WriteWait,
  WriteLatch,
  WriteDone,
  StartConversion,
  WaitForConversion,
  ReadSamples,
  SwitchICs,
  ReadDone
} STATE;

STATE State;
//------------------------------------------------------------------------------

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(~|SampleRateCount) SampleRateCount = SampleRate-1;
  else                  SampleRateCount = SampleRateCount-1;

  if(Reset) begin
    for(integer n = 0; n < 16; n++) begin
      opSamples[n] <= 'hX;
    end
    opValid <= 0;

    opnCS    <= 2'b11;
    opCR     <= 4'hX;
    enCR     <= 1'b0;
    opnWR    <= 1'b1;
    opnRD    <= 1'b1;
    opCONVST <= 1'b0;

    State <= Setup;
  //----------------------------------------------------------------------------

  end else begin
    case(State)
      Setup: begin
        opnCS <= 2'b00;
        State <= WriteConfig;
      end
      //------------------------------------------------------------------------

      WriteConfig: begin
        opCR[3] <= 1'b0; // Internal reference
        opCR[2] <= 1'b1; // 2's complement
        opCR[1] <= 1'b0; // Reserved, must be 0
        opCR[0] <= 1'b1; // Conversion mode 1 (acquire automatically)
        enCR    <= 1'b1;
        opnWR   <= 1'b0;
        State   <= WriteWait;
      end
      //------------------------------------------------------------------------

      WriteWait: begin
        State <= WriteLatch;
      end
      //------------------------------------------------------------------------

      WriteLatch: begin
        opnWR <= 1'b1;
        State <= WriteDone;
      end
      //------------------------------------------------------------------------

      WriteDone: begin
        opnCS <= 2'b11;
        enCR  <= 1'b0;
        State <= StartConversion;
      end
      //------------------------------------------------------------------------

      StartConversion: begin
        if(~|SampleRateCount) begin
          opCONVST <= 1'b1;
        end
        if(|ipnEOC) begin
          State <= WaitForConversion;
        end
      end
      //------------------------------------------------------------------------

      WaitForConversion: begin
        ClockCount   <= 0;
        ChannelCount <= 0;
        if(~|ipnEOC) begin
          opCONVST <= 1'b0;
          opnCS    <= 2'b10;
          State    <= ReadSamples;
        end
      end
      //------------------------------------------------------------------------

      ReadSamples: begin
        case(ClockCount)
          0: begin
            opnRD <= 1'b0;
          end

          5: begin
            opnRD <= 1'b1;
            opSamples[ChannelCount] <= ipDB;
            if(ChannelCount == 7) begin
              State <= SwitchICs;
            end
            if(ChannelCount == 15) begin
              opValid <= 1'b1;
              State   <= ReadDone;
            end
            ChannelCount <= ChannelCount + 1'b1;
          end

          default:;
        endcase

        if(ClockCount == 5) ClockCount <= 0;
        else                ClockCount <= ClockCount + 1'b1;

        QuietCount <= Quiet-1;
      end
      //------------------------------------------------------------------------

      SwitchICs: begin
        opnCS <= 2'b01;
        State <= ReadSamples;
      end
      //------------------------------------------------------------------------

      ReadDone: begin
        opValid <= 1'b0;
        opnCS   <= 2'b11;

        if(~|QuietCount) State <= StartConversion;
        QuietCount <= QuietCount - 1;
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

