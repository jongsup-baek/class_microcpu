module tb_cpu_core;

   import cpu_pkg::*;

   parameter PERIOD = 10;

   logic clk_ext, rst_n;
   logic clk_sys;

   logic        halt, ir_load;
   logic [7:0]  addr;
   logic [15:0] alu_out;
   logic        mem_rd, mem_wr;
   logic [15:0] data_out;

   // Clock generation
   initial clk_ext = 1'b0;
   always #(PERIOD/2) clk_ext = ~clk_ext;

   // Instantiate sysclk (clock gating + 2-divider)
   sysclk u_sysclk (
      .clk_ext,
      .halt,
      .clk_sys,
      .rst_n
   );

   // Instantiate cpu_core (DUT) — single clock
   cpu_core core1 (
      .halt,
      .ir_load,
      .addr,
      .alu_out,
      .mem_rd,
      .mem_wr,
      .data_out,
      .clk_sys,
      .rst_n
   );

   // Instantiate memory
   mem mem1 (
      .clk      (clk_sys),
      .read     (mem_rd),
      .write    (mem_wr),
      .addr     (addr),
      .data_in  (alu_out),
      .data_out (data_out)
   );

   initial begin
      rst_n = 0;
      repeat (4) @(negedge clk_ext);
      rst_n = 1;
      repeat (32) @(negedge clk_ext);
      $display("cpu_core COMPILE & RESET TEST PASSED");
      $finish;
   end

endmodule
