//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : mux2to1.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Parameterized 2-to-1 multiplexer
// Used for address mux (WIDTH=8) and operand mux (WIDTH=16)
module mux2to1 #(WIDTH = 8) (
   output logic [WIDTH-1:0] dout,
   input  logic [WIDTH-1:0] din_a,
   input  logic [WIDTH-1:0] din_b,
   input  logic             sel_a
);

   always_comb
   unique case (sel_a)
      1'b1:    dout = din_a;
      1'b0:    dout = din_b;
      default: dout = 'x;
   endcase

endmodule
