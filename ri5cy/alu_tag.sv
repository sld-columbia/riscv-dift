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

module riscv_alu
(
  input  logic                      clk,
  input  logic                      rst_n,

  input  logic [ALU_MODE_WIDTH-1:0] operator_i,
  input  logic [31:0]               operand_a_i,
  input  logic [31:0]               operand_b_i,
  input  logic [31:0]               operand_c_i,

  output logic [31:0]               result_o
);

  always_comb
  begin
    result_o   = 'x;

    unique case (operator_i)
      // Standard Operations
      ALU_AND:  result_o = operand_a_i & operand_b_i;
      ALU_OR:   result_o = operand_a_i | operand_b_i;
      ALU_XOR:  result_o = operand_a_i ^ operand_b_i;

      // Shift Operations
      ALU_ADD, ALU_ADDR, ALU_ADDU, ALU_ADDUR,
      ALU_SUB, ALU_SUBR, ALU_SUBU, ALU_SUBUR,
      ALU_SLL,
      ALU_SRL, ALU_SRA,
      ALU_ROR:  result_o = shift_result;

      // bit manipulation instructions
      ALU_BINS,
      ALU_BEXT,
      ALU_BEXTU: result_o = bextins_result;

      ALU_BCLR:  result_o = bclr_result;
      ALU_BSET:  result_o = bset_result;

      // pack and shuffle operations
      ALU_SHUF,  ALU_SHUF2,
      ALU_PCKLO, ALU_PCKHI,
      ALU_EXT,   ALU_EXTS,
      ALU_INS: result_o = pack_result;

      // Min/Max/Abs/Ins
      ALU_MIN, ALU_MINU,
      ALU_MAX, ALU_MAXU,
      ALU_ABS: result_o = result_minmax;

      ALU_CLIP, ALU_CLIPU: result_o = clip_result;

      // Comparison Operations
      ALU_EQ,    ALU_NE,
      ALU_GTU,   ALU_GEU,
      ALU_LTU,   ALU_LEU,
      ALU_GTS,   ALU_GES,
      ALU_LTS,   ALU_LES: begin
          result_o[31:24] = {8{cmp_result[3]}};
          result_o[23:16] = {8{cmp_result[2]}};
          result_o[15: 8] = {8{cmp_result[1]}};
          result_o[ 7: 0] = {8{cmp_result[0]}};
       end
      ALU_SLTS,  ALU_SLTU,
      ALU_SLETS, ALU_SLETU: result_o = {31'b0, comparison_result_o};

      ALU_FF1, ALU_FL1, ALU_CLB, ALU_CNT: result_o = {26'h0, bitop_result[5:0]};

      // Division Unit Commands
      ALU_DIV, ALU_DIVU,
      ALU_REM, ALU_REMU: result_o = result_div;

      default: ; // default case to suppress unique warning
    endcase
  end

  assign ready_o = div_ready;

endmodule
