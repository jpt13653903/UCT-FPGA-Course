module Filter( // TODO: Change from sub-sampler to FIR filter
  input ipClk,
  input ipReset,

  input      [15:0]ipData,
  input            ipValid,

  output reg [23:0]opData,
  output reg       opValid
);
//------------------------------------------------------------------------------

reg         [10:  0]CoefAddress;
wire signed [-7:-24]Coef;

altsyncram #(
  .address_reg_b            ("CLOCK0"),
  .clock_enable_input_a     ("BYPASS"),
  .clock_enable_input_b     ("BYPASS"),
  .clock_enable_output_a    ("BYPASS"),
  .clock_enable_output_b    ("BYPASS"),
  .indata_reg_b             ("CLOCK0"),
  .init_file                ("Filter.mif"),
  .intended_device_family   ("MAX 10"),
  .lpm_type                 ("altsyncram"),
  .numwords_a               (2048),
  .numwords_b               (2048),
  .operation_mode           ("BIDIR_DUAL_PORT"),
  .outdata_aclr_a           ("NONE"),
  .outdata_aclr_b           ("NONE"),
  .outdata_reg_a            ("CLOCK0"),
  .outdata_reg_b            ("CLOCK0"),
  .power_up_uninitialized   ("FALSE"),
  .widthad_a                (11),
  .widthad_b                (11),
  .width_a                  (18),
  .width_b                  (18),
  .width_byteena_a          (1),
  .width_byteena_b          (1),
  .wrcontrol_wraddress_reg_b("CLOCK0")
)Coefficients(
  .clock0   (ipClk),

  .address_a(CoefAddress),
  .q_a      (Coef),

  .address_b(11'd0),
  .q_b      (),

  .data_a(18'h0),
  .wren_a( 1'b0),
  .data_b(18'h0),
  .wren_b( 1'b0)
);
//------------------------------------------------------------------------------

reg signed [ 0:-15]Data;
reg signed [-6:-39]Product;
reg signed [ 5:-39]Sum[7:0];
reg signed [ 5:-23]Result;
//------------------------------------------------------------------------------

reg      Reset;
reg [2:0]Count;

enum {
  Idle,
  GetCoef,
  Multiply,
  Add,
  Done,
  Output
} State;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opData  <= 'hX;
    opValid <= 0;

    CoefAddress <= 0;
    Data        <= 'hX;
    Product     <= 'hX;
    Result      <= 'hX;

    for(int n = 0; n < 8; n++)
      Sum[n] <= 0;

    Count <= 'hX;
    State <= Idle;
  //----------------------------------------------------------------------------

  end else case(State)
    Idle: begin
      Count   <= 0;
      Data    <= ipData;
      opValid <= 0;

      if(ipValid)
        State <= GetCoef;
    end
    //--------------------------------------------------------------------------

    GetCoef: begin // Waits for the ROM read latency
      State <= Multiply;
    end
    //--------------------------------------------------------------------------

    Multiply: begin
      Product     <= Data * Coef;
      CoefAddress <= CoefAddress + 9'h100;
      State       <= Add;
    end
    //--------------------------------------------------------------------------

    Add: begin
      Sum[Count] <= Sum[Count] + Product;

      if(&Count)
        State <= Done;
      else
        State <= GetCoef;

      Count <= Count + 1'b1;
    end
    //--------------------------------------------------------------------------

    Done: begin
      if(CoefAddress[7:0] == 8'hFF) begin
        case(CoefAddress[10:8])
          0: begin
            Result <= Sum[7][5:-23];
            Sum[7] <= 0;
          end
          1: begin
            Result <= Sum[6][5:-23];
            Sum[6] <= 0;
          end
          2: begin
            Result <= Sum[5][5:-23];
            Sum[5] <= 0;
          end
          3: begin
            Result <= Sum[4][5:-23];
            Sum[4] <= 0;
          end
          4: begin
            Result <= Sum[3][5:-23];
            Sum[3] <= 0;
          end
          5: begin
            Result <= Sum[2][5:-23];
            Sum[2] <= 0;
          end
          6: begin
            Result <= Sum[1][5:-23];
            Sum[1] <= 0;
          end
          7: begin
            Result <= Sum[0][5:-23];
            Sum[0] <= 0;
          end
          default:;
        endcase
        State <= Output;
      end else begin
        State <= Idle;
      end

      CoefAddress <= CoefAddress + 1'b1;
    end
    //--------------------------------------------------------------------------

    Output: begin
      if(Result[5]) begin
        if(&Result[4:0]) opData <= Result[0:-23];
        else             opData <= 24'h800000;
      end else begin
        if(|Result[4:0]) opData <= 24'h7FFFFF;
        else             opData <= Result[0:-23];
      end
      opValid <= 1'b1;
      State   <= Idle;
    end
    //--------------------------------------------------------------------------

    default:;
  endcase
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

