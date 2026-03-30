//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : register_file.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// 4x16-bit register file with 2 read ports and 1 write port
// Replaces SimpleCPU's single accumulator (register_core)
module register_file (
   output logic [15:0] rd_data,
   output logic [15:0] rs_data,
   input  logic [1:0]  rd_addr,
   input  logic [1:0]  rs_addr,
   input  logic [15:0] wr_data,
   input  logic [1:0]  wr_addr,
   input  logic        wr_en,
   input  logic        clk,
   input  logic        rst_n
);

logic [15:0] regs [0:3];

// Synchronous write
always_ff @(posedge clk, negedge rst_n)
   if (!rst_n) begin
      regs[0] <= '0;
      regs[1] <= '0;
      regs[2] <= '0;
      regs[3] <= '0;
   end
   else if (wr_en)
      regs[wr_addr] <= wr_data;

// Combinational read
assign rd_data = regs[rd_addr];
assign rs_data = regs[rs_addr];

endmodule
