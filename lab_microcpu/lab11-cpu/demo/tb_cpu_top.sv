//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_cpu_top.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab11_blank.f -input ../../shm.tcl
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
      $readmemb("../program_code/test_arith.dat",
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
      $display("SIM DONE: lab11_cpu_top");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time   rst_n  halt  pc    설명
   //  -----  -----  ----  ----  ----
   //     50      0     0    00  reset
   //   1650      1     0    01  [1] NOT R0
   //   3250      1     0    02  NOT R0 (원복)
   //   4850      1     0    03  ADD R0,[0x82]
   //   6450      1     0    04  BRZ R0 (skip)
   //   8050      1     0    06  BRA 0x20
   //   9650      1     0    20  [2] LDA R0,[0x81]
   //  11250      1     0    21  AND R0,[0x80]
   //  12850      1     0    22  BRZ R0 (skip)
   //  14450      1     0    24  ADD R0,[0x81]
   //  16050      1     0    25  ADD R0,[0x83]
   //  17650      1     0    26  BRZ R0 (skip)
   //  19250      1     0    28  BRA 0x40
   //  20850      1     0    40  [3] LDA R0,[0x84]
   //  22450      1     0    41  LDA R1,[0x85]
   //  24050      1     0    42  NOT R1
   //  25650      1     0    43  ADD R1,[0x81]
   //  27250      1     0    44  ADD R0,R1 (m=1)
   //  28850      1     0    45  ADD R0,[0x86]
   //  30450      1     0    46  BRZ R0 (skip)
   //  32050      1     0    48  WFR
   //  32850      1     1    48  halt
   //////////////////////////////////////////////////////////
endmodule
