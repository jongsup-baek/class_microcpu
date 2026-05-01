module tb_mux2to1;

   import tb_pkg_lab02::*;

   logic [7:0] dout;
   logic [7:0] din_a, din_b;
   logic       sel_a;

   logic        clk;
   logic [15:0] actual_data;

   mux2to1 #(8) dut (.*);

   assign actual_data = {8'h00, dout};

   // Clock generation (for check_result_16bit sync only)
   initial clk = 1'b1;
   always #(PERIOD/2) clk = ~clk;

   // Monitor
   always @(negedge clk)
      $display("%0t: sel_a=%b din_a=%02h din_b=%02h dout=%02h",
               $time, sel_a, din_a, din_b, dout);

   // Timeout
   initial begin
      repeat (99) @(negedge clk);
      $display("ERROR: Timeout!");
      $finish;
   end

   initial begin
      $display("=== mux2to1 Test (WIDTH=8) ===");

      // Initialize
      {sel_a, din_a, din_b} = '0;

      // --- Test 1: sel_a=1 selects din_a ---
      $display("\n--- Test 1: sel_a=1 -> din_a ---");
      din_a = 8'hAA; din_b = 8'h55; sel_a = 1;
      check_result_16bit("sel_a=1: dout=AA", clk, actual_data, 16'h00AA);

      din_a = 8'hFF; din_b = 8'h00; sel_a = 1;
      check_result_16bit("sel_a=1: dout=FF", clk, actual_data, 16'h00FF);

      // --- Test 2: sel_a=0 selects din_b ---
      $display("\n--- Test 2: sel_a=0 -> din_b ---");
      din_a = 8'hAA; din_b = 8'h55; sel_a = 0;
      check_result_16bit("sel_a=0: dout=55", clk, actual_data, 16'h0055);

      din_a = 8'h00; din_b = 8'hFF; sel_a = 0;
      check_result_16bit("sel_a=0: dout=FF", clk, actual_data, 16'h00FF);

      // --- Test 3: Toggle ---
      $display("\n--- Test 3: Toggle sel_a ---");
      din_a = 8'h12; din_b = 8'h34;
      sel_a = 1;
      check_result_16bit("toggle: sel=1 -> 12", clk, actual_data, 16'h0012);
      sel_a = 0;
      check_result_16bit("toggle: sel=0 -> 34", clk, actual_data, 16'h0034);
      sel_a = 1;
      check_result_16bit("toggle: sel=1 -> 12", clk, actual_data, 16'h0012);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
