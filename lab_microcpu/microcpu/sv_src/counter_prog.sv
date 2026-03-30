//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : counter_prog.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// 8-bit programmable counter with load and enable
// Extended from SimpleCPU's 5-bit counter
module counter_prog (
   output logic [7:0] pc_count,
   input  logic [7:0] din,
   input  logic       clk,
   input  logic       load,
   input  logic       enable,
   input  logic       rst_n
);

import cpu_pkg::*;

always_ff @(posedge clk, negedge rst_n)
   if (!rst_n)
      pc_count <= '0;
   else if (load)
      pc_count <= din;
   else if (enable)
      pc_count <= pc_count + 1;

endmodule
