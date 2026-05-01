// Package
../cpu_pkg.sv
../tb_pkg.sv

// DUT sources
../sv_src/regfile.sv
../sv_src/instr_reg.sv
../sv_src/prog_counter.sv
../sv_src/alu.sv
../sv_src/mux2to1.sv
../sv_src/control.sv
../sv_src/sysclk.sv
../mem.sv
../cpu_core.sv

// Infrastructure
../cpu_intf.sv
../cpu_top.sv

// Testbench
../tb_cpu_top.sv

// Test program
+TESTPROG=../program_code/MCPUtest3.dat
+EXPECT_PC=17

// Simulation Options
+access+rwc
-timescale 1ns/100ps
