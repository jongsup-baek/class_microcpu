//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_alu_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab05_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk = 0; initial forever #50 clk = ~clk;

   import cpu_pkg::*;

   opcode_t     opcode;
   logic [15:0] accum, din;
   logic [15:0] dout;
   logic        zero;

   alu u_alu (
      .dout   (dout),
      .zero   (zero),
      .accum  (accum),
      .din    (din),
      .opcode (opcode)
   );

   task reset_dut();
      #10;
         opcode = WFR;
         accum  = 16'h0000;
         din    = 16'h0000;
      @(posedge clk);
   endtask

   // Comment #1 : drive_alu task






   // End Comment

   initial begin
      reset_dut();

      // Comment #2 : ADD/AND 연산




      // End Comment

      // Comment #3 : NOT/LDA 연산


      // End Comment

      // Comment #4 : BRZ zero 플래그 확인


      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab05_alu");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  opcode  accum  din    dout   zero
   //  ----  ------  -----  -----  -----  ----
   //     0  WFR     0000   0000   0000   1
   //   100  ADD     0010   0020   0030   0       #2
   //   200  ADD     FFFF   0001   0000   1
   //   300  AND     FF00   0F0F   0F00   0
   //   400  AND     AAAA   5555   0000   1
   //   500  NOT     00FF   0000   FF00   0       #3
   //   600  LDA     0000   BEEF   BEEF   0
   //   700  BRZ     0000   0000   0000   1       #4
   //   800  BRZ     1234   0000   1234   0
   //////////////////////////////////////////////////////////
endmodule
