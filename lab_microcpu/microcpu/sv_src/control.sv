//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : control.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// CPU control sequencer — single clock FSM
// 8-state Moore FSM, all outputs registered
module control
   import cpu_pkg::*;
(
   output logic    load_reg,
   output logic    mem_rd,
   output logic    mem_wr,
   output logic    inc_pc,
   output logic    load_pc,
   output logic    ir_load,
   output logic    halt,
   output logic    fetch_phase,
   input  opcode_t ir_opcode,
   input  logic    zero,
   input  logic    clk,
   input  logic    rst_n
);

state_t state;

logic is_op_memrd, is_not, is_brz, is_bra, is_sta, is_wfr;

assign is_op_memrd = (ir_opcode inside {ADD, AND, LDA});
assign is_not      = (ir_opcode == NOT);
assign is_brz      = (ir_opcode == BRZ);
assign is_bra      = (ir_opcode == BRA);
assign is_sta      = (ir_opcode == STA);
assign is_wfr      = (ir_opcode == WFR);

// state FF
always_ff @(posedge clk or negedge rst_n)
   if (!rst_n)
      state <= INST_ADDR;
   else if (!halt)
      state <= state.next();

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

endmodule
