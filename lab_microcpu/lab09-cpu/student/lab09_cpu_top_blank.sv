//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab09_cpu_top_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab09_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk_ext = 0; initial forever #50 clk_ext = ~clk_ext;

   import cpu_pkg::*;

   logic rst_n;
   logic halt, ir_load;

   // Comment #1 : cpu_top 인스턴스






   // End Comment

   initial begin
      // Comment #2 : 리셋 + 프로그램 로드






      // End Comment

      // Comment #3 : 프로그램 실행 — halt 대기











      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab09_cpu_top");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  halt  u_top.u_cpu_core.u_ctrl.state  u_top.u_cpu_core.u_pc.pc_count
   //  ----  -----  ----  ----------------------------  ------------------------------
   //     0      0     0  INST_ADDR                                                00    #2
   //   200      1     0  INST_ADDR                                                00
   //   -- FSM executes MCPUtest1 instructions --                                        #3
   //   -- halt asserts at end of program --
   //////////////////////////////////////////////////////////
endmodule
