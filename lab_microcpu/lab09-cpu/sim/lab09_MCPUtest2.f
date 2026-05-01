// Package
../../microcpu/cpu_pkg.sv
../../microcpu/tb_pkg.sv

// DUT sources
../../microcpu/sv_src/regfile.sv
../../microcpu/sv_src/instr_reg.sv
../../microcpu/sv_src/prog_counter.sv
../../microcpu/sv_src/alu.sv
../../microcpu/sv_src/mux2to1.sv
../../microcpu/sv_src/control.sv
../../microcpu/sv_src/sysclk.sv
../../microcpu/mem.sv
../../microcpu/cpu_core.sv

// Infrastructure
../../microcpu/cpu_intf.sv
../../microcpu/cpu_top.sv

// Testbench
../../microcpu/tb_cpu_top.sv

// Test program
+TESTPROG=../../microcpu/program_code/MCPUtest2.dat
+EXPECT_PC=25

// Simulation Options
+access+rwc
-timescale 1ns/100ps
