//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : sysclk.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module sysclk (
   input  logic clk_ext,   // 외부 클럭
   input  logic halt,      // 정지 신호
   output logic clk_sys,   // 시스템 클럭 (2분주)
   input  logic rst_n      // 비동기 리셋
);
   // Comment #1 : sysclk 모듈
   wire clk_i = clk_ext & ~halt;
   logic div;

   always_ff @(posedge clk_i or negedge rst_n) begin
      if (!rst_n)
         div <= 1'b0;
      else
         div <= ~div;
   end

   assign clk_sys = div;
   // End Comment

endmodule
