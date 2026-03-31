module tb_sys_clk;

   import tb_pkg_lab07::*;

   logic clk_master;
   logic rst_n;
   logic clk_core, clk_cntrl, clk_alu, sel_fetch_pc, clk_mem;

   sys_clk dut (.*);

   // Clock generation
   initial clk_master = 1'b0;
   always #(PERIOD/2) clk_master = ~clk_master;

   // Monitor
   always @(negedge clk_master)
      $display("%0t: count=%0d  clk_mem=%b clk_cntrl=%b clk_core=%b clk_alu=%b sel_fetch_pc=%b",
               $time, dut.count, clk_mem, clk_cntrl, clk_core, clk_alu, sel_fetch_pc);

   // Timeout
   initial begin
      repeat (99) @(negedge clk_master);
      $display("ERROR: Timeout!");
      $finish;
   end

   logic [3:0] cnt;
   integer cyc;

   initial begin
      $display("=== sys_clk Test ===");

      // Initialize
      rst_n = 0;

      // --- Test 1: Reset ---
      $display("\n--- Test 1: Reset ---");
      repeat (2) @(negedge clk_master);
      check_comb_1bit("reset: clk_mem=0",      clk_mem,      1'b0);
      check_comb_1bit("reset: clk_cntrl=1",    clk_cntrl,    1'b1);
      check_comb_1bit("reset: clk_core=0",     clk_core,     1'b0);
      check_comb_1bit("reset: clk_alu=0",      clk_alu,      1'b0);
      check_comb_1bit("reset: sel_fetch_pc=1",  sel_fetch_pc, 1'b1);

      // --- Test 2: Full 16-cycle pattern (x2) ---
      $display("\n--- Test 2: 32-cycle pattern ---");
      rst_n = 1;
      for (cyc = 1; cyc <= 32; cyc++) begin
         @(negedge clk_master);
         cnt = cyc[3:0];
         check_comb_1bit($sformatf("cyc%02d: clk_mem",      cyc), clk_mem,       cnt[0]);
         check_comb_1bit($sformatf("cyc%02d: clk_cntrl",    cyc), clk_cntrl,    ~cnt[0]);
         check_comb_1bit($sformatf("cyc%02d: clk_core",     cyc), clk_core,      cnt[1]);
         check_comb_1bit($sformatf("cyc%02d: clk_alu",      cyc), clk_alu,       (cnt[3:1] == 3'b110));
         check_comb_1bit($sformatf("cyc%02d: sel_fetch_pc",  cyc), sel_fetch_pc, ~cnt[3]);
      end

      // --- Test 3: Mid-operation reset ---
      $display("\n--- Test 3: Mid-operation reset ---");
      repeat (5) @(negedge clk_master);
      rst_n = 0;
      repeat (2) @(negedge clk_master);
      check_comb_1bit("mid-reset: clk_mem=0",     clk_mem,      1'b0);
      check_comb_1bit("mid-reset: clk_cntrl=1",   clk_cntrl,    1'b1);
      check_comb_1bit("mid-reset: clk_core=0",    clk_core,     1'b0);
      check_comb_1bit("mid-reset: clk_alu=0",     clk_alu,      1'b0);
      check_comb_1bit("mid-reset: sel_fetch_pc=1", sel_fetch_pc, 1'b1);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
