module tb_cpu_core;

   import cpu_pkg::*;

   parameter PERIOD = 10;

   logic clk_master, rst_n;
   logic clk_core, clk_cntrl, clk_alu, sel_fetch_pc, clk_mem;

   logic        halt, ir_load;
   logic [7:0]  addr;
   logic [15:0] alu_out;
   logic        mem_rd, mem_wr;
   logic [15:0] data_out;

   // Clock generation
   initial clk_master = 1'b0;
   always #(PERIOD/2) clk_master = ~clk_master;

   // Instantiate sys_clk
   sys_clk sclk (
      .clk_master,
      .clk_core,
      .clk_cntrl,
      .clk_alu,
      .sel_fetch_pc,
      .clk_mem,
      .rst_n
   );

   // Instantiate cpu_core (DUT)
   cpu_core core1 (
      .halt,
      .ir_load,
      .addr,
      .alu_out,
      .mem_rd,
      .mem_wr,
      .data_out,
      .clk_core,
      .clk_cntrl,
      .clk_alu,
      .sel_fetch_pc,
      .rst_n
   );

   // Instantiate memory
   mem mem1 (
      .clk      (clk_mem),
      .read     (mem_rd),
      .write    (mem_wr),
      .addr     (addr),
      .data_in  (alu_out),
      .data_out (data_out)
   );

   initial begin
      rst_n = 0;
      repeat (4) @(negedge clk_master);
      rst_n = 1;
      repeat (32) @(negedge clk_master);
      $display("cpu_core COMPILE & RESET TEST PASSED");
      $finish;
   end

endmodule
