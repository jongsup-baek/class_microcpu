//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : prog_counter_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module prog_counter (
   output logic [7:0] pc_count,  // 카운터 출력
   input  logic [7:0] din,       // 로드 데이터
   input  logic       clk,       // 클럭
   input  logic       load,      // 로드 활성화
   input  logic       enable,    // 카운트 활성화
   input  logic       rst_n      // 비동기 리셋 (active-low)
);
   // Comment #1 : 프로그램 카운터 모듈








   // End Comment

endmodule
