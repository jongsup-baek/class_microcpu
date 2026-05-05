//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab07_sysclk_demo.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab07_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

// Comment #1 : sysclk 모듈
module sysclk (
   input  logic clk_ext,
   input  logic halt,
   output logic clk_sys,
   input  logic rst_n
);

   wire clk_i = clk_ext & ~halt;
   logic div;

   always_ff @(posedge clk_i or negedge rst_n) begin
      if (!rst_n)
         div <= 1'b0;
      else
         div <= ~div;
   end

   assign clk_sys = div;

endmodule
// End Comment

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

   initial begin
      // Comment #2 : 리셋 + 정상 2분주
         rst_n = 0;
         halt  = 0;
      @(posedge clk_ext);
      @(posedge clk_ext);
         rst_n = 1;
      @(posedge clk_ext);
      @(posedge clk_ext);
      @(posedge clk_ext);
      @(posedge clk_ext);
      @(posedge clk_ext);
      @(posedge clk_ext);
      // End Comment

      // Comment #3 : halt 시 클럭 정지
      @(posedge clk_ext);
         halt = 1;
      @(posedge clk_ext);
      @(posedge clk_ext);
      @(posedge clk_ext);
      @(posedge clk_ext);
      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab07_sysclk");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  halt  clk_ext  clk_sys
   //  ----  -----  ----  -------  -------
   //     0      0     0     0        0       #2
   //    50      0     0     1        0
   //   100      0     0     0        0
   //   150      1     0     1        1
   //   200      1     0     0        1
   //   250      1     0     1        0
   //   300      1     0     0        0
   //   350      1     0     1        1
   //   400      1     0     0        1
   //   450      1     0     1        0
   //   500      1     0     0        0
   //   550      1     0     1        1
   //   600      1     0     0        1
   //   650      1     0     1        0
   //   700      1     0     0        0
   //   750      1     0     1        1
   //   800      1     0     0        1
   //   850      1     1     1        0       #3
   //   900      1     1     0        0
   //   950      1     1     1        0
   //  1000      1     1     0        0
   //  1050      1     1     1        0
   //  1100      1     1     0        0
   //  1150      1     1     1        0
   //  1200      1     1     0        0
   //////////////////////////////////////////////////////////
endmodule
