//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : regfile_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
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
   // Comment #1 : 레지스터 파일 모듈
















   // End Comment

endmodule
