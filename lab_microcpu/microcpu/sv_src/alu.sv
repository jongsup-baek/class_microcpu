//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : alu.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// 16-bit ALU — combinational logic
module alu
   import cpu_pkg::*;
(
   output logic [15:0] dout,
   output logic        zero,
   input  logic [15:0] accum,
   input  logic [15:0] din,
   input  opcode_t     opcode
);

always_comb
   unique case (opcode)
      ADD     : dout = accum + din;
      AND     : dout = accum & din;
      NOT     : dout = ~accum;
      LDA     : dout = din;
      default : dout = accum;
   endcase

assign zero = ~(|accum);

endmodule
