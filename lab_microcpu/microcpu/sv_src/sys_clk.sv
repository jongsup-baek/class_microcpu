//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : sys_clk.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Clock divider generating CPU internal clock phases
// Identical to SimpleCPU — same 5-phase structure
module sys_clk (
   input  logic clk_master,
   output logic clk_core,
   output logic clk_cntrl,
   output logic clk_alu,
   output logic sel_fetch_pc,
   output logic clk_mem,
   input  logic rst_n
);

logic [3:0] count;

always @(posedge clk_master or negedge rst_n)
   if (~rst_n)
      count <= 4'b0;
   else
      count <= count + 1;

assign clk_cntrl    = ~count[0];
assign clk_core     =  count[1];
assign sel_fetch_pc = ~count[3];
assign clk_alu      =  (count[3:1] == 3'b110);
assign clk_mem      =  count[0];

endmodule : sys_clk
