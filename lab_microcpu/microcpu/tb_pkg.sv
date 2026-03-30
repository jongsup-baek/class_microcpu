//////////////////////////////////////////////////////////
// KSDC Proprietary
// Course: MicroCPU 실습
// File  : tb_pkg.sv
// Date  : 2026-03-31
// Author: Jongsup Baek <jongsup.baek@ksdcsemi.com>
//////////////////////////////////////////////////////////

// Common testbench utilities for MicroCPU labs
package tb_pkg;

   parameter PERIOD = 10;

   task automatic check_result(
      input string test_name,
      ref logic clk,
      ref logic [15:0] actual,
      input logic [15:0] expected
   );
      @(negedge clk);
      if (actual !== expected) begin
         $display("[FAIL] %s: actual=%h, expected=%h", test_name, actual, expected);
         $display("%s TEST FAILED", test_name);
         $finish;
      end
   endtask

   task automatic check_result_1bit(
      input string test_name,
      ref logic clk,
      ref logic actual,
      input logic expected
   );
      @(negedge clk);
      if (actual !== expected) begin
         $display("[FAIL] %s: actual=%b, expected=%b", test_name, actual, expected);
         $display("%s TEST FAILED", test_name);
         $finish;
      end
   endtask

   task automatic check_result_8bit(
      input string test_name,
      ref logic clk,
      ref logic [7:0] actual,
      input logic [7:0] expected
   );
      @(negedge clk);
      if (actual !== expected) begin
         $display("[FAIL] %s: actual=%h, expected=%h", test_name, actual, expected);
         $display("%s TEST FAILED", test_name);
         $finish;
      end
   endtask

   function void print_pass(input string test_name);
      $display("%s TEST PASSED", test_name);
   endfunction

   function void print_fail(input string test_name, input string msg);
      $display("[FAIL] %s: %s", test_name, msg);
      $display("%s TEST FAILED", test_name);
      $finish;
   endfunction

endpackage
