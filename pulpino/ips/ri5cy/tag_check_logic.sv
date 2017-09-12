////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    Tag Check Logic                                            //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    This unit raises an exception if a check is enabled in     //
//                 the Tag Check Register and the tag bit of the              //
//                 corresponding operand is set                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_tag_check_logic
(
  input  logic  operand_a_i,
  input  logic  operand_b_i,
  input  logic  result_i,
  input  logic  check_s1_i,
  input  logic  check_s2_i,
  input  logic  check_d_i,
  input  logic  is_load_i,

  output logic  exception_o
);

  always_comb
  begin
    if (~is_load_i) begin
      if ((operand_a_i & check_s1_i) || (operand_b_i & check_s2_i) || (result_i & check_d_i)) begin
        exception_o = 1'b1;
      end else begin
        exception_o = 1'b0;
      end
    end else begin
      exception_o   = 1'b0;
    end
  end

endmodule
