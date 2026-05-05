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
      $display("SIM DONE: lab12_cpu_top");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time   rst_n  halt  pc    설명
   //  -----  -----  ----  ----  ----
   //  time   rst_n  halt  pc    설명
   //  -----  -----  ----  ----  ----
   //     50      0     0    00  reset
   //   1650      1     0    01  C[0][0]: ADD R0,[0x80]
   //   3250      1     0    02  STA [0x88]
   //   4850      1     0    03  C[0][1]: LDA R0,[0x91]
   //   6450      1     0    04  LDA R1,[0x80]
   //   8050      1     0    05  NOT R1
   //   9650      1     0    06  ADD R1,[0x90]
   //  11250      1     0    07  ADD R0,R1 (m=1)
   //  12850      1     0    08  ADD R0,[0x81]
   //  14450      1     0    09  STA [0x89]
   //  16050      1     0    0A  C[1][0]: LDA R0,[0x91]
   //  17650      1     0    0B  ADD R0,[0x82]
   //  19250      1     0    0C  STA [0x8A]
   //  20850      1     0    0D  C[1][1]: LDA R0,[0x91]
   //  22450      1     0    0E  LDA R1,[0x82]
   //  24050      1     0    0F  NOT R1
   //  25650      1     0    10  ADD R1,[0x90]
   //  27250      1     0    11  ADD R0,R1 (m=1)
   //  28850      1     0    12  ADD R0,[0x83]
   //  30450      1     0    13  STA [0x8B]
   //  32050      1     0    14  WFR
   //  32850      1     1    14  halt
   //////////////////////////////////////////////////////////
endmodule
