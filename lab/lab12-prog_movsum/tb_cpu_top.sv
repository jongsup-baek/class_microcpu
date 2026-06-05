//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_cpu_top.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab12_blank.f -input ../../shm.tcl
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
      $readmemb("../program_code/test_movsum.dat",
                 u_top.u_mem.memory);
      reset_dut();
      fork
         begin
            #200000;
            $display("TIMEOUT");
         end
         begin
            wait (halt == 1);
         end
      join_any
      disable fork;
      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab12_cpu_top");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time   rst_n  halt  pc    설명
   //  -----  -----  ----  ----  ----
   //     50      0     0    00  reset
   //   1650      1     0    01  LDA R3,[0xA0]  R3=7
   //   3250      1     0    02  BRA 0x10
   //  --- 1회차 (R3=7) ---
   //   4850      1     0    10  LDA R1,[0x81]  x[1]=7
   //   6450      1     0    11  LDA R2,R0      R2=3
   //   8050      1     0    12  ADD R2,R1      R2=10 (y[0])
   //   9650      1     0    13  LDA R0,R1      R0=7 (shift)
   //  11250      1     0    14  STA [0x90],R2  y[0]=10
   //  12850      1     0    15  BRA 0x20
   //  14450      1     0    20  LDA R2,[0x10]  self-modify x
   //  16050      1     0    21  ADD R2,[0xA1]
   //  17650      1     0    22  STA [0x10],R2
   //  19250      1     0    23  BRA 0x30
   //  20850      1     0    30  LDA R2,[0x14]  self-modify y
   //  22450      1     0    31  ADD R2,[0xA1]
   //  24050      1     0    32  STA [0x14],R2
   //  25650      1     0    33  BRA 0x40
   //  27250      1     0    40  ADD R3,[0xA2]  R3=6
   //  28850      1     0    42  BRA 0x10       loop
   //  --- 2회차 (R3=6) → y[1]=7+2=9 ---
   //  ...반복 7회...
   //  --- 7회차 (R3=1) ---
   //         1     0    40  ADD R3,[0xA2]  R3=0
   //         1     0    41  BRZ R3 (skip)
   //         1     0    43  WFR            이동합 완료!
   //         1     1    43  halt
   //
   //  결과: y = {10, 9, 7, 13, 9, 5, 10}
   //////////////////////////////////////////////////////////
endmodule
