//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_instr_reg_blank.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//
// execution command
//    $> cd sim
//    $> xrun -f lab06_blank.f -input ../../shm.tcl
//////////////////////////////////////////////////////////

module tb;
   bit clk = 0; initial forever #50 clk = ~clk;

   import cpu_pkg::*;

   logic [15:0] din;
   logic        enable, rst_n;
   opcode_t     ir_opcode;
   logic        ir_mode;
   logic [1:0]  ir_rd, ir_rs;
   logic [7:0]  ir_data;

   instr_reg u_ir (
      .ir_opcode (ir_opcode),
      .ir_mode   (ir_mode),
      .ir_rd     (ir_rd),
      .ir_rs     (ir_rs),
      .ir_data   (ir_data),
      .din       (din),
      .clk       (clk),
      .enable    (enable),
      .rst_n     (rst_n)
   );

   task reset_dut();
      #10;
         rst_n  = 0;
         enable = 0;
         din    = 16'h0000;
      @(posedge clk);
      @(posedge clk);
         rst_n = 1;
      @(posedge clk);
   endtask

   // Comment #1 : load_ir task







   // End Comment

   initial begin
      reset_dut();

      // Comment #2 : IR 로드 + 필드 디코드 검증











      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab06_instr_reg");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  enable  din    ir_opcode  ir_mode  ir_rd  ir_rs  ir_data
   //  ----  ------  -----  ---------  -------  -----  -----  -------
   //     0      0   0000   WFR             0      0      0       00
   //   100      0   0000   WFR             0      0      0       00
   //   200      1   A655   WFR             0      0      0       00    #2
   //   300      0   A655   ADD             0      1      2       55
   //   400      1   7CAB   ADD             0      1      2       55
   //   500      0   7CAB   LDA             1      3      0       AB
   //   600      1   0000   LDA             1      3      0       AB
   //   700      0   0000   WFR             0      0      0       00
   //////////////////////////////////////////////////////////
endmodule
