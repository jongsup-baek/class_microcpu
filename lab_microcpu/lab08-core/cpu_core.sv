// Students: Implement your cpu_core here
// See microcpu/cpu_core.sv for reference
// This module integrates: IR, regfile, PC, mux2to1 (op_mux, addr_mux), ALU, control

module cpu_core (
   output logic        halt,
   output logic        ir_load,
   output logic [7:0]  addr,
   output logic [15:0] alu_out,
   output logic        mem_rd,
   output logic        mem_wr,
   input  logic [15:0] data_out,
   input  logic        clk_sys,
   input  logic        rst_n
);

import cpu_pkg::*;

   // TODO: Declare IR output and decoded fields
   // TODO: Declare register file signals (rd_data, rs_data)
   // TODO: Declare PC signals (pc_addr)
   // TODO: Declare ALU signals (alu_operand, alu_zero)
   // TODO: Declare control signals (load_reg, pc_inc, pc_load, fetch_phase)

   // TODO: Instantiate instr_reg (IR)
   // TODO: Decode IR fields
   // TODO: Instantiate regfile
   // TODO: Instantiate prog_counter (PC)
   // TODO: Instantiate mux2to1 #(16) u_op_mux (operand MUX)
   // TODO: Instantiate alu (combinational — no clk port)
   // TODO: Instantiate mux2to1 #(8) u_addr_mux (address MUX)
   // TODO: Instantiate control (outputs fetch_phase)

endmodule : cpu_core
