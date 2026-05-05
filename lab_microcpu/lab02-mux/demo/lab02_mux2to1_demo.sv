//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab02_mux2to1_demo.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab02_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

// Comment #1 : 2:1 MUX 모듈
module mux2to1 #(WIDTH = 8) (
   output logic [WIDTH-1:0] dout,
   input  logic [WIDTH-1:0] din_a,
   input  logic [WIDTH-1:0] din_b,
   input  logic             sel_a
);

   assign dout = sel_a ? din_a : din_b;

endmodule
// End Comment

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

   initial begin
      @(posedge clk);

      // Comment #2 : sel_a=1 → din_a 선택
      @(posedge clk);
         din_a = 8'hAA;
         din_b = 8'h55;
         sel_a = 1;

      @(posedge clk);
         din_a = 8'hFF;
         din_b = 8'h00;
         sel_a = 1;
      // End Comment

      @(posedge clk);

      // Comment #3 : sel_a=0 → din_b 선택
      @(posedge clk);
         din_a = 8'hAA;
         din_b = 8'h55;
         sel_a = 0;

      @(posedge clk);
         din_a = 8'h00;
         din_b = 8'hFF;
         sel_a = 0;
      // End Comment

      @(posedge clk);

      // Comment #4 : sel_a 토글
      @(posedge clk);
         din_a = 8'h12;
         din_b = 8'h34;
         sel_a = 1;

      @(posedge clk);
         sel_a = 0;

      @(posedge clk);
         sel_a = 1;
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
   //     0  x      xx     xx     xx
   //   100  --     --     --     --
   //   200  1      AA     55     AA     #2
   //   300  1      FF     00     FF
   //   400  --     --     --     --
   //   500  0      AA     55     55     #3
   //   600  0      00     FF     FF
   //   700  --     --     --     --
   //   800  1      12     34     12     #4
   //   900  0      --     --     34
   //  1000  1      --     --     12
   //  1100  --     --     --     --
   //////////////////////////////////////////////////////////
endmodule
