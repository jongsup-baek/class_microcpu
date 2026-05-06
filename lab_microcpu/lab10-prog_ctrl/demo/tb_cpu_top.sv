//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_cpu_top.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab10_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk_ext = 0; initial forever #50 clk_ext = ~clk_ext;

   import cpu_pkg::*;

   logic rst_n;
   logic halt, ir_load;

   cpu_top u_top (
      .clk_ext (clk_ext),
      .rst_n   (rst_n),
      .halt    (halt),
      .ir_load (ir_load)
   );

   task reset_dut();
      #10;
         rst_n = 0;
      @(posedge clk_ext);
      @(posedge clk_ext);
         rst_n = 1;
   endtask

   initial begin
      // Comment #1 : 프로그램 로드 + 실행
      $readmemb("../program_code/test_ctrl.dat",
                 u_top.u_mem.memory);
      reset_dut();
      fork
         begin
            #50000;
            $display("TIMEOUT");
         end
         begin
            wait (halt == 1);
         end
      join_any
      disable fork;
      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab10_cpu_top");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time   rst_n  halt  pc    설명
   //  -----  -----  ----  ----  ----
   //     50      0     0    00  reset
   //   1650      1     0    05  BRA 0x05
   //   3250      1     0    20  BRA 0x20 → [2]
   //   4850      1     0    21  BRZ R0 (skip)
   //   6450      1     0    23  LDA R0,[0x81]
   //   8050      1     0    24  BRZ R0 (no skip)
   //   9650      1     0    25  BRA 0x40 → [3]
   //  11250      1     0    40  STA [0x82]
   //  12850      1     0    41  LDA R0,[0x80]
   //  14450      1     0    42  STA [0x82]
   //  16050      1     0    43  LDA R0,[0x82]
   //  17650      1     0    44  BRZ R0 (skip)
   //  19250      1     0    46  WFR
   //  20050      1     1    46  halt
   //////////////////////////////////////////////////////////
endmodule
