//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab06_mem_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab06_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

// Comment #1 : 동기 메모리 모듈






















// End Comment

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

   initial begin
      // Comment #2 : 쓰기 검증
















      // End Comment

      // Comment #3 : 읽기 검증









      // End Comment

      // Comment #4 : 읽기/쓰기 동시 — 무시











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
   //   500      0     1    00     CCCC      xxxx    #3
   //   600      0     1    01     --        AAAA
   //   700      0     1    02     --        BBBB
   //   800      0     0    02     --        CCCC
   //   900      1     1    00     FFFF      --      #4
   //  1000      0     1    00     FFFF      --
   //  1100      0     0    00     --        AAAA
   //  1200      --    --   --     --        --
   //////////////////////////////////////////////////////////
endmodule
