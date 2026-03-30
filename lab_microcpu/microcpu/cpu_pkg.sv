//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : cpu_pkg.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

package cpu_pkg;
  // MicroCPU opcodes (same encoding as SimpleCPU)
  typedef enum logic [2:0] {HALT, BRZ, ADD, AND, SUB, LDA, STA, BRA} opcode_t;

  // Control sequencer states (same as SimpleCPU)
  typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                            OP_ADDR, OP_FETCH, ALU_OP, UPDATE} state_t;

  // Instruction parameters
  parameter INSTR_WIDTH = 16;
  parameter DATA_WIDTH  = 16;

  // Memory parameters
  parameter MEM_DEPTH  = 256;
  parameter MEM_WIDTH  = 16;
  parameter ADDR_WIDTH = 8;

  // Register file parameters
  parameter REG_COUNT = 4;
  parameter REG_SEL   = 2;

endpackage : cpu_pkg
