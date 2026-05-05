//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab01_regfile_demo.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab01_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module regfile (
   output logic [15:0] rd_data,
   output logic [15:0] rs_data,
   input  logic [1:0]  rd_addr,
   input  logic [1:0]  rs_addr,
   input  logic [15:0] wr_data,
   input  logic [1:0]  wr_addr,
   input  logic        wr_en,
   input  logic        clk,
   input  logic        rst_n
);

   logic [15:0] regs [0:3];

   always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         regs[0] <= '0;
         regs[1] <= '0;
         regs[2] <= '0;
         regs[3] <= '0;
      end
      else if (wr_en) begin
         regs[wr_addr] <= wr_data;
      end
   end

   assign rd_data = regs[rd_addr];
   assign rs_data = regs[rs_addr];

endmodule

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

   initial begin
      // Comment #1 : 리셋 검증 -- rst_n=0 상태에서 모든 레지스터 0 확인
         rst_n   = 0;
         wr_en   = 0;
         wr_addr = 2'd0;
         wr_data = 16'h0000;
         rd_addr = 2'd0;
         rs_addr = 2'd1;
      @(posedge clk);
         rd_addr = 2'd2;
         rs_addr = 2'd3;
      // End Comment

      @(posedge clk);
      // Comment #2 : 쓰기 검증 -- R0~R3에 순차적으로 값 쓰기
         rst_n   = 1;              // reset 해제
         wr_en   = 1;
         wr_addr = 2'd0;
         wr_data = 16'hAAAA;
      @(posedge clk);
         wr_addr = 2'd1;
         wr_data = 16'hBBBB;
      @(posedge clk);
         wr_addr = 2'd2;
         wr_data = 16'hCCCC;
      @(posedge clk);
         wr_addr = 2'd3;
         wr_data = 16'hDDDD;
      // End Comment

      @(posedge clk);
      // Comment #3 : 읽기 검증 -- rd_addr/rs_addr 변경하며 값 확인
         wr_en   = 0;
         rd_addr = 2'd0;
         rs_addr = 2'd1;
      @(posedge clk);
         rd_addr = 2'd2;
         rs_addr = 2'd3;
      // End Comment

      @(posedge clk);
      // Comment #4 : 동시 읽기/쓰기 -- 쓰기 중 다른 주소 읽기
         wr_en   = 1;
         wr_addr = 2'd0;
         wr_data = 16'h1234;
         rd_addr = 2'd1;
         rs_addr = 2'd2;
      // End Comment

      @(posedge clk);
      // Comment #5 : wr_en 비활성 시 값 유지 확인
         wr_en   = 0;
         wr_addr = 2'd0;
         wr_data = 16'hFFFF;
         rd_addr = 2'd0;
         rs_addr = 2'd0;
      @(posedge clk);
      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab01_regfile");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  rst_n  wr_en  wr_addr  wr_data  rd_addr  rs_addr  rd_data  rs_data     #N
   //  ----  -----  -----  -------  -------  -------  -------  -------  -------  -----
   //     0      0      0        0     0000        0        1     0000     0000     #1
   //   100      0      0        0     0000        2        3     0000     0000     #1
   //   200      1      1        0     AAAA        2        3     0000     0000     #2
   //   300      1      1        1     BBBB        2        3     0000     0000     #2
   //   400      1      1        2     CCCC        2        3     CCCC     0000     #2
   //   500      1      1        3     DDDD        2        3     CCCC     DDDD     #2
   //   600      1      0        3     DDDD        0        1     AAAA     BBBB     #3
   //   700      1      0        3     DDDD        2        3     CCCC     DDDD     #3
   //   800      1      1        0     1234        1        2     BBBB     CCCC     #4
   //   900      1      0        0     FFFF        0        0     1234     1234     #5
   //  1000      1      0        0     FFFF        0        0     1234     1234     #5
   //////////////////////////////////////////////////////////
endmodule
