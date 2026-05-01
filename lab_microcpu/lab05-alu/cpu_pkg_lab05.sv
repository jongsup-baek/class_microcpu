package cpu_pkg_lab05;
  typedef enum logic [2:0] {HALT, BRZ, ADD, AND, SUB, LDA, STA, BRA} opcode_t;
  typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                            OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;
endpackage : cpu_pkg_lab05
