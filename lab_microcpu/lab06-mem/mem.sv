// Students: Implement your memory here
// See microcpu/mem.sv for reference

module mem (
   input  logic        clk,
   input  logic        read,
   input  logic        write,
   input  logic [7:0]  addr,
   input  logic [15:0] data_in,
   output logic [15:0] data_out
);

import cpu_pkg::*;

   // TODO: Declare 256x16 memory array

   // TODO: Synchronous write (posedge clk, write && !read)

   // TODO: Synchronous read (posedge clk iff read && !write)

endmodule
