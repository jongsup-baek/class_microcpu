//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : cpu_core.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// CPU datapath — single clock, all blocks use clk_sys
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

// IR decoded fields
opcode_t     ir_opcode;
logic        ir_mode;
logic [1:0]  ir_rd, ir_rs;
logic [7:0]  ir_data;

// Register file signals
logic [15:0] rd_data, rs_data;

// PC signals
logic [7:0]  pc_addr;

// ALU signals
logic [15:0] alu_operand;
logic        alu_zero;

// Control signals
logic load_reg, pc_inc, pc_load, fetch_phase;

// IR — 16-bit instruction register + field decode
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

// Register file
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

// PC — 8-bit program counter
prog_counter u_pc (
   .pc_count (pc_addr),
   .din      (ir_data),
   .clk      (clk_sys),
   .load     (pc_load),
   .enable   (pc_inc),
   .rst_n
);

// Operand MUX — selects ALU second input based on mode bit
// mode=0: memory data, mode=1: register Rs
mux2to1 #(16) u_opmux (
   .dout  (alu_operand),
   .din_a (data_out),
   .din_b (rs_data),
   .sel_a (~ir_mode)
);

// ALU — 16-bit combinational
alu u_alu (
   .dout   (alu_out),
   .zero   (alu_zero),
   .accum  (rd_data),
   .din    (alu_operand),
   .opcode (ir_opcode)
);

// Address MUX — selects between PC (fetch) and IR data (operand)
mux2to1 #(8) u_addrmux (
   .dout  (addr),
   .din_a (pc_addr),
   .din_b (ir_data),
   .sel_a (fetch_phase)
);

// Control FSM — single clock
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

endmodule : cpu_core
