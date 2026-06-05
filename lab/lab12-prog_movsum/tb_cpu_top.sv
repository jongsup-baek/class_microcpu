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
   // Expected Waveform (SimVision) — 시뮬레이션 검증 완료
   //////////////////////////////////////////////////////////
   //  time      pc   R0    R1    R2    R3    설명
   //  --------  --   ----  ----  ----  ----  ----
   //      4500  00   0000  0000  0000  0000  reset 후
   //     20500  01   0003  0000  0000  0000  LDA R0,[0x80]
   //     36500  02   0003  0000  0000  0007  LDA R3,[0xA0]
   //     52500  10   0003  0000  0000  0007  BRA 0x10 (1회차)
   //     68500  11   0003  0007  0000  0007  LDA R1,[0x81]
   //     84500  12   0003  0007  0003  0007  LDA R2,R0
   //    100500  13   0003  0007  000a  0007  ADD → y[0]=10
   //    116500  14   0007  0007  000a  0007  shift
   //    132500  15   0007  0007  000a  0007  STA [0x90]
   //    292500  41   0007  0007    *   0006  R3=6 (2회차로)
   //    372500  13   0007  0002  0009  0006  y[1]=9
   //    644500  13   0002  0005  0007  0005  y[2]=7
   //    916500  13   0005  0008  000d  0004  y[3]=13
   //   1188500  13   0008  0001  0009  0003  y[4]=9
   //   1460500  13   0001  0004  0005  0002  y[5]=5
   //   1732500  13   0004  0006  000a  0001  y[6]=10
   //   1924500  41   0006  0006    *   0000  BRZ R3 (skip)
   //   1940500  43   0006  0006    *   0000  WFR → halt
   //
   //  결과: y = {10, 9, 7, 13, 9, 5, 10}
   //  $finish = 194450ns
   //////////////////////////////////////////////////////////
endmodule
