// Students: Implement your ALU here
// See microcpu/sv_src/alu.sv for reference

// 16-bit ALU — combinational logic
module alu
   import cpu_pkg_lab05::*;
(
   output logic [15:0] dout,
   output logic        zero,
   input  logic [15:0] accum,
   input  logic [15:0] din,
   input  opcode_t     opcode
);

   // TODO: Combinational output (always_comb) with unique case on opcode
   //       ADD, AND, SUB, LDA: compute result
   //       default: passthrough (dout = accum)

   // TODO: Combinational zero flag: zero = ~(|accum)

endmodule
