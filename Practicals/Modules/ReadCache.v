/*------------------------------------------------------------------------------

A auto-prefetch read cache meant for streaming memory contents.

To invalidate the cache so that it starts reading again from address 0,
reset the module.

To start reading somewhere else, set ipRdStart during reset.
The actual start address will then be the beginning of the page.
------------------------------------------------------------------------------*/

module ReadCache #(
  parameter WordLength
)(
  input  ipClk,
  input  ipReset,

  output reg [            29:0]opMemory_Address,
  output     [WordLength/8-1:0]opMemory_ByteEnable,
  input                        ipMemory_WaitRequest,
  output     [WordLength  -1:0]opMemory_WriteData,
  output                       opMemory_Write,
  output reg                   opMemory_Read,
  input      [WordLength  -1:0]ipMemory_ReadData,
  input                        ipMemory_ReadDataValid,

  input      [            29:0]ipRdStart,
  input      [             9:0]ipRdAddress,
  output                       opRdReady,
  output reg [WordLength  -1:0]opRdData
);
//------------------------------------------------------------------------------

reg [9:0]WrAddress;

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
  .width_a                           (WordLength),
  .width_b                           (WordLength),
  .width_byteena_a                   (1)
)InjectionBuffer(
  .clock0   (ipClk),

  .address_a(WrAddress),
  .data_a   (ipMemory_ReadData),
  .wren_a   (ipMemory_ReadDataValid),

  .address_b(ipRdAddress),
  .q_b      (opRdData),

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
  .data_b        ({WordLength{1'b1}}),
  .eccstatus     (),
  .q_a           (),
  .rden_a        (1'b1),
  .rden_b        (1'b1),
  .wren_b        (1'b0)
);

wire [9:0]FIFO_Length = WrAddress - ipRdAddress;
assign opRdReady = |FIFO_Length;
//------------------------------------------------------------------------------

reg Reset;
assign opMemory_ByteEnable = -1;
assign opMemory_WriteData  =  0;
assign opMemory_Write      =  0;

enum {
  Idle,
  Reading
} State;

always @(posedge ipClk) begin: Input
  Reset <= ipReset;

  if(Reset) begin
    opMemory_Address <= { ipRdStart[29:9], 9'd0 };
    opMemory_Read    <= 0;
    WrAddress        <= 0;

    State <= Idle;

  end else begin
    if(~ipMemory_WaitRequest) begin
      case(State)
        Idle: begin
          if(FIFO_Length < 512) begin
            opMemory_Read <= 1'b1;
            State <= Reading;
          end
        end

        Reading: begin
          if(&opMemory_Address[8:0]) begin
            opMemory_Read <= 1'b0;
            State <= Idle;
          end
          opMemory_Address <= opMemory_Address + 1'b1;
        end

        default:;
      endcase
    end

    if(ipMemory_ReadDataValid) begin
      WrAddress <= WrAddress + 1'b1;
    end
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

