//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : tb_cpu_top.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f MCPUtest1.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb_cpu_top;
   import cpu_pkg::*;
   import tb_pkg::*;

   // Clock generator
   logic clk_master = 1'b1;
   always #(PERIOD/2) clk_master = ~clk_master;

   // Interface instance
   cpu_intf cif (.clk_master);

   // DUT
   cpu_top top (
      .clk_master,
      .rst_n   (cif.rst_n),
      .halt    (cif.halt),
      .ir_load (cif.ir_load)
   );

   // Test program selection via plusargs
   string testprog;
   int    expected_pc;

   initial begin
      // Get test program from command line (+TESTPROG=path)
      if (!$value$plusargs("TESTPROG=%s", testprog)) begin
         $display("ERROR: +TESTPROG=<path> required");
         $finish;
      end
      if (!$value$plusargs("EXPECT_PC=%d", expected_pc))
         expected_pc = -1;

      // Reset sequence
      cif.rst_n = 1;
      repeat (2) @(negedge clk_master);
      cif.rst_n = 0;
      repeat (2) @(negedge clk_master);

      // Load test program
      $readmemb(testprog, top.mem1.memory);
      cif.rst_n = 1;
      repeat (2) @(negedge clk_master);
      cif.rst_n = 0;
      repeat (2) @(negedge clk_master);
      cif.rst_n = 1;

      // Monitor
      $display("MicroCPU Test: Running %s ...", testprog);
      $display("     TIME       PC    INSTR  M  Rd   ADR   ALU_OUT   Rd_DATA");

      fork
         // Timeout watchdog
         begin
            #50000;
            $display("TIMEOUT: CPU did not halt within 50us");
            $finish;
         end

         // Wait for halt
         begin
            while (!cif.halt)
               @(posedge top.clk_core)
                  if (cif.ir_load) begin
                     #(PERIOD/2);
                     $display("%t    %02h    %s    %b  R%0d   %02h    %04h      %04h",
                              $time,
                              cif.pc_addr,
                              cif.ir_opcode.name(),
                              cif.ir_mode,
                              cif.ir_rd,
                              cif.addr,
                              cif.alu_out,
                              cif.rd_data);
                  end
         end
      join_any
      disable fork;

      // Check result
      if (expected_pc >= 0) begin
         if (cif.pc_addr === expected_pc[7:0])
            $display("\nMCPU TEST PASSED (halt at PC=0x%02h)", cif.pc_addr);
         else
            $display("\nMCPU TEST FAILED (PC=0x%02h, expected 0x%02h)",
                     cif.pc_addr, expected_pc[7:0]);
      end else begin
         $display("\nMCPU halted at PC=0x%02h", cif.pc_addr);
      end

      $finish;
   end

endmodule
