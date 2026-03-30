// Package
../cpu_pkg.sv
../tb_pkg.sv

// DUT sources
../sv_src/register_file.sv
../sv_src/register_core.sv
../sv_src/counter_prog.sv
../sv_src/alu.sv
../sv_src/addr_mux.sv
../sv_src/control.sv
../sv_src/sys_clk.sv
../mem.sv
../cpu_core.sv

// Infrastructure
../cpu_intf.sv
../cpu_top.sv

// Testbench
../tb_cpu_top.sv

// Test program
+TESTPROG=../program_code/MCPUtest1.dat
+EXPECT_PC=16

// Simulation Options
+access+rwc
-timescale 1ns/100ps
