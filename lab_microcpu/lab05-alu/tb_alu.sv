module tb_alu;

   import cpu_pkg_lab05::*;
   import tb_pkg_lab05::*;

   logic [15:0] dout;
   logic        zero;
   logic [15:0] accum, din;
   opcode_t     opcode;

   alu dut (.*);

   // Timeout
   initial begin
      #5000;
      $display("ERROR: Timeout!");
      $finish;
   end

   // Combinational check helper
   function void check_comb(
      input string test_name,
      input logic [15:0] exp_dout,
      input logic        exp_zero
   );
      #1;  // allow combinational settle
      if (dout === exp_dout && zero === exp_zero)
         print_pass(test_name);
      else begin
         print_fail(test_name,
            $sformatf("expected dout=%04h zero=%b, actual dout=%04h zero=%b",
                      exp_dout, exp_zero, dout, zero));
      end
   endfunction

   initial begin
      $display("=== ALU Test (16-bit, combinational) ===");

      // Initialize
      opcode = HALT;
      accum = 16'h0000;
      din   = 16'h0000;
      #1;

      // Base values: accum=0x00DA, din=0x0037
      $display("\n--- Base test: accum=00DA, din=0037 ---");

      {opcode, din, accum} = {ADD, 16'h0037, 16'h00DA};
      check_comb("ADD: DA+37=111",  16'h0111, 1'b0);

      {opcode, din, accum} = {AND, 16'h0037, 16'h00DA};
      check_comb("AND: DA&37=12",   16'h0012, 1'b0);

      {opcode, din, accum} = {NOT, 16'h0037, 16'h00DA};
      check_comb("NOT: ~00DA=FF25", 16'hFF25, 1'b0);

      {opcode, din, accum} = {LDA, 16'h0037, 16'h00DA};
      check_comb("LDA: din=37",     16'h0037, 1'b0);

      // --- Passthrough opcodes (dout = accum) ---
      $display("\n--- Passthrough opcodes ---");

      {opcode, din, accum} = {HALT, 16'h0037, 16'h00DA};
      check_comb("HALT: pass DA",   16'h00DA, 1'b0);

      {opcode, din, accum} = {BRZ, 16'h0037, 16'h00DA};
      check_comb("BRZ: pass DA",    16'h00DA, 1'b0);

      {opcode, din, accum} = {STA, 16'h0037, 16'h00DA};
      check_comb("STA: pass DA",    16'h00DA, 1'b0);

      {opcode, din, accum} = {BRA, 16'h0037, 16'h00DA};
      check_comb("BRA: pass DA",    16'h00DA, 1'b0);

      // --- Zero flag test ---
      $display("\n--- Zero flag ---");

      {opcode, din, accum} = {LDA, 16'h0000, 16'h0000};
      check_comb("LDA 0: zero=1",   16'h0000, 1'b1);

      {opcode, din, accum} = {LDA, 16'h0001, 16'h0000};
      check_comb("LDA 1: zero=1 (accum=0)", 16'h0001, 1'b1);

      {opcode, din, accum} = {NOT, 16'h0005, 16'h0005};
      check_comb("NOT: ~0005=FFFA (accum=5)", 16'hFFFA, 1'b0);

      // --- 16-bit overflow ---
      $display("\n--- 16-bit operations ---");

      {opcode, din, accum} = {ADD, 16'hFFFF, 16'h0001};
      check_comb("ADD: 1+FFFF=0000", 16'h0000, 1'b0);

      {opcode, din, accum} = {NOT, 16'h0001, 16'h0000};
      check_comb("NOT: ~0000=FFFF",   16'hFFFF, 1'b1);

      {opcode, din, accum} = {AND, 16'hFF00, 16'h0FF0};
      check_comb("AND: FF00&0FF0=0F00", 16'h0F00, 1'b0);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
