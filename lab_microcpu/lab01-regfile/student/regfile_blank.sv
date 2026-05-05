//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : regfile_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////


module regfile (
   output logic [15:0] rd_data,   // Rd 포트 읽기 데이터
   output logic [15:0] rs_data,   // Rs 포트 읽기 데이터
   input  logic [1:0]  rd_addr,   // Rd 포트 주소
   input  logic [1:0]  rs_addr,   // Rs 포트 주소
   input  logic [15:0] wr_data,   // 쓰기 데이터
   input  logic [1:0]  wr_addr,   // 쓰기 주소
   input  logic        wr_en,     // 쓰기 활성화
   input  logic        clk,       // 클럭
   input  logic        rst_n      // 비동기 리셋 (active-low)
);
   // Comment #1 : 레지스터 파일 모듈
















   // End Comment

endmodule
