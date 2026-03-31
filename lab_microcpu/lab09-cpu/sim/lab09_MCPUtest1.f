// Package
../../microcpu/cpu_pkg.sv
../../microcpu/tb_pkg.sv

// DUT sources
../../microcpu/sv_src/register_file.sv
../../microcpu/sv_src/register_core.sv
../../microcpu/sv_src/counter_prog.sv
../../microcpu/sv_src/alu.sv
../../microcpu/sv_src/addr_mux.sv
../../microcpu/sv_src/control.sv
../../microcpu/sv_src/sys_clk.sv
../../microcpu/mem.sv
../../microcpu/cpu_core.sv

// Infrastructure
../../microcpu/cpu_intf.sv
../../microcpu/cpu_top.sv

// Testbench
../../microcpu/tb_cpu_top.sv

// Test program
+TESTPROG=../../microcpu/program_code/MCPUtest1.dat
+EXPECT_PC=16

// Simulation Options
+access+rwc
-timescale 1ns/100ps
