module tb_prog_counter;

   import cpu_pkg::*;
   import tb_pkg_lab03::*;

   logic [7:0] pc_count;
   logic [7:0] din;
   logic       clk, load, enable, rst_n;

   logic [7:0] actual_data;

   prog_counter dut (.*);

   assign actual_data = pc_count;

   // Clock generation
   initial clk = 1'b1;
   always #(PERIOD/2) clk = ~clk;

   // Monitor
   always @(negedge clk)
      $display("%0t: rst_n=%b load=%b enable=%b din=%02h pc_count=%02h",
               $time, rst_n, load, enable, din, pc_count);

   // Timeout
   initial begin
      repeat (199) @(negedge clk);
      $display("ERROR: Timeout!");
      $finish;
   end

   initial begin
      $display("=== Prog Counter Test (8-bit) ===");

      // Initialize
      {rst_n, load, enable, din} = '0;

      // --- Test 1: Reset ---
      $display("\n--- Test 1: Reset ---");
      rst_n = 0;
      check_result_8bit("Reset -> 00", clk, actual_data, 8'h00);

      // --- Test 2: Count up ---
      $display("\n--- Test 2: Count up ---");
      rst_n = 1; enable = 1; load = 0;
      check_result_8bit("Count 1", clk, actual_data, 8'h01);
      check_result_8bit("Count 2", clk, actual_data, 8'h02);
      check_result_8bit("Count 3", clk, actual_data, 8'h03);

      // --- Test 3: Hold (enable=0) ---
      $display("\n--- Test 3: Hold ---");
      enable = 0;
      check_result_8bit("Hold at 03", clk, actual_data, 8'h03);
      check_result_8bit("Hold at 03", clk, actual_data, 8'h03);

      // --- Test 4: Load ---
      $display("\n--- Test 4: Load ---");
      load = 1; din = 8'hA0;
      check_result_8bit("Load A0", clk, actual_data, 8'hA0);
      load = 0; enable = 1;
      check_result_8bit("Count A1", clk, actual_data, 8'hA1);
      check_result_8bit("Count A2", clk, actual_data, 8'hA2);

      // --- Test 5: Wrap around ---
      $display("\n--- Test 5: Wrap around ---");
      load = 1; din = 8'hFE;
      check_result_8bit("Load FE", clk, actual_data, 8'hFE);
      load = 0;
      check_result_8bit("Count FF", clk, actual_data, 8'hFF);
      check_result_8bit("Wrap 00", clk, actual_data, 8'h00);

      // --- Test 6: Load priority over enable ---
      $display("\n--- Test 6: Load priority ---");
      load = 1; enable = 1; din = 8'h50;
      check_result_8bit("Load wins: 50", clk, actual_data, 8'h50);

      // --- Test 7: Async reset mid-operation ---
      $display("\n--- Test 7: Async reset ---");
      rst_n = 0;
      check_result_8bit("Async reset -> 00", clk, actual_data, 8'h00);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
