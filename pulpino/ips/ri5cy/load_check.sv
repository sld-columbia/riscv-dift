////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    Load check                                                 //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    This unit raises an exception if a check is enabled in     //
//                 the Tag Check Register and the tag bit of the              //
//                 corresponding operand is set.                              //
//                 This unit is dedicated to the LOAD operation               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_load_check
(
  input  logic        regfile_wdata_wb_i_tag,  // M[RS1+offset]: source tag
  input  logic        rs1_i_tag,               // RS1: source address tag
  input  logic        regfile_dest_tag,        // RD: destination tag
  input  logic [31:0] tcr_i,
  input  logic        regfile_we_wb_i,

  output logic        exception_o
);

  logic  check_s;
  logic  check_sa;
  logic  check_d;

  assign check_s  = tcr_i[LOADSTORE_CHECK_S];
  assign check_sa = tcr_i[LOADSTORE_CHECK_SA];
  assign check_d  = tcr_i[LOADSTORE_CHECK_D];

  always_comb
  begin
    exception_o     = 1'b0;
    if (regfile_we_wb_i) begin
      if ((regfile_wdata_wb_i_tag & check_s) || (rs1_i_tag & check_sa) || (regfile_dest_tag & check_d)) begin
        exception_o = 1'b1;
      end else begin
        exception_o = 1'b0;
      end
    end
  end

endmodule
