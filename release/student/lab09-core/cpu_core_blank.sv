//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : cpu_core_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module cpu_core (
   output logic        halt,       // 정지
   output logic        ir_load,    // IR 로드
   output logic [7:0]  addr,       // 메모리 주소
   output logic [15:0] alu_out,    // ALU 출력
   output logic        mem_rd,     // 메모리 읽기
   output logic        mem_wr,     // 메모리 쓰기
   input  logic [15:0] data_out,   // 메모리 데이터 입력
   input  logic        clk_sys,    // 시스템 클럭
   input  logic        rst_n       // 비동기 리셋
);

import cpu_pkg::*;

opcode_t     ir_opcode;
logic        ir_mode;
logic [1:0]  ir_rd, ir_rs;
logic [7:0]  ir_data;
logic [15:0] rd_data, rs_data;
logic [7:0]  pc_addr;
logic [15:0] alu_operand;
logic        alu_zero;
logic        load_reg, pc_inc, pc_load, fetch_phase;
// End Comment

// Comment #1 : 블록 인스턴스 연결





































































// End Comment

endmodule : cpu_core
