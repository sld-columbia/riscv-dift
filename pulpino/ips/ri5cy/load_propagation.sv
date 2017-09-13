////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    Load propagation                                           //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    This unit reads the MODE and the ENABLE field of the       //
//                 Tag Propagation Register and computes the destination tag. //
//                 This unit is dedicated to the LOAD operation               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_load_propagation
(
  input  logic        regfile_wdata_wb_i_tag,  // M[RS1+offset]: source tag
  input  logic        rs1_i_tag,               // RS1: source address tag
  input  logic        regfile_we_wb_i,         // Register file port a write enable
  input  logic [31:0] tpr_i,

  output logic        regfile_dest_tag,        // RD: destination tag
  output logic        regfile_enable_tag       // Register file port a write enable after reading TPR
);

  logic [ALU_MODE_WIDTH-1:0] alu_operator_mode;
  logic enable_a;
  logic enable_b;
  logic operand_a;
  logic operand_b;

  assign alu_operator_mode = tpr_i[LOADSTORE_HIGH:LOADSTORE_LOW];
  assign enable_a  = tpr_i[LOADSTORE_EN_SOURCE_ADDR];
  assign enable_b  = tpr_i[LOADSTORE_EN_SOURCE];
  assign operand_a = rs1_i_tag & enable_a;
  assign operand_b = regfile_wdata_wb_i_tag & enable_b;

  always_comb
  begin
    regfile_dest_tag     = 1'b0;
    regfile_enable_tag   = 1'b0;
    if (regfile_we_wb_i) begin
      regfile_dest_tag   = 1'b0;
      regfile_enable_tag = 1'b1;

      unique case (alu_operator_mode)
        // Standard Operations
        ALU_MODE_OLD: begin
          regfile_enable_tag = 1'b0;
        end
        ALU_MODE_AND:   regfile_dest_tag = operand_a & operand_b;
        ALU_MODE_OR:    regfile_dest_tag = operand_a | operand_b;
        ALU_MODE_CLEAR: regfile_dest_tag = '0;
        default: ; // default case to suppress unique warning
      endcase
    end
  end

endmodule
