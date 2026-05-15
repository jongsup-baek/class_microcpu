//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : mem.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module mem (
   input  logic        clk,       // 클럭
   input  logic        read,      // 읽기 활성화
   input  logic        write,     // 쓰기 활성화
   input  logic [7:0]  addr,      // 주소
   input  logic [15:0] data_in,   // 쓰기 데이터
   output logic [15:0] data_out   // 읽기 데이터
);
   // Comment #1 : 동기 메모리 모듈
   logic [15:0] memory [0:255];

   always @(posedge clk) begin
      if (write && !read)
         memory[addr] <= data_in;
   end

   always_ff @(posedge clk) begin
      if (read && !write)
         data_out <= memory[addr];
   end
   // End Comment

endmodule
