// Students: Implement your ALU here
// See microcpu/sv_src/alu.sv for reference

module alu
   import cpu_pkg_lab05::*;
(
   output logic [15:0] dout,
   output logic        zero,
   input  logic        clk,
   input  logic [15:0] accum,
   input  logic [15:0] din,
   input  opcode_t     opcode
);

   // TODO: Registered output (posedge clk) with unique case on opcode
   //       ADD, AND, SUB, LDA: compute result
   //       HALT, BRZ, BRA, STA: passthrough (dout <= accum)

   // TODO: Combinational zero flag: zero = ~(|accum)

endmodule
