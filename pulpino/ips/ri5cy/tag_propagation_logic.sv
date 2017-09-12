////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    Tag Propagation Logic                                      //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    This unit computes the destination operand tag based on    //
//                 the source operands tags and on the type of the operation  //
//                 specified in the Tag Propagation Register                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_tag_propagation_logic
(
  input  logic [ALU_MODE_WIDTH-1:0] operator_i,
  input  logic                      operand_a_i,
  input  logic                      operand_b_i,

  output logic                      result_o,
  output logic                      rf_enable_tag,
  output logic                      pc_enable_tag
);

  always_comb
  begin
    result_o      = 1'b0;
    rf_enable_tag = 1'b1;
    pc_enable_tag = 1'b1;

    unique case (operator_i)
      // Standard Operations
      ALU_MODE_OLD: begin
        rf_enable_tag = 1'b0;
        pc_enable_tag = 1'b0;
      end
      ALU_MODE_AND:   result_o = operand_a_i & operand_b_i;
      ALU_MODE_OR:    result_o = operand_a_i | operand_b_i;
      ALU_MODE_CLEAR: result_o = 1'b0;
      default: ; // default case to suppress unique warning
    endcase
  end

endmodule
