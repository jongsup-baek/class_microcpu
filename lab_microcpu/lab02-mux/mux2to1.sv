// Students: Implement your mux2to1 here
// See microcpu/sv_src/mux2to1.sv for reference

module mux2to1 #(WIDTH = 8) (
   output logic [WIDTH-1:0] dout,
   input  logic [WIDTH-1:0] din_a,
   input  logic [WIDTH-1:0] din_b,
   input  logic             sel_a
);

   // TODO: Implement 2-to-1 MUX using unique case

endmodule
