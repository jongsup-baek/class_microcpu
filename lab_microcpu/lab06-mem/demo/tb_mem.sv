//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_mem.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab06_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk = 0; initial forever #50 clk = ~clk;

   logic        read, write;
   logic [7:0]  addr;
   logic [15:0] data_in, data_out;

   mem u_mem (
      .clk      (clk),
      .read     (read),
      .write    (write),
      .addr     (addr),
      .data_in  (data_in),
      .data_out (data_out)
   );

   task reset_dut();
      #10;
         read    = 0;
         write   = 0;
         addr    = 8'h00;
         data_in = 16'h0000;
      @(posedge clk);
   endtask

   // Comment #1 : write_mem/read_mem task
   task write_mem(input logic [7:0] a, input logic [15:0] d);
         write   = 1;
         read    = 0;
         addr    = a;
         data_in = d;
      @(posedge clk);
   endtask

   task read_mem(input logic [7:0] a);
         write = 0;
         read  = 1;
         addr  = a;
      @(posedge clk);
   endtask

   task idle();
         write = 0;
         read  = 0;
      @(posedge clk);
   endtask
   // End Comment

   initial begin
      reset_dut();

      // Comment #2 : 쓰기 후 읽기 검증
      write_mem(8'h00, 16'hAAAA);
      write_mem(8'h01, 16'hBBBB);
      write_mem(8'h02, 16'hCCCC);
      idle();
      read_mem(8'h00);
      read_mem(8'h01);
      read_mem(8'h02);
      idle();
      // End Comment

      // Comment #3 : 읽기/쓰기 동시 — 무시
      @(posedge clk);
         read    = 1;
         write   = 1;
         addr    = 8'h00;
         data_in = 16'hFFFF;
      @(posedge clk);
      read_mem(8'h00);
      idle();
      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab06_mem");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  write  read  addr  data_in  data_out
   //  ----  -----  ----  ----  -------  --------
   //     0      0     0    00     0000      xxxx
   //   100      1     0    00     AAAA      xxxx    #2
   //   200      1     0    01     BBBB      xxxx
   //   300      1     0    02     CCCC      xxxx
   //   400      0     0    02     CCCC      xxxx
   //   500      0     1    00     CCCC      xxxx
   //   600      0     1    01     --        AAAA
   //   700      0     1    02     --        BBBB
   //   800      0     0    02     --        CCCC
   //   900      1     1    00     FFFF      --      #3
   //  1000      0     1    00     FFFF      --
   //  1100      0     0    00     --        AAAA
   //////////////////////////////////////////////////////////
endmodule
