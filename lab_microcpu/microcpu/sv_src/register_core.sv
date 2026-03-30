//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : register_core.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// 16-bit instruction register with synchronous load and async reset
// Used for IR only (AC replaced by register_file)
module register_core (
   output logic [15:0] dout,
   input  logic [15:0] din,
   input  logic        clk,
   input  logic        enable,
   input  logic        rst_n
);

   always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
         dout <= '0;
      else if (enable)
         dout <= din;

endmodule
