//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : control.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// CPU control sequencer — single clock FSM
// 8-state Mealy FSM, one state per clk_ext cycle
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

logic op_memrd;

assign op_memrd = (ir_opcode inside {ADD, AND, LDA});
wire is_not = (ir_opcode == NOT);

// halt latch — once asserted, held until rst_n
always_ff @(posedge clk or negedge rst_n)
   if (!rst_n)
      halt <= 1'b0;
   else if (state == OP_ADDR && ir_opcode == WFR)
      halt <= 1'b1;

// fetch_phase — high during Fetch (S0~S3), low during Execute (S4~S7)
assign fetch_phase = (state inside {INST_ADDR, INST_FETCH, INST_LOAD, IDLE});

always_ff @(posedge clk or negedge rst_n)
   if (!rst_n)
      state <= INST_ADDR;
   else if (!halt)
      state <= state.next();

always_comb begin
   {mem_rd, ir_load, inc_pc, load_reg, load_pc, mem_wr} = 6'b000_000;
   case (state)
      INST_ADDR : ;
      INST_FETCH: mem_rd = 1;
      INST_LOAD : begin
         mem_rd  = 1;
         ir_load = 1;
      end
      IDLE      : begin
         mem_rd  = 1;
         ir_load = 1;
      end
      OP_ADDR   : begin
         inc_pc = 1;
      end
      OP_FETCH  : mem_rd = op_memrd;
      OP_ALU    : begin
         load_reg = op_memrd | is_not;
         mem_rd   = op_memrd;
         inc_pc   = ((ir_opcode == BRZ) && zero);
         load_pc  = (ir_opcode == BRA);
      end
      UPDATE    : begin
         mem_wr  = (ir_opcode == STA);
      end
      default   : ;
   endcase
end

endmodule
