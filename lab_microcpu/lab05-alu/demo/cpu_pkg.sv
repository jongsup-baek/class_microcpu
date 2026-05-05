//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : cpu_pkg.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

package cpu_pkg;
   typedef enum logic [2:0] {WFR, BRZ, BRA, LDA, STA, ADD, AND, NOT} opcode_t;
   typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                             OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;
endpackage : cpu_pkg
