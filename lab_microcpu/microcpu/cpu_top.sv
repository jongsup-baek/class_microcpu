//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : cpu_top.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module cpu_top (
   input  logic clk_ext,
   input  logic rst_n,
   output logic halt,
   output logic ir_load
);

import cpu_pkg::*;

// Internal gated clock
logic clk_sys;

// Memory bus signals
logic [7:0]  addr;
logic [15:0] alu_out, data_out;
logic        mem_rd, mem_wr;

// Clock gating
sysclk u_sysclk (
   .clk_ext,
   .halt,
   .clk_sys,
   .rst_n
);

// CPU instance
cpu_core u_cpu_core (
   .halt,
   .ir_load,
   .addr     (addr),
   .alu_out  (alu_out),
   .mem_rd   (mem_rd),
   .mem_wr   (mem_wr),
   .data_out (data_out),
   .clk_sys  (clk_sys),
   .rst_n
);

// Memory instance
mem u_mem (
   .clk      (clk_sys),
   .read    (mem_rd),
   .write   (mem_wr),
   .addr    (addr),
   .data_in (alu_out),
   .data_out(data_out)
);

endmodule : cpu_top
