// Students: Implement your register_file here
// See microcpu/sv_src/register_file.sv for reference

module register_file (
   output logic [15:0] rd_data,
   output logic [15:0] rs_data,
   input  logic [1:0]  rd_addr,
   input  logic [1:0]  rs_addr,
   input  logic [15:0] wr_data,
   input  logic [1:0]  wr_addr,
   input  logic        wr_en,
   input  logic        clk,
   input  logic        rst_n
);

   // TODO: Declare 4x16-bit register array

   // TODO: Synchronous write with async reset

   // TODO: Combinational read for both ports

endmodule
