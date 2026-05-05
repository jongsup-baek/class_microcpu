//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : alu.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module alu
   import cpu_pkg::*;
(
   output logic [15:0] dout,      // ALU 출력
   output logic        zero,      // zero 플래그
   input  logic [15:0] accum,     // 누산기 입력
   input  logic [15:0] din,       // 데이터 입력
   input  opcode_t     opcode     // 연산 선택
);
   // Comment #1 : ALU 모듈
   always_comb begin
      unique case (opcode)
         ADD     : dout = accum + din;
         AND     : dout = accum & din;
         NOT     : dout = ~accum;
         LDA     : dout = din;
         default : dout = accum;
      endcase
   end

   assign zero = ~(|accum);
   // End Comment

endmodule
