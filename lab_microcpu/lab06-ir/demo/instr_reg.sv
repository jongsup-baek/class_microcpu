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
   output logic [7:0]  ir_addr,    // 주소 필드
   input  logic [15:0] din,        // 입력 데이터 (메모리에서)
   input  logic        clk,        // 클럭
   input  logic        enable,     // 래치 활성화
   input  logic        rst_n       // 비동기 리셋
);
   // Comment #1 : IR 모듈
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         ir_opcode <= WFR;
         ir_mode   <= 1'b0;
         ir_rd     <= 2'b0;
         ir_rs     <= 2'b0;
         ir_addr   <= 8'b0;
      end
      else if (enable) begin
         ir_opcode <= opcode_t'(din[15:13]);
         ir_mode   <= din[12];
         ir_rd     <= din[11:10];
         ir_rs     <= din[9:8];
         ir_addr   <= din[7:0];
      end
   end
   // End Comment

endmodule
