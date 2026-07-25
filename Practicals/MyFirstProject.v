module MyFirstProject(
  input  [9:0]Switch,
  output [9:0]LED
);

wire [9:0]Source;
SourcesAndProbes SourcesAndProbes_inst(
  .source(Source),
  .probe (Switch)
);
assign LED = Switch ^ Source;

endmodule

