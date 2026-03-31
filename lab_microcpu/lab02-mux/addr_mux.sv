// Students: Implement your addr_mux here
// See microcpu/sv_src/addr_mux.sv for reference

module addr_mux #(WIDTH = 8) (
   output logic [WIDTH-1:0] dout,
   input  logic [WIDTH-1:0] din_a,
   input  logic [WIDTH-1:0] din_b,
   input  logic             sel_a
);

   // TODO: Implement 2-to-1 MUX using unique case

endmodule
