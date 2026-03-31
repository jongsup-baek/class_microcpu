// Students: Implement your sys_clk here
// See microcpu/sv_src/sys_clk.sv for reference

module sys_clk (
   input  logic clk_master,
   output logic clk_core,
   output logic clk_cntrl,
   output logic clk_alu,
   output logic sel_fetch_pc,
   output logic clk_mem,
   input  logic rst_n
);

   // TODO: Declare 4-bit counter

   // TODO: Counter increment on posedge clk_master with async rst_n

   // TODO: Generate 5 phase clocks from counter bits
   //   clk_cntrl    = ~count[0]
   //   clk_core     =  count[1]
   //   sel_fetch_pc = ~count[3]
   //   clk_alu      = (count[3:1] == 3'b110)
   //   clk_mem      =  count[0]

endmodule : sys_clk
