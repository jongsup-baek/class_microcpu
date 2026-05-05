//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_cpu_top.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab10_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk_ext = 0; initial forever #50 clk_ext = ~clk_ext;

   import cpu_pkg::*;

   logic rst_n;
   logic halt, ir_load;

   cpu_top u_top (
      .clk_ext (clk_ext),
      .rst_n   (rst_n),
      .halt    (halt),
      .ir_load (ir_load)
   );

   task reset_dut();
      #10;
         rst_n = 0;
      @(posedge clk_ext);
      @(posedge clk_ext);
         rst_n = 1;
   endtask

   initial begin
      // Comment #1 : 프로그램 로드 + 실행
      $readmemb("../program_code/MCPUtest1.dat",
                 u_top.u_mem.memory);
      reset_dut();
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
      $display("SIM DONE: lab10_cpu_top");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  halt  u_top.u_cpu_core.u_ctrl.state  u_top.u_cpu_core.u_pc.pc_count
   //  ----  -----  ----  ----------------------------  ------------------------------
   //     0      0     0  INST_ADDR                       00
   //   200      1     0  INST_ADDR                       00    #1
   //   -- FSM executes MCPUtest1 instructions --
   //   -- halt asserts at end of program --
   //////////////////////////////////////////////////////////
endmodule
