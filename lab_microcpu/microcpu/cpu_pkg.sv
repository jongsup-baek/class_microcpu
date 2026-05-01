//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : cpu_pkg.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

package cpu_pkg;
  // MicroCPU opcodes — grouped by function
  // Control(000), Branch(001-010), Data Move(011-100), ALU(101-111)
  typedef enum logic [2:0] {HALT, BRZ, BRA, LDA, STA, ADD, AND, NOT} opcode_t;

  // Control sequencer states
  typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                            OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;

endpackage : cpu_pkg
