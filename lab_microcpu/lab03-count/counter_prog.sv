// Students: Implement your counter_prog here
// See microcpu/sv_src/counter_prog.sv for reference

module counter_prog (
   output logic [7:0] pc_count,
   input  logic [7:0] din,
   input  logic       clk,
   input  logic       load,
   input  logic       enable,
   input  logic       rst_n
);

import cpu_pkg::*;

   // TODO: Implement 8-bit programmable counter
   // Priority: rst_n > load > enable > hold

endmodule
