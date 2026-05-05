//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : mux2to1.sv
// Date  : 2026-05-01
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Parameterized 2-to-1 multiplexer
module mux2to1 #(WIDTH = 8) (
   output logic [WIDTH-1:0] dout,
   input  logic [WIDTH-1:0] din_a,
   input  logic [WIDTH-1:0] din_b,
   input  logic             sel_a
);

assign dout = sel_a ? din_a : din_b;

endmodule
