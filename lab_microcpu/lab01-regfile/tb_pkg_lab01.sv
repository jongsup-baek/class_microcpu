package tb_pkg_lab01;

   parameter PERIOD = 10;

   task automatic check_result_16bit(
      input string test_name,
      ref logic clk,
      ref logic [15:0] actual,
      input logic [15:0] expected
   );
      @(negedge clk);
      if (actual === expected)
         print_pass(test_name);
      else
         print_fail(test_name,
            $sformatf("expected=%04h, actual=%04h", expected, actual));
   endtask

   function void print_pass(input string test_name);
      $display("  [PASS] %s", test_name);
   endfunction

   function void print_fail(input string test_name, input string msg);
      $display("  [FAIL] %s : %s", test_name, msg);
      $finish;
   endfunction

endpackage : tb_pkg_lab01
