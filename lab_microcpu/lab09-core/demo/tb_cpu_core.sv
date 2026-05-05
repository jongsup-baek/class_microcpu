//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_cpu_core.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab09_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk_ext = 0; initial forever #50 clk_ext = ~clk_ext;

   import cpu_pkg::*;

   logic        rst_n;
   logic        halt, ir_load;
   logic [7:0]  addr;
   logic [15:0] alu_out;
   logic        mem_rd, mem_wr;
   logic [15:0] data_out;
   logic        clk_sys;

   sysclk u_sysclk (
      .clk_ext (clk_ext),
      .halt    (halt),
      .clk_sys (clk_sys),
      .rst_n   (rst_n)
   );

   cpu_core u_core (
      .halt     (halt),
      .ir_load  (ir_load),
      .addr     (addr),
      .alu_out  (alu_out),
      .mem_rd   (mem_rd),
      .mem_wr   (mem_wr),
      .data_out (data_out),
      .clk_sys  (clk_sys),
      .rst_n    (rst_n)
   );

   mem u_mem (
      .clk      (clk_sys),
      .read     (mem_rd),
      .write    (mem_wr),
      .addr     (addr),
      .data_in  (alu_out),
      .data_out (data_out)
   );

   task reset_dut();
      #10;
         rst_n = 0;
      @(posedge clk_ext);
      @(posedge clk_ext);
         rst_n = 1;
   endtask

   initial begin
      reset_dut();

      // Comment #1 : Fetch/Execute 사이클 관찰
      repeat (40) @(posedge clk_ext);
      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab09_cpu_core");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  clk_sys  halt  u_core.u_ctrl.state  addr  mem_rd  mem_wr
   //  ----  -----  -------  ----  -------------------  ----  ------  ------
   //     0      0        0     0  INST_ADDR              00       0       0
   //   200      1        0     0  INST_ADDR              00       0       0    #1
   //   -- FSM cycles through INST_ADDR → INST_FETCH → ... → UPDATE --
   //   -- halt asserts when WFR opcode reaches OP_ADDR --
   //////////////////////////////////////////////////////////
endmodule
