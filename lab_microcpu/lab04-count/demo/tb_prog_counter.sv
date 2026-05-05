//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_prog_counter.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab03_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

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

   task reset_dut();
      #10;
         rst_n  = 0;
         load   = 0;
         enable = 0;
         din    = 8'h00;
      @(posedge clk);
      @(posedge clk);
         rst_n = 1;
      @(posedge clk);
   endtask

   // Comment #1 : enable_pc_duration/load_pc task
   task enable_pc_duration(input int n);
         enable = 1;
         load   = 0;
      repeat(n) @(posedge clk);
   endtask

   task load_pc(input logic [7:0] val);
         enable = 0;
         load   = 1;
         din    = val;
      @(posedge clk);
   endtask
   // End Comment

   initial begin
      reset_dut();

      // Comment #2 : enable 카운트
      enable_pc_duration(4);
      // End Comment

      // Comment #3 : load 값 로드 후 카운트
      load_pc(8'hF0);
      enable_pc_duration(3);
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
   //     0      0       0     0   00        00
   //   100      1       0     0   00        00
   //   200      1       1     0   00        00    #2
   //   300      1       1     0   00        01
   //   400      1       1     0   00        02
   //   500      1       1     0   00        03
   //   600      1       0     1   F0        04    #3
   //   700      1       1     0   F0        F0
   //   800      1       1     0   F0        F1
   //   900      1       1     0   F0        F2
   //  1000      1       1     0   F0        F3
   //  1100      --      --    --  --        --
   //////////////////////////////////////////////////////////
endmodule
