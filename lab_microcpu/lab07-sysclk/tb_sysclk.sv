module tb_sysclk;

   import tb_pkg_lab07::*;

   logic clk_ext;
   logic halt;
   logic clk_sys;
   logic rst_n;

   sysclk dut (.*);

   // Clock generation
   initial clk_ext = 1'b0;
   always #(PERIOD/2) clk_ext = ~clk_ext;

   // Monitor
   always @(negedge clk_ext)
      $display("%0t: halt=%b clk_sys=%b", $time, halt, clk_sys);

   // Timeout
   initial begin
      repeat (99) @(negedge clk_ext);
      $display("ERROR: Timeout!");
      $finish;
   end

   initial begin
      $display("=== sysclk Test (clock gating + 2-divider) ===");

      // Initialize
      rst_n = 0;
      halt  = 0;

      // --- Test 1: Reset ---
      $display("\n--- Test 1: Reset ---");
      repeat (2) @(negedge clk_ext);
      check_comb_1bit("reset: clk_sys=0", clk_sys, 1'b0);

      // --- Test 2: Normal 2-divider ---
      $display("\n--- Test 2: Normal 2-divider (halt=0) ---");
      rst_n = 1;
      @(negedge clk_ext);  // div toggles 0->1
      check_comb_1bit("cyc1: clk_sys=1", clk_sys, 1'b1);
      @(negedge clk_ext);  // div toggles 1->0
      check_comb_1bit("cyc2: clk_sys=0", clk_sys, 1'b0);
      @(negedge clk_ext);  // div toggles 0->1
      check_comb_1bit("cyc3: clk_sys=1", clk_sys, 1'b1);
      @(negedge clk_ext);  // div toggles 1->0
      check_comb_1bit("cyc4: clk_sys=0", clk_sys, 1'b0);

      // --- Test 3: Halt gating ---
      $display("\n--- Test 3: Halt gating ---");
      halt = 1;
      @(negedge clk_ext);
      logic clk_before;
      clk_before = clk_sys;
      @(negedge clk_ext);
      check_comb_1bit("halt: clk_sys frozen", clk_sys, clk_before);
      @(negedge clk_ext);
      check_comb_1bit("halt: clk_sys still frozen", clk_sys, clk_before);

      // --- Test 4: Resume after halt ---
      $display("\n--- Test 4: Resume after halt ---");
      halt = 0;
      @(negedge clk_ext);
      // clock should toggle again
      logic clk_resumed;
      clk_resumed = clk_sys;
      @(negedge clk_ext);
      check_comb_1bit("resume: clk_sys toggled", clk_sys, ~clk_resumed);

      // --- Test 5: Mid-operation reset ---
      $display("\n--- Test 5: Mid-operation reset ---");
      repeat (3) @(negedge clk_ext);
      rst_n = 0;
      repeat (2) @(negedge clk_ext);
      check_comb_1bit("mid-reset: clk_sys=0", clk_sys, 1'b0);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
