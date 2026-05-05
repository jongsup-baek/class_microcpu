//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab03_prog_counter_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab03_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

// Comment #1 : 프로그램 카운터 모듈



















// End Comment

module tb;
   bit clk = 0; initial forever #50 clk = ~clk;

   logic       rst_n, load, enable;
   logic [7:0] din;
   logic [7:0] pc_count;

   prog_counter u_pc (
      .pc_count (pc_count),
      .din      (din),
      .clk      (clk),
      .load     (load),
      .enable   (enable),
      .rst_n    (rst_n)
   );

   initial begin
      // Comment #2 : 리셋 검증






      // End Comment

      // Comment #3 : enable 카운트






      // End Comment

      // Comment #4 : load 값 로드









      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab03_prog_counter");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  enable  load  din  pc_count
   //  ----  -----  ------  ----  ---  --------
   //     0      0       0     0   00        00    #2
   //   100      0       0     0   00        00
   //   200      1       1     0   00        00    #3
   //   300      1       1     0   00        01
   //   400      1       1     0   00        02
   //   500      1       1     0   00        03
   //   600      1       0     1   F0        04    #4
   //   700      1       1     0   F0        F0
   //   800      1       1     0   F0        F1
   //   900      1       1     0   F0        F2
   //  1000      --      --    --  --        --
   //////////////////////////////////////////////////////////
endmodule
