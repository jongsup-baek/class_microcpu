//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab09_demo.f
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Design sources
../../../design/cpu_pkg.sv
../../../design/regfile.sv
../../../design/instr_reg.sv
../../../design/prog_counter.sv
../../../design/alu.sv
../../../design/mux2to1.sv
../../../design/control.sv
../../../design/sysclk.sv
../../../design/mem.sv

// Lab files
../cpu_core.sv
../tb_cpu_core.sv

// Simulation Options
+access+rwc
-timescale 1ns/100ps
