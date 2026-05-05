//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : control.sv
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
   state_t state;

   logic is_op_memrd, is_not, is_brz, is_bra, is_sta, is_wfr;

   assign is_op_memrd = (ir_opcode inside {ADD, AND, LDA});
   assign is_not      = (ir_opcode == NOT);
   assign is_brz      = (ir_opcode == BRZ);
   assign is_bra      = (ir_opcode == BRA);
   assign is_sta      = (ir_opcode == STA);
   assign is_wfr      = (ir_opcode == WFR);

   // state FF
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
         state <= INST_ADDR;
      else if (!halt)
         state <= state.next();
   end

   // 출력 FF — next-state 기반
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= 6'b0;
         fetch_phase <= 1'b1;
         halt        <= 1'b0;
      end
      else if (!halt) begin
         fetch_phase <= (state.next() inside {INST_ADDR, INST_FETCH, INST_LOAD, IDLE});

         case (state.next())
            INST_ADDR : begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= 6'b0;
            end
            INST_FETCH: begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= 6'b100_000;
            end
            INST_LOAD : begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= 6'b110_000;
            end
            IDLE      : begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= 6'b110_000;
            end
            OP_ADDR   : begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= 6'b001_000;
               halt <= is_wfr;
            end
            OP_FETCH  : begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= {is_op_memrd, 5'b0};
            end
            OP_ALU    : begin
               mem_rd   <= is_op_memrd;
               ir_load  <= 1'b0;
               inc_pc   <= is_brz && zero;
               load_reg <= is_op_memrd | is_not;
               load_pc  <= is_bra;
               mem_wr   <= 1'b0;
            end
            UPDATE    : begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc} <= 5'b0;
               mem_wr <= is_sta;
            end
            default   : begin
               {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} <= 6'b0;
            end
         endcase
      end
   end
   // End Comment

endmodule
