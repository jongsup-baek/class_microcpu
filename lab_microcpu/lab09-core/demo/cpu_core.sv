//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : cpu_core.sv
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

// Comment #1 : 내부 신호 선언
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

// Comment #2 : 블록 인스턴스 연결
instr_reg u_ir (
   .ir_opcode,
   .ir_mode,
   .ir_rd,
   .ir_rs,
   .ir_data,
   .din    (data_out),
   .clk    (clk_sys),
   .enable (ir_load),
   .rst_n
);

regfile u_regfile (
   .rd_data (rd_data),
   .rs_data (rs_data),
   .rd_addr (ir_rd),
   .rs_addr (ir_rs),
   .wr_data (alu_out),
   .wr_addr (ir_rd),
   .wr_en   (load_reg),
   .clk     (clk_sys),
   .rst_n
);

prog_counter u_pc (
   .pc_count (pc_addr),
   .din      (ir_data),
   .clk      (clk_sys),
   .load     (pc_load),
   .enable   (pc_inc),
   .rst_n
);

mux2to1 #(16) u_opmux (
   .dout  (alu_operand),
   .din_a (data_out),
   .din_b (rs_data),
   .sel_a (~ir_mode)
);

alu u_alu (
   .dout   (alu_out),
   .zero   (alu_zero),
   .accum  (rd_data),
   .din    (alu_operand),
   .opcode (ir_opcode)
);

mux2to1 #(8) u_addrmux (
   .dout  (addr),
   .din_a (pc_addr),
   .din_b (ir_data),
   .sel_a (fetch_phase)
);

control u_ctrl (
   .load_reg (load_reg),
   .mem_rd,
   .mem_wr,
   .inc_pc   (pc_inc),
   .load_pc  (pc_load),
   .ir_load,
   .halt,
   .fetch_phase,
   .ir_opcode,
   .zero     (alu_zero),
   .clk      (clk_sys),
   .rst_n
);
// End Comment

endmodule : cpu_core
