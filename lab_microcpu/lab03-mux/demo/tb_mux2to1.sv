//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_mux2to1.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab02_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk = 0; initial forever #50 clk = ~clk;

   logic [7:0] din_a, din_b;
   logic       sel_a;
   logic [7:0] dout;

   mux2to1 #(8) u_mux (
      .dout  (dout),
      .din_a (din_a),
      .din_b (din_b),
      .sel_a (sel_a)
   );

   task reset_dut();
      #10;
         din_a = 8'h00;
         din_b = 8'h00;
         sel_a = 0;
      @(posedge clk);
   endtask

   // Comment #1 : drive_mux task
   task drive_mux(input logic [7:0] a, input logic [7:0] b, input logic s);
         din_a = a;
         din_b = b;
         sel_a = s;
      @(posedge clk);
   endtask
   // End Comment

   initial begin
      reset_dut();

      // Comment #2 : sel_a=1 → din_a 선택
      drive_mux(8'hAA, 8'h55, 1);
      drive_mux(8'hFF, 8'h00, 1);
      // End Comment

      @(posedge clk);

      // Comment #3 : sel_a=0 → din_b 선택
      drive_mux(8'hAA, 8'h55, 0);
      drive_mux(8'h00, 8'hFF, 0);
      // End Comment

      @(posedge clk);

      // Comment #4 : sel_a 토글
      drive_mux(8'h12, 8'h34, 1);
      drive_mux(8'h12, 8'h34, 0);
      drive_mux(8'h12, 8'h34, 1);
      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab02_mux2to1");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  sel_a  din_a  din_b  dout
   //  ----  -----  -----  -----  ----
   //     0  0      00     00     00
   //   100  1      AA     55     AA     #2
   //   200  1      FF     00     FF
   //   300  --     --     --     --
   //   400  0      AA     55     55     #3
   //   500  0      00     FF     FF
   //   600  --     --     --     --
   //   700  1      12     34     12     #4
   //   800  0      12     34     34
   //   900  1      12     34     12
   //  1000  --     --     --     --
   //////////////////////////////////////////////////////////
endmodule
