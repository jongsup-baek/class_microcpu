//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab04_control_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab04_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

package cpu_pkg;
   typedef enum logic [2:0] {HALT, BRZ, BRA, LDA, STA, ADD, AND, NOT} opcode_t;
   typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                             OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;
endpackage : cpu_pkg

// Comment #1 : control FSM 모듈




























































// End Comment

module tb;
   bit clk = 0; initial forever #50 clk = ~clk;

   import cpu_pkg::*;

   opcode_t ir_opcode;
   logic    zero, rst_n;
   logic    load_reg, mem_rd, mem_wr, inc_pc, load_pc, ir_load, halt, fetch_phase;

   control u_ctrl (
      .load_reg    (load_reg),
      .mem_rd      (mem_rd),
      .mem_wr      (mem_wr),
      .inc_pc      (inc_pc),
      .load_pc     (load_pc),
      .ir_load     (ir_load),
      .halt        (halt),
      .fetch_phase (fetch_phase),
      .ir_opcode   (ir_opcode),
      .zero        (zero),
      .clk         (clk),
      .rst_n       (rst_n)
   );

   initial begin
      // Comment #2 : 리셋 + ADD Fetch 사이클









      // End Comment

      // Comment #3 : ADD Execute 사이클




      // End Comment

      // Comment #4 : BRA Execute 사이클









      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab04_control");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  state       ir_opcode  mem_rd  ir_load  inc_pc  load_reg  load_pc  mem_wr  halt
   //  ----  -----  ----------  ---------  ------  -------  ------  --------  -------  ------  ----
   //     0      0  INST_ADDR   ADD             0        0       0         0        0       0     0    #2
   //   100      1  INST_ADDR   ADD             0        0       0         0        0       0     0
   //   200      1  INST_FETCH  ADD             1        0       0         0        0       0     0
   //   300      1  INST_LOAD   ADD             1        1       0         0        0       0     0
   //   400      1  IDLE        ADD             1        1       0         0        0       0     0
   //   500      1  OP_ADDR     ADD             0        0       1         0        0       0     0    #3
   //   600      1  OP_FETCH    ADD             1        0       0         0        0       0     0
   //   700      1  OP_ALU      ADD             1        0       0         1        0       0     0
   //   800      1  UPDATE      ADD             0        0       0         0        0       0     0
   //   900      1  INST_ADDR   BRA             0        0       0         0        0       0     0    #4
   //  1000      1  INST_FETCH  BRA             1        0       0         0        0       0     0
   //  1100      1  INST_LOAD   BRA             1        1       0         0        0       0     0
   //  1200      1  IDLE        BRA             1        1       0         0        0       0     0
   //  1300      1  OP_ADDR     BRA             0        0       1         0        0       0     0
   //  1400      1  OP_FETCH    BRA             0        0       0         0        0       0     0
   //  1500      1  OP_ALU      BRA             0        0       0         0        1       0     0
   //  1600      1  UPDATE      BRA             0        0       0         0        0       0     0
   //  1700      --  --          --             --       --      --        --       --      --    --
   //////////////////////////////////////////////////////////
endmodule
