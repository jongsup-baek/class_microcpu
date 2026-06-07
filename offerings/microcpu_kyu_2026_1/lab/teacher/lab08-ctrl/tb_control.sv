//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_control.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab04_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

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

   task reset_dut();
      #10;
         rst_n     = 0;
         ir_opcode = WFR;
         zero      = 0;
      @(posedge clk);
         rst_n = 1;
      @(posedge clk);
   endtask

   // Comment #1 : drive_fsm task
   task drive_fsm(input opcode_t op);
      ir_opcode = op;
      repeat(8) @(posedge clk);
   endtask
   // End Comment

   initial begin
      reset_dut();

      // Comment #2 : 전체 opcode 검증
      drive_fsm(ADD);
      drive_fsm(BRA);
      drive_fsm(STA);
      drive_fsm(WFR);
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
   //     0      0  INST_ADDR   WFR             0        0       0         0        0       0     0
   //   100      1  INST_ADDR   WFR             0        0       0         0        0       0     0
   //   200      1  INST_FETCH  ADD             1        0       0         0        0       0     0    #2
   //   300      1  INST_LOAD   ADD             1        1       0         0        0       0     0
   //   400      1  IDLE        ADD             1        1       0         0        0       0     0
   //   500      1  OP_ADDR     ADD             0        0       1         0        0       0     0
   //   600      1  OP_FETCH    ADD             1        0       0         0        0       0     0
   //   700      1  OP_ALU      ADD             1        0       0         1        0       0     0
   //   800      1  UPDATE      ADD             0        0       0         0        0       0     0
   //   900      1  INST_ADDR   ADD             0        0       0         0        0       0     0
   //  1000      1  INST_ADDR   BRA             0        0       0         0        0       0     0
   //  1100      1  INST_FETCH  BRA             1        0       0         0        0       0     0
   //  1200      1  INST_LOAD   BRA             1        1       0         0        0       0     0
   //  1300      1  IDLE        BRA             1        1       0         0        0       0     0
   //  1400      1  OP_ADDR     BRA             0        0       1         0        0       0     0
   //  1500      1  OP_FETCH    BRA             0        0       0         0        0       0     0
   //  1600      1  OP_ALU      BRA             0        0       0         0        1       0     0
   //  1700      1  UPDATE      BRA             0        0       0         0        0       0     0
   //  1800      1  INST_ADDR   STA             0        0       0         0        0       0     0
   //  1900      1  INST_FETCH  STA             1        0       0         0        0       0     0
   //  2000      1  INST_LOAD   STA             1        1       0         0        0       0     0
   //  2100      1  IDLE        STA             1        1       0         0        0       0     0
   //  2200      1  OP_ADDR     STA             0        0       1         0        0       0     0
   //  2300      1  OP_FETCH    STA             0        0       0         0        0       0     0
   //  2400      1  OP_ALU      STA             0        0       0         0        0       0     0
   //  2500      1  UPDATE      STA             0        0       0         0        0       1     0
   //  2600      1  INST_ADDR   WFR             0        0       0         0        0       0     0
   //  2700      1  INST_FETCH  WFR             1        0       0         0        0       0     0
   //  2800      1  INST_LOAD   WFR             1        1       0         0        0       0     0
   //  2900      1  IDLE        WFR             1        1       0         0        0       0     0
   //  3000      1  OP_ADDR     WFR             0        0       1         0        0       0     0
   //  3100      1  OP_ADDR     WFR             0        0       1         0        0       0     1
   //  3200      1  OP_ADDR     WFR             0        0       1         0        0       0     1
   //  3300      1  OP_ADDR     WFR             0        0       1         0        0       0     1
   //////////////////////////////////////////////////////////
endmodule
