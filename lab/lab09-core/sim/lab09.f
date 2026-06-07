//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab09.f
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Design sources
../../../lab00-design/cpu_pkg.sv
../../../lab00-design/regfile.sv
../../../lab00-design/instr_reg.sv
../../../lab00-design/prog_counter.sv
../../../lab00-design/alu.sv
../../../lab00-design/mux2to1.sv
../../../lab00-design/control.sv
../../../lab00-design/sysclk.sv
../../../lab00-design/mem.sv

// Lab files
../cpu_core.sv
../cpu_top.sv
../tb_cpu_core.sv

// Simulation Options
+access+rwc
-timescale 1ns/100ps
