module tb_control;

   import cpu_pkg_lab04::*;
   import tb_pkg_lab04::*;

   logic    load_reg, mem_rd, mem_wr, inc_pc, load_pc, load_ir, halt;
   opcode_t ir_opcode;
   logic    zero, clk, rst_n;

   // Pack 7 control outputs into 8 bits for uniform check
   // Bit: [7]=0, [6]=mem_rd, [5]=load_ir, [4]=halt, [3]=inc_pc, [2]=load_reg, [1]=load_pc, [0]=mem_wr
   logic [7:0] actual_data;
   assign actual_data = {1'b0, mem_rd, load_ir, halt, inc_pc, load_reg, load_pc, mem_wr};

   control ctrl (.*);

   // Clock generation
   initial clk = 1'b1;
   always #(PERIOD/2) clk = ~clk;

   // Monitor
   always @(negedge clk)
      $display("%0t: rst_n=%b state=%s zero=%b opcode=%s ctrl=%07b",
               $time, rst_n, ctrl.state.name(), zero, ir_opcode.name(), actual_data[6:0]);

   // Timeout
   initial begin
      repeat (1200) @(negedge clk);
      $display("ERROR: Timeout!");
      $finish;
   end

   initial begin
      $display("=== Control FSM Test ===");

      // Initialize
      ir_opcode = HALT;
      zero = 0;
      rst_n = 0;

      // Reset and advance to known state (INST_ADDR)
      @(negedge clk);
      rst_n = 1;
      repeat (7) @(negedge clk);

      // --- HALT ---
      $display("\n--- HALT ---");
      ir_opcode = HALT; zero = 0;
      //                      0_mrd_lir_hlt_ipc_lrg_lpc_mwr
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_1_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      // --- ADD ---
      $display("\n--- ADD ---");
      ir_opcode = ADD; zero = 0;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_1_0_0_0_1_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      // --- AND ---
      $display("\n--- AND ---");
      ir_opcode = AND; zero = 0;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_1_0_0_0_1_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      // --- SUB ---
      $display("\n--- SUB ---");
      ir_opcode = SUB; zero = 0;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_1_0_0_0_1_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      // --- LDA ---
      $display("\n--- LDA ---");
      ir_opcode = LDA; zero = 0;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_1_0_0_0_1_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      // --- STA ---
      $display("\n--- STA ---");
      ir_opcode = STA; zero = 0;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_1);

      // --- BRA ---
      $display("\n--- BRA ---");
      ir_opcode = BRA; zero = 0;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_0_0_0_0_0_1_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      // --- BRZ (zero=0, not taken) ---
      $display("\n--- BRZ (zero=0) ---");
      ir_opcode = BRZ; zero = 0;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      // --- BRZ (zero=1, taken — skip next) ---
      $display("\n--- BRZ (zero=1) ---");
      ir_opcode = BRZ; zero = 1;
      check_result_8bit("S0 INST_ADDR",  clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S1 INST_FETCH", clk, actual_data, 8'b0_1_0_0_0_0_0_0);
      check_result_8bit("S2 INST_LOAD",  clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S3 IDLE",       clk, actual_data, 8'b0_1_1_0_0_0_0_0);
      check_result_8bit("S4 OP_ADDR",    clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S5 OP_FETCH",   clk, actual_data, 8'b0_0_0_0_0_0_0_0);
      check_result_8bit("S6 OP_ALU",     clk, actual_data, 8'b0_0_0_0_1_0_0_0);
      check_result_8bit("S7 UPDATE",     clk, actual_data, 8'b0_0_0_0_0_0_0_0);

      $display("\n=== All tests PASSED ===");
      $finish;
   end

endmodule
