//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_regfile.sv
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

   task reset_dut();
      #10;
         rst_n   = 0;
         wr_en   = 0;
         wr_addr = 2'd0;
         wr_data = 16'h0000;
         rd_addr = 2'd0;
         rs_addr = 2'd0;
      @(posedge clk);
      @(posedge clk);
         rst_n = 1;
      @(posedge clk);
   endtask

   // Comment #1 : write_reg task
   task write_reg(input logic [1:0] addr, input logic [15:0] data);
         wr_en   = 1;
         wr_addr = addr;
         wr_data = data;
      @(posedge clk);
   endtask

   task read_reg(input logic [1:0] rd, input logic [1:0] rs);
         wr_en   = 0;
         rd_addr = rd;
         rs_addr = rs;
      @(posedge clk);
   endtask
   // End Comment

   // Comment #3 : write_nowr task
   task write_nowr(input logic [1:0] addr, input logic [15:0] data);
         wr_en   = 0;
         wr_addr = addr;
         wr_data = data;
      @(posedge clk);
   endtask
   // End Comment

   
   initial begin
      reset_dut();

      // Comment #2 : 쓰기 검증
      write_reg(2'd0, 16'hAAAA);
      write_reg(2'd1, 16'hBBBB);
      write_reg(2'd2, 16'hCCCC);
      write_reg(2'd3, 16'hDDDD);

      read_reg(2'd0, 2'd1);
      read_reg(2'd2, 2'd3);
      // End Comment

      // Comment #4 : wr_en 비활성 쓰기 시도
      write_nowr(2'd0, 16'hEEEE);
      write_nowr(2'd1, 16'hFFFF);

      read_reg(2'd0, 2'd1);
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
   //     0      0      0        0     0000        0        0     0000     0000
   //   100      1      0        0     0000        0        0     0000     0000
   //   200      1      1        0     AAAA        0        0     AAAA     AAAA    #2
   //   300      1      1        1     BBBB        0        0     AAAA     AAAA
   //   400      1      1        2     CCCC        0        0     AAAA     AAAA
   //   500      1      1        3     DDDD        0        0     AAAA     AAAA
   //   600      1      0        3     DDDD        0        1     AAAA     BBBB
   //   700      1      0        3     DDDD        2        3     CCCC     DDDD
   //   800      1      0        0     EEEE        2        3     AAAA     AAAA    #4
   //   900      1      0        1     FFFF        2        3     AAAA     AAAA
   //  1000      1      0        1     FFFF        0        1     AAAA     BBBB
   //////////////////////////////////////////////////////////
endmodule
