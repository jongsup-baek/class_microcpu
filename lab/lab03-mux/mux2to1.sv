//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : mux2to1.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module mux2to1 #(WIDTH = 8) (
   output logic [WIDTH-1:0] dout,    // 출력 데이터
   input  logic [WIDTH-1:0] din_a,   // 입력 A
   input  logic [WIDTH-1:0] din_b,   // 입력 B
   input  logic             sel_a    // 선택 (1=A, 0=B)
);
   // Comment #1 : 2:1 MUX 모듈
   assign dout = sel_a ? din_a : din_b;
   // End Comment

endmodule
