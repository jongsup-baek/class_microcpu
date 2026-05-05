//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : cpu_top.sv
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

module cpu_top (
   input  logic clk_ext,   // 외부 클럭
   input  logic rst_n,     // 비동기 리셋
   output logic halt,      // 정지 출력
   output logic ir_load    // IR 로드 (디버그용)
);

import cpu_pkg::*;

logic clk_sys;
logic [7:0]  addr;
logic [15:0] alu_out, data_out;
logic        mem_rd, mem_wr;

// Comment #1 : cpu_top 인스턴스 연결
sysclk u_sysclk (
   .clk_ext,
   .halt,
   .clk_sys,
   .rst_n
);

cpu_core u_cpu_core (
   .halt,
   .ir_load,
   .addr     (addr),
   .alu_out  (alu_out),
   .mem_rd   (mem_rd),
   .mem_wr   (mem_wr),
   .data_out (data_out),
   .clk_sys  (clk_sys),
   .rst_n
);

mem u_mem (
   .clk      (clk_sys),
   .read     (mem_rd),
   .write    (mem_wr),
   .addr     (addr),
   .data_in  (alu_out),
   .data_out (data_out)
);
// End Comment

endmodule : cpu_top
