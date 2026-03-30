//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : alu.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// 16-bit ALU — executes opcode-based operations
// Extended from SimpleCPU's 8-bit ALU
module alu
   import cpu_pkg::*;
(
   output logic [15:0] dout,
   output logic        zero,
   input  logic        clk,
   input  logic [15:0] accum,
   input  logic [15:0] din,
   input  opcode_t     opcode
);

always_ff @(posedge clk)
   unique case (opcode)
      ADD     : dout <= accum + din;
      AND     : dout <= accum & din;
      SUB     : dout <= accum - din;
      LDA     : dout <= din;
      HALT,
      BRZ,
      BRA,
      STA     : dout <= accum;
      default : dout <= 'x;
   endcase

always_comb
   zero = ~(|accum);

endmodule
