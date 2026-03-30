//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : control.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// CPU control sequencer — decodes opcode and generates control signals
// Same 8-state FSM as SimpleCPU, load_ac renamed to load_reg
module control
   import cpu_pkg::*;
(
   output logic    load_reg,
   output logic    mem_rd,
   output logic    mem_wr,
   output logic    inc_pc,
   output logic    load_pc,
   output logic    load_ir,
   output logic    halt,
   input  opcode_t ir_opcode,
   input  logic    zero,
   input  logic    clk,
   input  logic    rst_n
);

state_t state;

logic aluop;

assign aluop = (ir_opcode inside {ADD, AND, SUB, LDA});

always_ff @(posedge clk or negedge rst_n)
   if (!rst_n)
      state <= INST_ADDR;
   else
      state <= state.next();

always_comb begin
   {mem_rd, load_ir, halt, inc_pc, load_reg, load_pc, mem_wr} = 7'b000_0000;
   case (state)
      INST_ADDR : ;
      INST_FETCH: mem_rd = 1;
      INST_LOAD : begin
         mem_rd  = 1;
         load_ir = 1;
      end
      IDLE      : begin
         mem_rd  = 1;
         load_ir = 1;
      end
      OP_ADDR   : begin
         inc_pc = 1;
         halt   = (ir_opcode == HALT);
      end
      OP_FETCH  : mem_rd = aluop;
      ALU_OP    : begin
         load_reg = aluop;
         mem_rd   = aluop;
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
