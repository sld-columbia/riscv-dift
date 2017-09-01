////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    ALU tag                                                    //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Tag ALU                                                    //
//                 This unit computes the destination tag based on the        //
//                 source tags and on the type of the operation               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_alu_tag
(
  input  logic                      clk,
  input  logic                      rst_n,

  input  logic [ALU_MODE_WIDTH-1:0] operator_i,
  input  logic [31:0]               operand_a_i,
  input  logic [31:0]               operand_b_i,
  input  logic [31:0]               operand_c_i,

  output logic [31:0]               result_o,
  output logic                      rf_enable_tag
);

  always_comb
  begin
    result_o      = 'x;
    rf_enable_tag = '1;

    unique case (operator_i)
      // Standard Operations
      ALU_MODE_OLD:   rf_enable_tag = '0;
      ALU_MODE_AND:   result_o = operand_a_i & operand_b_i;
      ALU_MODE_OR:    result_o = operand_a_i | operand_b_i;
      ALU_MODE_CLEAR: result_o = '0;
      default: ; // default case to suppress unique warning
    endcase
  end

endmodule
