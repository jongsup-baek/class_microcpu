//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : instr_reg_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module instr_reg
   import cpu_pkg::*;
(
   output opcode_t     ir_opcode,  // 명령어 opcode
   output logic        ir_mode,    // 모드 비트
   output logic [1:0]  ir_rd,      // Rd 주소
   output logic [1:0]  ir_rs,      // Rs 주소
   output logic [7:0]  ir_addr,    // 주소 필드
   input  logic [15:0] din,        // 입력 데이터 (메모리에서)
   input  logic        clk,        // 클럭
   input  logic        enable,     // 래치 활성화
   input  logic        rst_n       // 비동기 리셋
);
   // Comment #1 : IR 모듈
















   // End Comment

endmodule
