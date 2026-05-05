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
      
      foreach (u_mem.memory[i]) u_mem.memory[i] = '0;

      reset_dut();

      // Comment #1 : halt 대기
      fork
         begin
            #50000;
            $display("TIMEOUT");
         end
         begin
            wait (halt == 1);
         end
      join_any
      disable fork;
      // End Comment

      @(posedge clk_ext);
      $display("SIM DONE: lab09_cpu_core");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  clk_sys  halt  state       addr  mem_rd  mem_wr
   //  ----  -----  -------  ----  ----------  ----  ------  ------
   //    50      0        0     0  INST_ADDR     00       0       0
   //   150      0        0     0  INST_ADDR     00       0       0
   //   250      1        1     0  INST_FETCH    00       1       0    #1
   //   350      1        0     0  INST_FETCH    00       1       0
   //   450      1        1     0  INST_LOAD     00       1       0
   //   550      1        0     0  INST_LOAD     00       1       0
   //   650      1        1     0  IDLE          00       1       0
   //   750      1        0     0  IDLE          00       1       0
   //   850      1        1     1  OP_ADDR       00       0       0
   //////////////////////////////////////////////////////////
endmodule
