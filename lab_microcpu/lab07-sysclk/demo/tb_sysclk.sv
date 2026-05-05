//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_sysclk.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab07_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk_ext = 0; initial forever #50 clk_ext = ~clk_ext;

   logic rst_n, halt;
   logic clk_sys;

   sysclk u_sysclk (
      .clk_ext (clk_ext),
      .halt    (halt),
      .clk_sys (clk_sys),
      .rst_n   (rst_n)
   );

   task reset_dut();
      #10;
         rst_n = 0;
         halt  = 0;
      @(posedge clk_ext);
      @(posedge clk_ext);
         rst_n = 1;
   endtask

   initial begin
      reset_dut();

      // Comment #1 : 정상 2분주
      repeat(8) @(posedge clk_ext);
      // End Comment

      // Comment #2 : halt 시 클럭 정지
         halt = 1;
      repeat(4) @(posedge clk_ext);
      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab07_sysclk");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  halt  clk_sys
   //  ----  -----  ----  -------
   //     0      0     0     0       reset
   //   100      1     0     0
   //   200      1     0     1       #1
   //   300      1     0     0
   //   400      1     0     1
   //   500      1     0     0
   //   600      1     0     1
   //   700      1     0     0
   //   800      1     0     1
   //   900      1     0     0
   //  1000      1     1     0       #2
   //  1100      1     1     0
   //  1200      1     1     0
   //  1300      1     1     0
   //////////////////////////////////////////////////////////
endmodule
