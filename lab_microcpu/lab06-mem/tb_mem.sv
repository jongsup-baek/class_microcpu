module tb_mem;

   import tb_pkg_lab06::*;

   logic        clk;
   logic        read, write;
   logic [7:0]  addr;
   logic [15:0] data_in, data_out;

   logic [15:0] actual_data;

   mem dut (.*);

   assign actual_data = data_out;

   // Clock generation
   initial clk = 1'b0;
   always #(PERIOD/2) clk = ~clk;

   // Monitor
   always @(negedge clk)
      $display("%0t: read=%b write=%b addr=%02h data_in=%04h data_out=%04h",
               $time, read, write, addr, data_in, data_out);

   // Timeout
   initial begin
      repeat (2999) @(negedge clk);
      $display("ERROR: Timeout!");
      $finish;
   end

   integer i;

   initial begin
      $display("=== Memory Test (256x16) ===");

      // Initialize
      {read, write, addr, data_in} = '0;

      // --- Test 1: Write zeros to first 16 locations ---
      $display("\n--- Test 1: Clear first 16 locations ---");
      for (i = 0; i < 16; i++)
         write_mem_16(clk, read, write, addr, data_in, i[7:0], 16'h0000);

      // Read back zeros
      for (i = 0; i < 16; i++) begin
         read_mem_16(clk, write, read, addr, i[7:0]);
         check_result_16bit($sformatf("mem[%02h]=0000", i), clk, actual_data, 16'h0000);
      end

      // --- Test 2: Write addr-based pattern ---
      $display("\n--- Test 2: Data = Address pattern ---");
      for (i = 0; i < 16; i++)
         write_mem_16(clk, read, write, addr, data_in, i[7:0], {8'h00, i[7:0]});

      for (i = 0; i < 16; i++) begin
         read_mem_16(clk, write, read, addr, i[7:0]);
         check_result_16bit($sformatf("mem[%02h]=%04h", i, i), clk, actual_data, {8'h00, i[7:0]});
      end

      // --- Test 3: 16-bit data ---
      $display("\n--- Test 3: 16-bit wide data ---");
      write_mem_16(clk, read, write, addr, data_in, 8'h80, 16'hCAFE);
      write_mem_16(clk, read, write, addr, data_in, 8'h81, 16'hBEEF);
      write_mem_16(clk, read, write, addr, data_in, 8'hFF, 16'hDEAD);

      read_mem_16(clk, write, read, addr, 8'h80);
      check_result_16bit("mem[80]=CAFE", clk, actual_data, 16'hCAFE);
      read_mem_16(clk, write, read, addr, 8'h81);
      check_result_16bit("mem[81]=BEEF", clk, actual_data, 16'hBEEF);
      read_mem_16(clk, write, read, addr, 8'hFF);
      check_result_16bit("mem[FF]=DEAD", clk, actual_data, 16'hDEAD);

      // --- Test 4: Overwrite ---
      $display("\n--- Test 4: Overwrite ---");
      write_mem_16(clk, read, write, addr, data_in, 8'h80, 16'h1111);
      read_mem_16(clk, write, read, addr, 8'h80);
      check_result_16bit("mem[80]=1111 overwrite", clk, actual_data, 16'h1111);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
