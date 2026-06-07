//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab06_demo.f
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Lab files (cpu_pkg는 lab02에서 작성한 자산을 참조)
../../lab02-alu/cpu_pkg.sv
../instr_reg.sv
../tb_instr_reg.sv

// Simulation Options
+access+rwc
-timescale 1ns/100ps
