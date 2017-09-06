////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    Enable tag                                                 //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Enable decoder                                             //
//                 This unit reads the ENABLE field of the Tag Propagation    //
//                 Register and sends the proper signals to the EX stage      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_enable_tag
(
  // from IF/ID pipeline
  input  logic [31:0] instr_rdata_i,           // instruction read from instr memory/cache

  // from CSRs
  input  logic [31:0] tpr_i,

  // enable signals
  output logic        is_store_o,
  output logic        enable_a_o,
  output logic        enable_b_o
);

  always_comb
  begin
    enable_a_o = 1'b1;
    enable_b_o = 1'b1;
    is_store_o = 1'b0;

    unique case (instr_rdata_i[6:0])

      OPCODE_STORE,
      //OPCODE_STORE_POST,
      : begin
        enable_a_o  = tpr_i[LOADSTORE_EN_DEST_ADDR];
        enable_b_o  = tpr_i[LOADSTORE_EN_SOURCE];
        is_store_o = 1'b1;
      end

      OPCODE_LOAD
      //OPCODE_LOAD_POST,
      : begin
      end

      default: begin
        enable_a_o = 1'b1;
        enable_b_o = 1'b1;
        is_store_o = 1'b0;
      end
    endcase
  end

endmodule
