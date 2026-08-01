module ADC_Logger(
  input  ipClk,
  input  ipReset,

  input      ipGo,
  output reg opBusy,

  input      [13:0]ipSamples[15:0],
  input            ipValid,

  output reg [23:0]opAvalon_Address,
  output     [ 3:0]opAvalon_ByteEnable,
  input            ipAvalon_WaitRequest,
  output reg [31:0]opAvalon_WriteData,
  output reg       opAvalon_Write,
  output           opAvalon_Read,
  input      [31:0]ipAvalon_ReadData,
  input            ipAvalon_ReadDataValid
);
//------------------------------------------------------------------------------

assign opAvalon_ByteEnable = 4'b1111;
assign opAvalon_Read       = 0;

reg        Reset;
reg [255:0]Data;

enum { Idle, Sample, Write } State;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opBusy             <= 1'b1;

    opAvalon_Address   <= 'hX;
    opAvalon_WriteData <= 'hX;
    opAvalon_Write     <= 0;

    Data               <= 'hX;

    State              <= Idle;
  //----------------------------------------------------------------------------

  end else case(State)
    Idle: begin
      if(~ipAvalon_WaitRequest) begin
        opAvalon_Address   <= -1;
        opAvalon_WriteData <= 'hX;
        opAvalon_Write     <= 0;
      end

      Data <= 'hX;

      if(~opBusy && ipGo) State <= Sample;

      opBusy <= ipGo;
    end
    //------------------------------------------------------------------------

    Sample: begin
      if(~ipAvalon_WaitRequest)
        opAvalon_Write <= 1'b0;

      for(int n = 0; n < 16; n++) begin
        Data[16*n +:16] <= { {2{ipSamples[n][13]}}, ipSamples[n] };
      end

      if(ipValid) State <= Write;
    end
    //------------------------------------------------------------------------

    Write: begin
      if(~ipAvalon_WaitRequest) begin
        opAvalon_Address   <= opAvalon_Address + 1'b1;
        opAvalon_WriteData <= Data[31:0];
        opAvalon_Write     <= 1'b1;

        Data <= { 32'hX, Data[255:32] };

        if(opAvalon_Address[2:0] == 6) begin
          if(&opAvalon_Address[23:3])
            State <= Idle;
          else
            State <= Sample;
        end
      end
    end
    //------------------------------------------------------------------------

    default:;
  endcase
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------
