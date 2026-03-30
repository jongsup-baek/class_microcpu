//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : mem.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Synchronous 256x16 word memory with read/write ports
// Extended from SimpleCPU's 32x8 memory
module mem (
   input  logic        clk,
   input  logic        read,
   input  logic        write,
   input  logic [7:0]  addr,
   input  logic [15:0] data_in,
   output logic [15:0] data_out
);

import cpu_pkg::*;

logic [15:0] memory [0:255];

   always @(posedge clk)
      if (write && !read)
         memory[addr] <= data_in;

   always_ff @(posedge clk iff ((read == '1) && (write == '0)))
      data_out <= memory[addr];

endmodule
