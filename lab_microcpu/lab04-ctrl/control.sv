// Students: Implement your control FSM here
// See microcpu/sv_src/control.sv for reference

module control
   import cpu_pkg_lab04::*;
(
   output logic    load_reg,
   output logic    mem_rd,
   output logic    mem_wr,
   output logic    inc_pc,
   output logic    load_pc,
   output logic    load_ir,
   output logic    halt,
   input  opcode_t ir_opcode,
   input  logic    zero,
   input  logic    clk,
   input  logic    rst_n
);

   // TODO: Declare state register (state_t)
   // TODO: Declare aluop logic

   // TODO: State transition (posedge clk, negedge rst_n)
   //       state <= state.next()

   // TODO: Output logic (Mealy FSM)
   //       8 states x opcode-dependent outputs

endmodule
