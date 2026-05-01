// Students: Implement your sysclk here
// See microcpu/sv_src/sysclk.sv for reference

// Clock gating + 2-divider
// clk_i = clk_ext & ~halt (gated clock)
// clk_sys = clk_i / 2       (internal clock for all blocks)
module sysclk (
   input  logic clk_ext,
   input  logic halt,
   output logic clk_sys,
   input  logic rst_n
);

   // TODO: Create gated clock: clk_i = clk_ext & ~halt

   // TODO: Declare 1-bit divider register

   // TODO: Toggle divider on posedge clk_i with async rst_n

   // TODO: Assign clk_sys = div

endmodule : sysclk
