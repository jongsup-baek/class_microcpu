//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 설계 실무
// File  : lab10_demo.f
// Date  : 2026-05-05
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Shared RTL sources
../../../microcpu/cpu_pkg.sv
../../../microcpu/sv_src/regfile.sv
../../../microcpu/sv_src/instr_reg.sv
../../../microcpu/sv_src/prog_counter.sv
../../../microcpu/sv_src/alu.sv
../../../microcpu/sv_src/mux2to1.sv
../../../microcpu/sv_src/control.sv
../../../microcpu/sv_src/sysclk.sv
../../../microcpu/sv_src/mem.sv
../../../microcpu/cpu_core.sv

// Lab files
../cpu_top.sv
../tb_cpu_top.sv

// Simulation Options
+access+rwc
-timescale 1ns/100ps
