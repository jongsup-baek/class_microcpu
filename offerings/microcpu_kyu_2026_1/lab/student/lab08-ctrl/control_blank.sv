//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : control_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module control
   import cpu_pkg::*;
(
   output logic    load_reg,     // 레지스터 쓰기
   output logic    mem_rd,       // 메모리 읽기
   output logic    mem_wr,       // 메모리 쓰기
   output logic    inc_pc,       // PC 증가
   output logic    load_pc,      // PC 로드
   output logic    ir_load,      // IR 로드
   output logic    halt,         // 정지
   output logic    fetch_phase,  // 페치 구간 표시
   input  opcode_t ir_opcode,    // 명령어 opcode
   input  logic    zero,         // ALU zero 플래그
   input  logic    clk,          // 클럭
   input  logic    rst_n         // 비동기 리셋
);
   // Comment #1 : control FSM 모듈




































































   // End Comment

endmodule
