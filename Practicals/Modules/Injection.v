module Injection(
  input  ipClk,
  input  ipReset,

  output reg [24:0]opSDRAM_Address,
  output     [ 1:0]opSDRAM_ByteEnable,
  input            ipSDRAM_WaitRequest,
  output     [15:0]opSDRAM_WriteData,
  output           opSDRAM_Write,
  output reg       opSDRAM_Read,
  input      [15:0]ipSDRAM_ReadData,
  input            ipSDRAM_ReadDataValid,

  output reg [15:0]opData,
  output           opValid
);
//------------------------------------------------------------------------------

reg  [ 9:0]WrAddress;
reg  [ 9:0]RdAddress;
wire [15:0]RdData;

altsyncram #(
  .address_aclr_b                    ("NONE"),
  .address_reg_b                     ("CLOCK0"),
  .clock_enable_input_a              ("BYPASS"),
  .clock_enable_input_b              ("BYPASS"),
  .clock_enable_output_b             ("BYPASS"),
  .intended_device_family            ("MAX 10"),
  .lpm_type                          ("altsyncram"),
  .numwords_a                        (1024),
  .numwords_b                        (1024),
  .operation_mode                    ("DUAL_PORT"),
  .outdata_aclr_b                    ("NONE"),
  .outdata_reg_b                     ("UNREGISTERED"),
  .power_up_uninitialized            ("FALSE"),
  .ram_block_type                    ("M9K"),
  .read_during_write_mode_mixed_ports("DONT_CARE"),
  .widthad_a                         (10),
  .widthad_b                         (10),
  .width_a                           (16),
  .width_b                           (16),
  .width_byteena_a                   (1)
)InjectionBuffer(
  .clock0   (ipClk),

  .address_a(WrAddress),
  .data_a   (ipSDRAM_ReadData),
  .wren_a   (ipSDRAM_ReadDataValid),

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

wire [9:0]FIFO_Length = WrAddress - RdAddress;
//------------------------------------------------------------------------------

reg Reset;
assign opSDRAM_ByteEnable = 2'b11;
assign opSDRAM_WriteData  = 0;
assign opSDRAM_Write      = 0;

enum {
  Idle,
  Reading
} State;

always @(posedge ipClk) begin: Input
  Reset <= ipReset;

  if(Reset) begin
    opSDRAM_Address <= 0;
    opSDRAM_Read    <= 0;
    WrAddress       <= 0;

    State <= Idle;

  end else begin
    if(~ipSDRAM_WaitRequest) begin
      case(State)
        Idle: begin
          if(FIFO_Length < 512) begin
            opSDRAM_Read <= 1'b1;
            State <= Reading;
          end
        end

        Reading: begin
          if(&opSDRAM_Address[8:0]) begin
            opSDRAM_Read <= 1'b0;
            State <= Idle;
          end
          opSDRAM_Address <= opSDRAM_Address + 1'b1;
        end

        default:;
      endcase
    end

    if(ipSDRAM_ReadDataValid) begin
      WrAddress <= WrAddress + 1'b1;
    end
  end
end
//------------------------------------------------------------------------------

reg [10:0]Count = 0;

always @(posedge ipClk) begin: Output
  Count <= Count + 1'b1;

  if(Reset) begin
    opData    <= 0;
    opValid   <= 0;

    RdAddress <= 16'h0;

  end else if(|FIFO_Length && ~|Count) begin
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

