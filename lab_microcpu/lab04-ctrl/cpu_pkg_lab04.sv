package cpu_pkg_lab04;
  typedef enum logic [2:0] {HALT, BRZ, BRA, LDA, STA, ADD, AND, NOT} opcode_t;
  typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                            OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;
endpackage : cpu_pkg_lab04
