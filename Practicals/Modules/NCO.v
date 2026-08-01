module NCO(
  input ipClk,
  input ipClkEnable,
  input ipReset,

  input  signed [23:0]ipFrequency,

  output signed [ 8:0]opSin,
  output signed [ 8:0]opCos
);
//------------------------------------------------------------------------------

reg       Reset;
reg [23:0]Phase;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    Phase <= 0;

  end else if(ipClkEnable) begin
    Phase <= Phase + ipFrequency;
  end
end
//------------------------------------------------------------------------------

altsyncram #(
  .address_reg_b            ("CLOCK0"),
  .clock_enable_input_a     ("BYPASS"),
  .clock_enable_input_b     ("BYPASS"),
  .clock_enable_output_a    ("BYPASS"),
  .clock_enable_output_b    ("BYPASS"),
  .indata_reg_b             ("CLOCK0"),
  .init_file                ("NCO.mif"),
  .intended_device_family   ("MAX 10"),
  .lpm_type                 ("altsyncram"),
  .numwords_a               (4096),
  .numwords_b               (4096),
  .operation_mode           ("BIDIR_DUAL_PORT"),
  .outdata_aclr_a           ("NONE"),
  .outdata_aclr_b           ("NONE"),
  .outdata_reg_a            ("CLOCK0"),
  .outdata_reg_b            ("CLOCK0"),
  .power_up_uninitialized   ("FALSE"),
  .widthad_a                (12),
  .widthad_b                (12),
  .width_a                  (9),
  .width_b                  (9),
  .width_byteena_a          (1),
  .width_byteena_b          (1),
  .wrcontrol_wraddress_reg_b("CLOCK0")
)SinLut(
  .clock0   (ipClk),

  .address_a(Phase[23:12]),
  .q_a      (opSin),

  .address_b(Phase[23:12] + 12'h400),
  .q_b      (opCos),

  .data_a(9'h0),
  .wren_a(1'b0),
  .data_b(9'h0),
  .wren_b(1'b0)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

