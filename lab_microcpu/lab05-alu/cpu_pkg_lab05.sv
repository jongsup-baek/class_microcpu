package cpu_pkg_lab05;
  typedef enum logic [2:0] {HALT, BRZ, ADD, AND, SUB, LDA, STA, BRA} opcode_t;
  typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                            OP_ADDR, OP_FETCH, ALU_OP, UPDATE} state_t;
  parameter INSTR_WIDTH = 16;
  parameter DATA_WIDTH  = 16;
  parameter MEM_DEPTH  = 256;
  parameter MEM_WIDTH  = 16;
  parameter ADDR_WIDTH = 8;
  parameter REG_COUNT = 4;
  parameter REG_SEL   = 2;
endpackage : cpu_pkg_lab05
