// Students: Implement your cpu_core here
// See microcpu/cpu_core.sv for reference
// This module integrates: IR, register_file, PC, operand_mux, ALU, addr_mux, control

module cpu_core (
   output logic        halt,
   output logic        ir_load,
   output logic [7:0]  addr,
   output logic [15:0] alu_out,
   output logic        mem_rd,
   output logic        mem_wr,
   input  logic [15:0] data_out,
   input  logic        clk_core,
   input  logic        clk_cntrl,
   input  logic        clk_alu,
   input  logic        sel_fetch_pc,
   input  logic        rst_n
);

import cpu_pkg::*;

   // TODO: Declare IR output and decoded fields
   // TODO: Declare register file signals (rd_data, rs_data)
   // TODO: Declare PC signals (pc_addr)
   // TODO: Declare ALU signals (alu_operand, alu_zero)
   // TODO: Declare control signals (load_reg, pc_inc, pc_load)

   // TODO: Instantiate register_core (IR)
   // TODO: Decode IR fields
   // TODO: Instantiate register_file
   // TODO: Instantiate counter_prog (PC)
   // TODO: Instantiate addr_mux #(16) operand MUX
   // TODO: Instantiate alu
   // TODO: Instantiate addr_mux #(8) address MUX
   // TODO: Instantiate control

endmodule : cpu_core
