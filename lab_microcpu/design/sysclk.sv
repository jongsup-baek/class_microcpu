//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : sysclk.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Clock gating + 2-divider
// clk_i = clk_ext & ~halt (gated clock)
// clk_sys = clk_i / 2     (internal clock for all blocks)
module sysclk (
   input  logic clk_ext,
   input  logic halt,
   output logic clk_sys,
   input  logic rst_n
);

wire clk_i = clk_ext & ~halt;

logic div;

always_ff @(posedge clk_i or negedge rst_n)
   if (!rst_n)
      div <= 1'b0;
   else
      div <= ~div;

assign clk_sys = div;

endmodule : sysclk
