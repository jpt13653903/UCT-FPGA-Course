module Injection(
  input  ipClk,
  input  ipReset,

  output reg [15:0]opData,
  output reg       opValid
);
//------------------------------------------------------------------------------

reg  [15:0]WrAddress;
reg  [15:0]WrData;
reg        WrEn;

reg  [15:0]RdAddress;
wire [15:0]RdData;

altsyncram #(
  .address_aclr_b                    ("NONE"),
  .address_reg_b                     ("CLOCK0"),
  .clock_enable_input_a              ("BYPASS"),
  .clock_enable_input_b              ("BYPASS"),
  .clock_enable_output_b             ("BYPASS"),
  .init_file                         ("Audio.mif"),
  .intended_device_family            ("MAX 10"),
  .lpm_type                          ("altsyncram"),
  .numwords_a                        (2**16),
  .numwords_b                        (2**16),
  .operation_mode                    ("DUAL_PORT"),
  .outdata_aclr_b                    ("NONE"),
  .outdata_reg_b                     ("UNREGISTERED"),
  .power_up_uninitialized            ("FALSE"),
  .ram_block_type                    ("M9K"),
  .read_during_write_mode_mixed_ports("DONT_CARE"),
  .widthad_a                         (16),
  .widthad_b                         (16),
  .width_a                           (16),
  .width_b                           (16),
  .width_byteena_a                   (1)
)InjectionBuffer(
  .clock0   (ipClk),

  .address_a(WrAddress),
  .data_a   (WrData),
  .wren_a   (WrEn),

  .address_b(RdAddress),
  .q_b      (RdData),

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
  .data_b        ({16{1'b1}}),
  .eccstatus     (),
  .q_a           (),
  .rden_a        (1'b1),
  .rden_b        (1'b1),
  .wren_b        (1'b0)
);
//------------------------------------------------------------------------------

reg Reset;
reg [10:0]Count = 0;

always @(posedge ipClk) begin
  Reset <= ipReset;
  Count <= Count + 1'b1;

  if(Reset) begin
    opData    <= 0;
    opValid   <= 0;

    WrAddress <= 16'hX;
    WrData    <= 16'hX;
    WrEn      <= 1'b0;

    RdAddress <= 16'h0;

  end else if(~|Count) begin
    opData    <= RdData;
    opValid   <= 1'b1;
    RdAddress <= RdAddress + 1'b1;

  end else begin
    opValid <= 1'b0;
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

