module tb_regfile;

   import tb_pkg_lab01::*;

   logic [15:0] rd_data, rs_data;
   logic [1:0]  rd_addr, rs_addr;
   logic [15:0] wr_data;
   logic [1:0]  wr_addr;
   logic        wr_en;
   logic        clk, rst_n;

   logic [15:0] actual_rd, actual_rs;

   regfile dut (.*);

   assign actual_rd = rd_data;
   assign actual_rs = rs_data;

   // Clock generation
   initial clk = 1'b1;
   always #(PERIOD/2) clk = ~clk;

   // Monitor
   always @(negedge clk)
      $display("%0t: rst_n=%b wr_en=%b wr_addr=%0d wr_data=%04h | rd_addr=%0d rd_data=%04h | rs_addr=%0d rs_data=%04h",
               $time, rst_n, wr_en, wr_addr, wr_data, rd_addr, rd_data, rs_addr, rs_data);

   // Timeout
   initial begin
      repeat (199) @(negedge clk);
      $display("ERROR: Timeout!");
      $finish;
   end

   initial begin
      $display("=== Register File Test ===");

      // Initialize
      {rst_n, wr_en, wr_addr, wr_data, rd_addr, rs_addr} = '0;

      // --- Test 1: Reset ---
      $display("\n--- Test 1: Reset ---");
      rst_n = 0;
      rd_addr = 2'd0; rs_addr = 2'd1;
      check_result_16bit("R0 after reset", clk, actual_rd, 16'h0000);
      rd_addr = 2'd2; rs_addr = 2'd3;
      check_result_16bit("R2 after reset", clk, actual_rd, 16'h0000);
      check_result_16bit("R3 after reset", clk, actual_rs, 16'h0000);

      // --- Test 2: Write R0, R1, R2, R3 ---
      $display("\n--- Test 2: Write all registers ---");
      rst_n = 1;

      wr_en = 1; wr_addr = 2'd0; wr_data = 16'hCAFE;
      check_result_16bit("Write R0=CAFE (pending)", clk, actual_rd, 16'h0000);

      // After posedge, R0 should have CAFE
      rd_addr = 2'd0;
      wr_addr = 2'd1; wr_data = 16'hBEEF;
      check_result_16bit("R0=CAFE readback", clk, actual_rd, 16'hCAFE);

      rd_addr = 2'd1;
      wr_addr = 2'd2; wr_data = 16'h1234;
      check_result_16bit("R1=BEEF readback", clk, actual_rd, 16'hBEEF);

      rd_addr = 2'd2;
      wr_addr = 2'd3; wr_data = 16'h5678;
      check_result_16bit("R2=1234 readback", clk, actual_rd, 16'h1234);

      rd_addr = 2'd3;
      wr_en = 0;
      check_result_16bit("R3=5678 readback", clk, actual_rd, 16'h5678);

      // --- Test 3: Hold (wr_en=0) ---
      $display("\n--- Test 3: Hold (wr_en=0) ---");
      wr_en = 0; wr_addr = 2'd0; wr_data = 16'hFFFF;
      rd_addr = 2'd0;
      check_result_16bit("R0 hold (wr_en=0)", clk, actual_rd, 16'hCAFE);

      // --- Test 4: Dual read port ---
      $display("\n--- Test 4: Dual read ports ---");
      rd_addr = 2'd0; rs_addr = 2'd1;
      check_result_16bit("rd_data=R0", clk, actual_rd, 16'hCAFE);
      check_result_16bit("rs_data=R1", clk, actual_rs, 16'hBEEF);

      rd_addr = 2'd2; rs_addr = 2'd3;
      check_result_16bit("rd_data=R2", clk, actual_rd, 16'h1234);
      check_result_16bit("rs_data=R3", clk, actual_rs, 16'h5678);

      // --- Test 5: Overwrite ---
      $display("\n--- Test 5: Overwrite R0 ---");
      wr_en = 1; wr_addr = 2'd0; wr_data = 16'h9999;
      rd_addr = 2'd0;
      @(negedge clk);  // wait for write
      check_result_16bit("R0=9999 after overwrite", clk, actual_rd, 16'h9999);

      // --- Test 6: Mid-operation reset ---
      $display("\n--- Test 6: Mid-operation reset ---");
      rst_n = 0;
      rd_addr = 2'd0; rs_addr = 2'd1;
      check_result_16bit("R0=0 after re-reset", clk, actual_rd, 16'h0000);
      check_result_16bit("R1=0 after re-reset", clk, actual_rs, 16'h0000);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
