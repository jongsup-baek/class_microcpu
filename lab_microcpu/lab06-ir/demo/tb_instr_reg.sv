//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : tb_instr_reg.sv
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
   logic [7:0]  ir_addr;

   instr_reg u_ir (
      .ir_opcode (ir_opcode),
      .ir_mode   (ir_mode),
      .ir_rd     (ir_rd),
      .ir_rs     (ir_rs),
      .ir_addr   (ir_addr),
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
   task load_ir(input logic [15:0] instr);
         enable = 1;
         din    = instr;
      @(posedge clk);
         enable = 0;
      @(posedge clk);
   endtask
   // End Comment

   initial begin
      reset_dut();

      // Comment #2 : IR 로드 + 필드 디코드 검증
      // ADD mode=0, Rd=1, Rs=2, data=0x55
      // {ADD[2:0], mode, rd[1:0], rs[1:0], data[7:0]} = {101, 0, 01, 10, 01010101}
      load_ir(16'b101_0_01_10_01010101);

      // LDA mode=1, Rd=3, Rs=0, data=0xAB
      // {LDA[2:0], mode, rd[1:0], rs[1:0], data[7:0]} = {011, 1, 11, 00, 10101011}
      load_ir(16'b011_1_11_00_10101011);

      // WFR (halt)
      // {WFR[2:0], mode, rd[1:0], rs[1:0], data[7:0]} = {000, 0, 00, 00, 00000000}
      load_ir(16'b000_0_00_00_00000000);
      // End Comment

      @(posedge clk);
      $display("SIM DONE: lab06_instr_reg");
      $finish;
   end

   //////////////////////////////////////////////////////////
   // Expected Waveform (SimVision)
   //////////////////////////////////////////////////////////
   //  time  enable  din    ir_opcode  ir_mode  ir_rd  ir_rs  ir_addr
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
