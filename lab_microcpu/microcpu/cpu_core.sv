//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : cpu_core.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// CPU datapath — connects register file, counter, ALU, muxes, control
// Extended from SimpleCPU: register_file replaces AC, operand_mux added
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

// IR output and decoded fields
logic [15:0] ir_out;
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
logic load_reg, pc_inc, pc_load;

// IR — 16-bit instruction register
register_core ir (
   .dout   (ir_out),
   .din    (data_out),
   .clk    (clk_core),
   .enable (ir_load),
   .rst_n  (rst_n)
);

// IR field decoding
assign ir_opcode = opcode_t'(ir_out[15:13]);
assign ir_mode   = ir_out[12];
assign ir_rd     = ir_out[11:10];
assign ir_rs     = ir_out[9:8];
assign ir_data   = ir_out[7:0];

// Register file — replaces single accumulator
register_file regfile (
   .rd_data (rd_data),
   .rs_data (rs_data),
   .rd_addr (ir_rd),
   .rs_addr (ir_rs),
   .wr_data (alu_out),
   .wr_addr (ir_rd),
   .wr_en   (load_reg),
   .clk     (clk_core),
   .rst_n   (rst_n)
);

// PC — 8-bit program counter
counter_prog pc (
   .pc_count (pc_addr),
   .din      (ir_data),
   .clk      (clk_core),
   .load     (pc_load),
   .enable   (pc_inc),
   .rst_n    (rst_n)
);

// Operand MUX — selects ALU second input based on mode bit
// mode=0: memory data, mode=1: register Rs
addr_mux #(16) op_mux (
   .dout  (alu_operand),
   .din_a (data_out),
   .din_b (rs_data),
   .sel_a (~ir_mode)
);

// ALU — 16-bit arithmetic/logic unit
alu alu1 (
   .dout   (alu_out),
   .zero   (alu_zero),
   .clk    (clk_alu),
   .accum  (rd_data),
   .din    (alu_operand),
   .opcode (ir_opcode)
);

// Address MUX — selects between PC (fetch) and IR data (operand)
addr_mux #(8) smx (
   .dout  (addr),
   .din_a (pc_addr),
   .din_b (ir_data),
   .sel_a (sel_fetch_pc)
);

// Control FSM
control cntl (
   .load_reg (load_reg),
   .mem_rd,
   .mem_wr,
   .inc_pc   (pc_inc),
   .load_pc  (pc_load),
   .load_ir  (ir_load),
   .halt,
   .ir_opcode,
   .zero     (alu_zero),
   .clk      (clk_cntrl),
   .rst_n    (rst_n)
);

endmodule : cpu_core
