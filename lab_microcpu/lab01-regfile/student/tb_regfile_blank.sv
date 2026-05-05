//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_regfile_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab01_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk = 0; initial forever #50 clk = ~clk;

   logic        rst_n;
   logic [1:0]  rd_addr, rs_addr;
   logic [1:0]  wr_addr;
   logic [15:0] wr_data;
   logic        wr_en;
   logic [15:0] rd_data, rs_data;

   regfile u_regfile (
      .rd_data (rd_data),
      .rs_data (rs_data),
      .rd_addr (rd_addr),
      .rs_addr (rs_addr),
      .wr_data (wr_data),
      .wr_addr (wr_addr),
      .wr_en   (wr_en),
      .clk     (clk),
      .rst_n   (rst_n)
   );

   // Comment #1 : task 정의
































   // End Comment

   initial begin
      // Comment #2 : 리셋 검증

      // End Comment

      // Comment #3 : 쓰기 검증




      // End Comment

      // Comment #4 : 읽기 검증


      // End Comment

      // Comment #5 : wr_en 비활성 쓰기 시도


      // End Comment

      // Comment #6 : 값 유지 확인

      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab01_regfile");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  wr_en  wr_addr  wr_data  rd_addr  rs_addr  rd_data  rs_data
   //  ----  -----  -----  -------  -------  -------  -------  -------  -------
   //     0      0      0        0     0000        0        0     0000     0000    #2
   //   100      1      0        0     0000        0        0     0000     0000
   //   200      1      1        0     AAAA        0        0     AAAA     AAAA    #3
   //   300      1      1        1     BBBB        0        0     AAAA     AAAA
   //   400      1      1        2     CCCC        0        0     AAAA     AAAA
   //   500      1      1        3     DDDD        0        0     AAAA     AAAA
   //   600      1      0        3     DDDD        0        1     AAAA     BBBB    #4
   //   700      1      0        3     DDDD        2        3     CCCC     DDDD
   //   800      1      0        0     EEEE        2        3     AAAA     AAAA    #5
   //   900      1      0        1     FFFF        2        3     AAAA     AAAA
   //  1000      1      0        1     FFFF        0        1     AAAA     BBBB    #6
   //////////////////////////////////////////////////////////
endmodule
