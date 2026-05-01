//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : instr_reg.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// 16-bit instruction register with synchronous load, async reset, and field decode
module instr_reg
   import cpu_pkg::*;
(
   output opcode_t     ir_opcode,
   output logic        ir_mode,
   output logic [1:0]  ir_rd,
   output logic [1:0]  ir_rs,
   output logic [7:0]  ir_data,
   input  logic [15:0] din,
   input  logic        clk,
   input  logic        enable,
   input  logic        rst_n
);

logic [15:0] ir_out;

always_ff @(posedge clk, negedge rst_n)
   if (!rst_n)
      ir_out <= '0;
   else if (enable)
      ir_out <= din;

// Field decode
assign ir_opcode = opcode_t'(ir_out[15:13]);
assign ir_mode   = ir_out[12];
assign ir_rd     = ir_out[11:10];
assign ir_rs     = ir_out[9:8];
assign ir_data   = ir_out[7:0];

endmodule
