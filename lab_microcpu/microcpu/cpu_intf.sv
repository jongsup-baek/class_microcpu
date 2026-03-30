//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : cpu_intf.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

interface cpu_intf (
   input logic clk_master
);
   import cpu_pkg::*;

   // Control signal (driven by TB)
   logic rst_n;

   // CPU output signals
   logic halt;
   logic ir_load;

   // Observation signals (connected via hierarchical reference)
   logic [15:0] data_out;
   logic [15:0] alu_out;
   logic [15:0] rd_data;
   logic [7:0]  pc_addr;
   logic [7:0]  addr;
   opcode_t     ir_opcode;
   logic        ir_mode;
   logic [1:0]  ir_rd;

   assign data_out  = tb_cpu_top.top.data_out;
   assign alu_out   = tb_cpu_top.top.alu_out;
   assign rd_data   = tb_cpu_top.top.cpu1.rd_data;
   assign pc_addr   = tb_cpu_top.top.cpu1.pc_addr;
   assign addr      = tb_cpu_top.top.addr;
   assign ir_opcode = tb_cpu_top.top.cpu1.ir_opcode;
   assign ir_mode   = tb_cpu_top.top.cpu1.ir_mode;
   assign ir_rd     = tb_cpu_top.top.cpu1.ir_rd;

   // Testbench modport
   modport TB (
      input  clk_master,
      output rst_n,
      input  halt, ir_load
   );

   // Monitor modport (read-only)
   modport MON (
      input clk_master,
      input halt, ir_load,
      input data_out, alu_out, rd_data,
      input pc_addr, addr, ir_opcode, ir_mode, ir_rd
   );

endinterface : cpu_intf
