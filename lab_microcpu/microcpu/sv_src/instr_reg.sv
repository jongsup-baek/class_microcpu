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

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      ir_opcode <= WFR;
      ir_mode   <= 1'b0;
      ir_rd     <= 2'b0;
      ir_rs     <= 2'b0;
      ir_data   <= 8'b0;
   end
   else if (enable) begin
      ir_opcode <= opcode_t'(din[15:13]);
      ir_mode   <= din[12];
      ir_rd     <= din[11:10];
      ir_rs     <= din[9:8];
      ir_data   <= din[7:0];
   end
end

endmodule
