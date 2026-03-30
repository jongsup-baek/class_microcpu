//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : cpu_top.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module cpu_top (
   input  logic clk_master,
   input  logic rst_n,
   output logic halt,
   output logic ir_load
);

import cpu_pkg::*;

// Internal clock signals
logic clk_core, clk_cntrl, clk_alu, sel_fetch_pc, clk_mem;

// Memory bus signals
logic [7:0]  addr;
logic [15:0] alu_out, data_out;
logic        mem_rd, mem_wr;

// Clock generator
sys_clk clkgen (
   .clk_master,
   .clk_core,
   .clk_cntrl,
   .clk_alu,
   .sel_fetch_pc,
   .clk_mem,
   .rst_n
);

// CPU instance
cpu_core cpu1 (
   .halt,
   .ir_load,
   .addr     (addr),
   .alu_out  (alu_out),
   .mem_rd   (mem_rd),
   .mem_wr   (mem_wr),
   .data_out (data_out),
   .clk_core,
   .clk_cntrl,
   .clk_alu,
   .sel_fetch_pc,
   .rst_n
);

// Memory instance
mem mem1 (
   .clk(clk_mem),
   .read    (mem_rd),
   .write   (mem_wr),
   .addr    (addr),
   .data_in (alu_out),
   .data_out(data_out)
);

endmodule : cpu_top
