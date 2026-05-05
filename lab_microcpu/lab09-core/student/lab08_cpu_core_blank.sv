//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab08_cpu_core_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab08_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk_ext = 0; initial forever #50 clk_ext = ~clk_ext;

   import cpu_pkg::*;

   logic        rst_n;
   logic        halt, ir_load;
   logic [7:0]  addr;
   logic [15:0] alu_out;
   logic        mem_rd, mem_wr;
   logic [15:0] data_out;
   logic        clk_sys;

   // Comment #1 : cpu_core 인스턴스



























   // End Comment

   initial begin
      // Comment #2 : 리셋 검증




      // End Comment

      // Comment #3 : Fetch/Execute 사이클 관찰

      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab08_cpu_core");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  clk_sys  halt  u_core.u_ctrl.state  addr  mem_rd  mem_wr
   //  ----  -----  -------  ----  -------------------  ----  ------  ------
   //     0      0        0     0  INST_ADDR              00       0       0    #2
   //   200      1        0     0  INST_ADDR              00       0       0
   //   -- FSM cycles through INST_ADDR → INST_FETCH → ... → UPDATE --      #3
   //   -- halt asserts when WFR opcode reaches OP_ADDR --
   //////////////////////////////////////////////////////////
endmodule
