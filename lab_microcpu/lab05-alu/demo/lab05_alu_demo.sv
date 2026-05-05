//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab05_alu_demo.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab05_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

package cpu_pkg;
   typedef enum logic [2:0] {WFR, BRZ, BRA, LDA, STA, ADD, AND, NOT} opcode_t;
   typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                             OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;
endpackage : cpu_pkg

// Comment #1 : ALU 모듈
module alu
   import cpu_pkg::*;
(
   output logic [15:0] dout,
   output logic        zero,
   input  logic [15:0] accum,
   input  logic [15:0] din,
   input  opcode_t     opcode
);

   always_comb begin
      unique case (opcode)
         ADD     : dout = accum + din;
         AND     : dout = accum & din;
         NOT     : dout = ~accum;
         LDA     : dout = din;
         default : dout = accum;
      endcase
   end

   assign zero = ~(|accum);

endmodule
// End Comment

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

   initial begin
      @(posedge clk);

      // Comment #2 : ADD 연산
      @(posedge clk);
         opcode = ADD;
         accum  = 16'h0010;
         din    = 16'h0020;

      @(posedge clk);
         accum  = 16'hFFFF;
         din    = 16'h0001;
      // End Comment

      @(posedge clk);

      // Comment #3 : AND 연산
      @(posedge clk);
         opcode = AND;
         accum  = 16'hFF00;
         din    = 16'h0F0F;

      @(posedge clk);
         accum  = 16'hAAAA;
         din    = 16'h5555;
      // End Comment

      @(posedge clk);

      // Comment #4 : NOT/LDA 연산과 zero 플래그
      @(posedge clk);
         opcode = NOT;
         accum  = 16'h00FF;

      @(posedge clk);
         opcode = LDA;
         din    = 16'hBEEF;

      @(posedge clk);
         opcode = ADD;
         accum  = 16'h0000;
         din    = 16'h0000;
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
   //     0  WFR     xxxx   xxxx   xxxx   x
   //   100  --      --     --     --     --
   //   200  ADD     0010   0020   0030   0       #2
   //   300  ADD     FFFF   0001   0000   0
   //   400  --      --     --     --     --
   //   500  AND     FF00   0F0F   0F00   0       #3
   //   600  AND     AAAA   5555   0000   0
   //   700  --      --     --     --     --
   //   800  NOT     00FF   --     FF00   0       #4
   //   900  LDA     --     BEEF   BEEF   0
   //  1000  ADD     0000   0000   0000   1
   //  1100  --      --     --     --     --
   //////////////////////////////////////////////////////////
endmodule
