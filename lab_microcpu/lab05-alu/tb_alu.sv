module tb_alu;

   import cpu_pkg_lab05::*;
   import tb_pkg_lab05::*;

   logic [15:0] dout;
   logic        zero;
   logic        clk;
   logic [15:0] accum, din;
   opcode_t     opcode;

   // {zero, dout} = 17 bits
   logic [16:0] actual_data;
   assign actual_data = {zero, dout};

   alu dut (.*);

   // Clock generation
   initial clk = 1'b1;
   always #(PERIOD/2) clk = ~clk;

   // Monitor
   always @(negedge clk)
      $display("%0t: opcode=%s accum=%04h din=%04h -> dout=%04h zero=%b",
               $time, opcode.name(), accum, din, dout, zero);

   // Timeout
   initial begin
      repeat (200) @(negedge clk);
      $display("ERROR: Timeout!");
      $finish;
   end

   initial begin
      $display("=== ALU Test (16-bit) ===");

      // Initialize
      opcode = HALT;
      accum = 16'h0000;
      din   = 16'h0000;
      @(negedge clk);

      // Base values: accum=0x00DA, din=0x0037
      $display("\n--- Base test: accum=00DA, din=0037 ---");

      {opcode, din, accum} = {ADD, 16'h0037, 16'h00DA};
      check_result_17bit("ADD: DA+37=111",  clk, actual_data, {1'b0, 16'h0111});

      {opcode, din, accum} = {AND, 16'h0037, 16'h00DA};
      check_result_17bit("AND: DA&37=12",   clk, actual_data, {1'b0, 16'h0012});

      {opcode, din, accum} = {SUB, 16'h0037, 16'h00DA};
      check_result_17bit("SUB: DA-37=A3",   clk, actual_data, {1'b0, 16'h00A3});

      {opcode, din, accum} = {LDA, 16'h0037, 16'h00DA};
      check_result_17bit("LDA: din=37",     clk, actual_data, {1'b0, 16'h0037});

      // --- Passthrough opcodes (dout <= accum) ---
      $display("\n--- Passthrough opcodes ---");

      {opcode, din, accum} = {HALT, 16'h0037, 16'h00DA};
      check_result_17bit("HALT: pass DA",   clk, actual_data, {1'b0, 16'h00DA});

      {opcode, din, accum} = {BRZ, 16'h0037, 16'h00DA};
      check_result_17bit("BRZ: pass DA",    clk, actual_data, {1'b0, 16'h00DA});

      {opcode, din, accum} = {STA, 16'h0037, 16'h00DA};
      check_result_17bit("STA: pass DA",    clk, actual_data, {1'b0, 16'h00DA});

      {opcode, din, accum} = {BRA, 16'h0037, 16'h00DA};
      check_result_17bit("BRA: pass DA",    clk, actual_data, {1'b0, 16'h00DA});

      // --- Zero flag test ---
      $display("\n--- Zero flag ---");

      {opcode, din, accum} = {LDA, 16'h0000, 16'h0000};
      check_result_17bit("LDA 0: zero=1",   clk, actual_data, {1'b1, 16'h0000});

      {opcode, din, accum} = {LDA, 16'h0001, 16'h0000};
      check_result_17bit("LDA 1: zero=1 (accum=0)", clk, actual_data, {1'b1, 16'h0001});

      {opcode, din, accum} = {SUB, 16'h0005, 16'h0005};
      check_result_17bit("SUB 5-5: zero=0 (accum=5)", clk, actual_data, {1'b0, 16'h0000});

      // --- 16-bit overflow ---
      $display("\n--- 16-bit operations ---");

      {opcode, din, accum} = {ADD, 16'hFFFF, 16'h0001};
      check_result_17bit("ADD: 1+FFFF=0000", clk, actual_data, {1'b0, 16'h0000});

      {opcode, din, accum} = {SUB, 16'h0001, 16'h0000};
      check_result_17bit("SUB: 0-1=FFFF",    clk, actual_data, {1'b1, 16'hFFFF});

      {opcode, din, accum} = {AND, 16'hFF00, 16'h0FF0};
      check_result_17bit("AND: FF00&0FF0=0F00", clk, actual_data, {1'b0, 16'h0F00});

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
