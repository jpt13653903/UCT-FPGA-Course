/*------------------------------------------------------------------------------

Virtual JTAG interface to a memory-mapped bus.

Instructions:

- 0 => Write to the bus
- 1 => Read from the bus
------------------------------------------------------------------------------*/

module VirtualJTAG_MM(
  input        ipClk,
  input        ipReset,

  output reg   opBusy,

  output [29:0]opAvalon_Address,
  output [ 3:0]opAvalon_ByteEnable,
  input        ipAvalon_WaitRequest,

  output [31:0]opAvalon_WriteData,
  output reg   opAvalon_Write,

  output       opAvalon_Read,
  input  [31:0]ipAvalon_ReadData,
  input        ipAvalon_ReadDataValid
);
//------------------------------------------------------------------------------

reg  [3:0]TDO;
wire TCK;
wire TDI;

wire [7:0]Instruction;
wire      Capture;
wire      Shift;
wire      Update;

sld_virtual_jtag #(
  .sld_auto_instance_index("NO"),
  .sld_instance_index     (0),
  .sld_ir_width           (8)

)virtual_jtag_0(
  .tck              (TCK),
  .tdi              (TDI),
  .tdo              (TDO[3]),

  .ir_in            (Instruction),
  .virtual_state_cdr(Capture),
  .virtual_state_sdr(Shift  ),
  .virtual_state_udr(Update )
);
//------------------------------------------------------------------------------

reg [12:0]JTAG_Address;

reg JTAG_Reset;
reg JTAG_Busy;

