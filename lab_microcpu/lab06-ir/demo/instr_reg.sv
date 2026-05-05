//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : instr_reg.sv
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
   output logic [7:0]  ir_data,    // 데이터/주소 필드
   input  logic [15:0] din,        // 입력 데이터 (메모리에서)
   input  logic        clk,        // 클럭
   input  logic        enable,     // 래치 활성화
   input  logic        rst_n       // 비동기 리셋
);
   // Comment #1 : IR 모듈
   logic [15:0] ir_out;

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
         ir_out <= '0;
      else if (enable)
         ir_out <= din;
   end

   assign ir_opcode = opcode_t'(ir_out[15:13]);
   assign ir_mode   = ir_out[12];
   assign ir_rd     = ir_out[11:10];
   assign ir_rs     = ir_out[9:8];
   assign ir_data   = ir_out[7:0];
   // End Comment

endmodule
