module LPF_Logger(
  input  ipClk,
  input  ipReset,
  input  ipRampStart,

  input      ipGo,
  output reg opBusy,

  input      [23:0]ipI,
  input      [23:0]ipQ,
  input            ipValid,

  input      [ 9:0]ipAvalon_Address,
  input      [ 3:0]ipAvalon_ByteEnable,
  output           opAvalon_WaitRequest,
  input      [31:0]ipAvalon_WriteData,
  input            ipAvalon_Write,
  input            ipAvalon_Read,
  output reg [31:0]opAvalon_ReadData,
  output reg       opAvalon_ReadDataValid
);
//------------------------------------------------------------------------------

reg [ 6:0]WrAddress;
reg [64:0]WrData;
reg       WrEnable;

altsyncram #(
  .address_aclr_b                    ("NONE"),
  .address_reg_b                     ("CLOCK0"),
  .clock_enable_input_a              ("BYPASS"),
  .clock_enable_input_b              ("BYPASS"),
  .clock_enable_output_b             ("BYPASS"),
  .intended_device_family            ("MAX 10"),
  .lpm_type                          ("altsyncram"),
  .numwords_a                        (128),
  .numwords_b                        (256),
  .operation_mode                    ("DUAL_PORT"),
  .outdata_aclr_b                    ("NONE"),
  .outdata_reg_b                     ("UNREGISTERED"),
  .power_up_uninitialized            ("FALSE"),
  .ram_block_type                    ("M9K"),
  .read_during_write_mode_mixed_ports("DONT_CARE"),
  .widthad_a                         (7),
  .widthad_b                         (8),
  .width_a                           (64),
  .width_b                           (32),
  .width_byteena_a                   (1)
)InjectionBuffer(
  .clock0   (ipClk),

  .address_a(WrAddress),
  .data_a   (WrData   ),
  .wren_a   (WrEnable ),

  .address_b(ipAvalon_Address ),
  .q_b      (opAvalon_ReadData),

  .aclr0         (1'b0),
  .aclr1         (1'b0),
  .addressstall_a(1'b0),
  .addressstall_b(1'b0),
  .byteena_a     (1'b1),
  .byteena_b     (1'b1),
  .clock1        (1'b1),
  .clocken0      (1'b1),
  .clocken1      (1'b1),
  .clocken2      (1'b1),
  .clocken3      (1'b1),
  .data_b        ({32{1'b1}}),
  .eccstatus     (),
  .q_a           (),
  .rden_a        (1'b1),
  .rden_b        (1'b1),
  .wren_b        (1'b0)
);

assign opAvalon_WaitRequest = 0;
//------------------------------------------------------------------------------

reg      Reset;
reg [5:0]Count;

enum { Idle, WaitForRamp, DiscardSamples, Logging } State;

always @(posedge ipClk) begin
  Reset <= ipReset;
  opAvalon_ReadDataValid <= ipAvalon_Read;

  if(Reset) begin
    opBusy <= 1'b1;

    WrAddress <= 'hX;
    WrData    <= 'hX;
    WrEnable  <= 0;

    State  <= Idle;
  //----------------------------------------------------------------------------

  end else case(State)
    Idle: begin
      WrAddress <= -1;
      WrData    <= 'hX;
      WrEnable  <= 0;

      if(~opBusy && ipGo) State <= WaitForRamp;

      opBusy <= ipGo;
    end
    //--------------------------------------------------------------------------

    WaitForRamp: begin
      Count    <= 0;
      WrEnable <= 0;

      if(ipRampStart)
        State <= DiscardSamples;
    end
    //--------------------------------------------------------------------------

    DiscardSamples: begin
      if(ipValid) begin
        if(Count == 4) State <= Logging;
        Count <= Count + 1;
      end
    end
    //--------------------------------------------------------------------------

    Logging: begin
      if(ipValid) begin
        WrAddress <= WrAddress + 1;
        WrData    <= { {8{ipQ[23]}}, ipQ, {8{ipI[23]}}, ipI };
        WrEnable  <= 1'b1;

        if(WrAddress == 7'h7E)
          State <= Idle;
        else if(Count == 36)
          State <= WaitForRamp;

        Count <= Count + 1;

      end else begin
        WrEnable <= 1'b0;
      end
    end
    //--------------------------------------------------------------------------

    default:;
  endcase
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------