always @(posedge TCK) begin
  JTAG_Reset <= ipReset;
  TDO[3]     <= TDO[2];

  if(JTAG_Reset) begin
    JTAG_Address   <= 0;
    JTAG_Busy      <= 0;
    RdCacheReset   <= 1;

  end else begin
    case(Instruction)
      1: RdCacheStart <= 'h0000_0000; // SDRAM
      2: RdCacheStart <= 'h0140_0000; // LPF Logger
      default:;
    endcase

    case(1'b1)
      Capture: begin
        JTAG_Address <= 0;
        JTAG_Busy    <= 1'b1;
        RdCacheReset <= (Instruction != 1 && Instruction != 2);
      end

      Shift: begin
        JTAG_Address <= JTAG_Address + 1'b1;
      end

      Update: begin
        JTAG_Busy    <= 1'b0;
        RdCacheReset <= 1'b1;
      end

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

always_comb begin
  case(Instruction)
    0: begin
      opAvalon_Address     <= Writer_Address;
      opAvalon_ByteEnable  <= Writer_ByteEnable;
      opAvalon_WriteData   <= Writer_WriteData;
      opAvalon_Write       <= Writer_Write;
      opAvalon_Read        <= Writer_Read;

      Writer_WaitRequest   <= ipAvalon_WaitRequest;
      Writer_ReadData      <= ipAvalon_ReadData;
      Writer_ReadDataValid <= ipAvalon_ReadDataValid;

      Reader_WaitRequest   <= 1'b1;
      Reader_ReadData      <= 32'hX;
      Reader_ReadDataValid <= 1'b0;
    end

    1, 2: begin
      opAvalon_Address     <= Reader_Address;
      opAvalon_ByteEnable  <= Reader_ByteEnable;
      opAvalon_WriteData   <= Reader_WriteData;
      opAvalon_Write       <= Reader_Write;
      opAvalon_Read        <= Reader_Read;

      Writer_WaitRequest   <= 1'b1;
      Writer_ReadData      <= 32'hX;
      Writer_ReadDataValid <= 1'b0;

      Reader_WaitRequest   <= ipAvalon_WaitRequest;
      Reader_ReadData      <= ipAvalon_ReadData;
      Reader_ReadDataValid <= ipAvalon_ReadDataValid;
    end

    default: begin
      opAvalon_Address     <= 30'hX;
      opAvalon_ByteEnable  <=  4'b1111;
      opAvalon_WriteData   <= 32'hX;
      opAvalon_Write       <=  1'b0;
      opAvalon_Read        <=  1'b0;

      Writer_WaitRequest   <=  1'b1;
      Writer_ReadData      <= 32'hX;
      Writer_ReadDataValid <=  1'b0;

      Reader_WaitRequest   <=  1'b1;
      Reader_ReadData      <= 32'hX;
      Reader_ReadDataValid <=  1'b0;
    end
  endcase
end
//------------------------------------------------------------------------------

wire [23:0]Writer_Address;
wire [ 3:0]Writer_ByteEnable = 4'b1111;
wire       Writer_WaitRequest;

wire [31:0]Writer_WriteData;
reg        Writer_Write;

wire       Writer_Read = 1'b0;
wire [31:0]Writer_ReadData;
wire       Writer_ReadDataValid;

altsyncram #(
  // General parameters
  .intended_device_family("MAX 10"),
  .lpm_type              ("altsyncram"),
  .operation_mode        ("DUAL_PORT"),
  .power_up_uninitialized("FALSE"),
  .ram_block_type        ("M9K"),

  // Port A parameters
  .clock_enable_input_a  ("BYPASS"),
  .numwords_a            (8192),
  .widthad_a             (13),
  .width_a               (1),
  .width_byteena_a       (1),

  // Port B parameters
  .address_aclr_b        ("NONE"),
  .address_reg_b         ("CLOCK1"),
  .clock_enable_input_b  ("BYPASS"),
  .clock_enable_output_b ("BYPASS"),
  .numwords_b            (256),
  .outdata_aclr_b        ("NONE"),
  .outdata_reg_b         ("UNREGISTERED"),
  .widthad_b             (8),
  .width_b               (32)

)altsyncram_component(
  // Write port
  .clock0        (TCK),
  .address_a     (JTAG_Address),
  .data_a        (TDI),
  .wren_a        (Shift),

  // Read port
  .clock1        (ipClk),
  .address_b     (Writer_Address[7:0]),
  .q_b           (Writer_WriteData),

  // Unused features
  .aclr0         (1'b0),
  .aclr1         (1'b0),
  .addressstall_a(1'b0),
  .addressstall_b(1'b0),
  .byteena_a     (1'b1),
  .byteena_b     (1'b1),
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
//------------------------------------------------------------------------------

wire [29:0]Reader_Address;
wire [ 3:0]Reader_ByteEnable;
wire       Reader_WaitRequest;

wire [31:0]Reader_WriteData;
reg        Reader_Write;

wire       Reader_Read;
wire [31:0]Reader_ReadData;
wire       Reader_ReadDataValid;

reg        RdCacheReset;
reg  [29:0]RdCacheStart;
reg  [ 9:0]RdCacheAddress;
wire [31:0]RdData;

ReadCache #(32) ReadCache_Inst(
  .ipClk                 (ipClk  ),
  .ipReset               (ipReset | RdCacheReset),

  .opMemory_Address      (Reader_Address      ),
  .opMemory_ByteEnable   (Reader_ByteEnable   ),
  .ipMemory_WaitRequest  (Reader_WaitRequest  ),
  .opMemory_WriteData    (Reader_WriteData    ),
  .opMemory_Write        (Reader_Write        ),
  .opMemory_Read         (Reader_Read         ),
  .ipMemory_ReadData     (Reader_ReadData     ),
  .ipMemory_ReadDataValid(Reader_ReadDataValid),

  .ipRdStart             (RdCacheStart  ),
  .ipRdAddress           (RdCacheAddress),
  .opRdReady             (),
  .opRdData              (RdData)
);
//------------------------------------------------------------------------------

reg       Local_Reset;
reg [ 1:0]TCK_Sync;
reg [12:0]JTAG_Address_Sync;
reg       Capture_Sync;

always @(posedge ipClk) begin
  Local_Reset  <=  ipReset;
  TCK_Sync     <= {TCK_Sync[0], TCK};
  Capture_Sync <=  Capture;
  opBusy       <=  JTAG_Busy;
  //----------------------------------------------------------------------------

  if(Local_Reset || Capture_Sync)
    JTAG_Address_Sync <= 0;

  else if(TCK_Sync == 2'b10)
    JTAG_Address_Sync <= JTAG_Address;
  //----------------------------------------------------------------------------

  if(Local_Reset || Capture_Sync || Instruction != 0) begin
    Writer_Address    <= 0;
    Writer_Write      <= 0;

  end else if(~Writer_Write) begin // Idle
    if(JTAG_Address_Sync[12:5] != Writer_Address[7:0])
      Writer_Write <= 1'b1;

  end else begin // Writing
    if(~Writer_WaitRequest) begin
      Writer_Address <= Writer_Address + 1'b1;
      Writer_Write   <= 0;
    end
  end
  //----------------------------------------------------------------------------

  if(Local_Reset || Capture_Sync || (Instruction != 1 && Instruction != 2)) begin
    TDO[2:0]       <= 0;
    RdCacheAddress <= 0;

  end else if(TCK_Sync == 2'b10) begin
    TDO[2:0] <= { TDO[1:0], RdData[JTAG_Address_Sync[4:0]] };

    if(&JTAG_Address_Sync[4:0]) RdCacheAddress <= RdCacheAddress + 1'b1;
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

