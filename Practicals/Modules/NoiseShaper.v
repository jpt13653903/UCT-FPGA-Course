module NoiseShaper #(
  parameter InputN  = 24,
  parameter OutputN =  8,
  parameter N       =  4  // Order of the noise shaper
)(
  input  ipClk,
  input  ipReset,

  input      [InputN -1:0]ipData,
  input                   ipValid,

  output reg [OutputN-1:0]opData,
  output reg              opValid
);
//------------------------------------------------------------------------------

wire [(InputN+1)        :0]t1;
reg  [(InputN-1)        :0]t2;
reg  [(InputN-OutputN+N):0]t3[2*N+1:0];
wire [(InputN+1)        :0]t4;

reg t2Valid;
//------------------------------------------------------------------------------

reg Reset;
reg [InputN -1:0]Data;
reg [OutputN-1:0]Count;

assign t1 = t4 + Data;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(ipValid) begin
    Count <= 0;
    Data  <= ipData;
  end else begin
    Count <= Count + 1'b1;
  end

  if(Reset) begin
    t2 <= 0;

  end else if(~|Count) begin
    if     (t1[InputN+1]) t2 <= 0;
    else if(t1[InputN  ]) t2 <= {InputN{1'b1}};
    else                  t2 <= t1[InputN-1:0];
    t2Valid <= 1'b1;
  end else begin
    t2Valid <= 1'b0;
  end

  opData  <= t2[InputN-1:InputN-OutputN];
  opValid <= t2Valid;
end
//------------------------------------------------------------------------------

always_comb begin
  t3[0] <= {{(N+1){1'b0}}, t2[InputN-OutputN-1:0]};
end
//------------------------------------------------------------------------------

generate
genvar g;
  for(g = 0; g < N; g++) begin: NS_Blocks
    always_comb begin
      t3[2*g+2] <= t3[2*g] - t3[2*g+1];
    end

    always @(posedge ipClk) begin
      if(Reset)
        t3[2*g+1] <= 0;
      else if(~|Count)
        t3[2*g+1] <= t3[2*g];
    end
  end
endgenerate
//------------------------------------------------------------------------------

always_comb begin
  t3[2*N+1] <= t3[0] - t3[2*N];
end
//------------------------------------------------------------------------------

assign t4 = { { (OutputN-N+1){t3[2*N+1][InputN-OutputN+N]} }, t3[2*N+1] };
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

