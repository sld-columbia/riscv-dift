// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Renzo Andri - andrire@student.ethz.ch                      //
//                                                                            //
// Additional contributions by:                                               //
//                 Igor Loi - igor.loi@unibo.it                               //
//                 Sven Stucki - svstucki@student.ethz.ch                     //
//                 Andreas Traber - atraber@iis.ee.ethz.ch                    //
//                                                                            //
// Design Name:    Excecute stage                                             //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Execution stage: Hosts ALU and MAC unit                    //
//                 ALU: computes additions/subtractions/comparisons           //
//                 MAC:                                                       //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_ex_stage
(
  input  logic        clk,
  input  logic        rst_n,

  // ALU signals from ID stage
  input  logic [ALU_OP_WIDTH-1:0] alu_operator_i,
  input  logic [31:0] alu_operand_a_i,
  input  logic [31:0] alu_operand_b_i,
  input  logic [31:0] alu_operand_c_i,
  input  logic [ 4:0] bmask_a_i,
  input  logic [ 4:0] bmask_b_i,
  input  logic [ 1:0] imm_vec_ext_i,
  input  logic [ 1:0] alu_vec_mode_i,

  // Multiplier signals
  input  logic [ 2:0] mult_operator_i,
  input  logic [31:0] mult_operand_a_i,
  input  logic [31:0] mult_operand_b_i,
  input  logic [31:0] mult_operand_c_i,
  input  logic        mult_en_i,
  input  logic        mult_sel_subword_i,
  input  logic [ 1:0] mult_signed_mode_i,
  input  logic [ 4:0] mult_imm_i,

  input  logic [31:0] mult_dot_op_a_i,
  input  logic [31:0] mult_dot_op_b_i,
  input  logic [31:0] mult_dot_op_c_i,
  input  logic [ 1:0] mult_dot_signed_i,

  output logic        mult_multicycle_o,

  // input from ID stage
  input  logic        branch_in_ex_i,
  input  logic [4:0]  regfile_alu_waddr_i,
  input  logic        regfile_alu_we_i,

  // directly passed through to WB stage, not used in EX
  input  logic        regfile_we_i,
  input  logic [4:0]  regfile_waddr_i,

  // CSR access
  input  logic        csr_access_i,
  input  logic [31:0] csr_rdata_i,

  // Output of EX stage pipeline
  output logic [4:0]  regfile_waddr_wb_o,
  output logic        regfile_we_wb_o,

  // Forwarding ports : to ID stage
  output logic  [4:0] regfile_alu_waddr_fw_o,
  output logic        regfile_alu_we_fw_o,
  output logic [31:0] regfile_alu_wdata_fw_o,    // forward to RF and ID/EX pipe, ALU & MUL

  // To IF: Jump and branch target and decision
  output logic [31:0] jump_target_o,
  output logic        branch_decision_o,

  // Stall Control
  input  logic        lsu_ready_ex_i, // EX part of LSU is done

  output logic        ex_ready_o, // EX stage ready for new data
  output logic        ex_valid_o, // EX stage gets new data
  input  logic        wb_ready_i  // WB stage ready for new data

`ifdef DIFT
  ,
  input  logic [ALU_MODE_WIDTH-1:0] alu_operator_i_mode,
  input  logic        alu_operand_a_i_tag,
  input  logic        alu_operand_b_i_tag,
  input  logic        alu_operand_c_i_tag,
  output logic        regfile_alu_wdata_fw_o_tag,
  output logic        regfile_alu_we_fw_o_tag,
  output logic        jump_target_o_tag,
  output logic        pc_enable_o_tag
`endif
);

  logic [31:0] alu_result;
  logic [31:0] alu_csr_result;
  logic [31:0] mult_result;
  logic        alu_cmp_result;

  logic        alu_ready;
  logic        mult_ready;

`ifdef DIFT
  logic        alu_result_tag;
  logic        rf_enable_tag;
  logic        pc_enable_tag;
`endif

  // EX stage result mux (ALU, MAC unit, CSR)
  assign alu_csr_result         = csr_access_i ? csr_rdata_i : alu_result;

  assign regfile_alu_wdata_fw_o = mult_en_i ? mult_result : alu_csr_result;

  assign regfile_alu_we_fw_o    = regfile_alu_we_i;
  assign regfile_alu_waddr_fw_o = regfile_alu_waddr_i;

  // branch handling
  assign branch_decision_o = alu_cmp_result;
  assign jump_target_o     = alu_operand_c_i;

`ifdef DIFT
  assign regfile_alu_wdata_fw_o_tag = alu_result_tag;
  assign regfile_alu_we_fw_o_tag    = rf_enable_tag;
  
  // if (branch is not taken)
  //   old PC tag is not updated; 
  // else
  //   if (old PC tag is equal to 1)
  //     new PC tag is equal to 1; 
  //   else
  //     new PC tag is the result of the policy applied on the source operands;
  assign jump_target_o_tag          = alu_operand_c_i_tag | alu_result_tag;
  assign pc_enable_o_tag            = pc_enable_tag;
`endif


  ////////////////////////////
  //     _    _    _   _    //
  //    / \  | |  | | | |   //
  //   / _ \ | |  | | | |   //
  //  / ___ \| |__| |_| |   //
  // /_/   \_\_____\___/    //
  //                        //
  ////////////////////////////

  riscv_alu alu_i
  (
    .clk                 ( clk             ),
    .rst_n               ( rst_n           ),

    .operator_i          ( alu_operator_i  ),
    .operand_a_i         ( alu_operand_a_i ),
    .operand_b_i         ( alu_operand_b_i ),
    .operand_c_i         ( alu_operand_c_i ),

    .vector_mode_i       ( alu_vec_mode_i  ),
    .bmask_a_i           ( bmask_a_i       ),
    .bmask_b_i           ( bmask_b_i       ),
    .imm_vec_ext_i       ( imm_vec_ext_i   ),

    .result_o            ( alu_result      ),
    .comparison_result_o ( alu_cmp_result  ),

    .ready_o             ( alu_ready       ),
    .ex_ready_i          ( ex_ready_o      )
  );

  ///////////////////////////////////////////////////
  //  _____  _    ____ ____       _    _    _   _  //
  // |_   _|/ \  / ___/ ___|     / \  | |  | | | | //
  //   | | / _ \| |  _\___ \    / _ \ | |  | | | | //
  //   | |/ ___ \ |_| |___) |  / ___ \| |__| |_| | //
  //   |_/_/   \_\____|____/  /_/   \_\_____\___/  //
  //                                               //
  ///////////////////////////////////////////////////
`ifdef DIFT
  riscv_alu_tag alu_tag_i
  (
    .clk                  ( clk                     ),
    .rst_n,               ( rst_n                   ),
    .operator_i,          ( alu_operator_i_mode     ),
    .operand_a_i,         ( alu_operand_a_i_tag     ),
    .operand_b_i,         ( alu_operand_b_i_tag     ),
    .result_o,            ( alu_result_tag          ),
    .rf_enable_tag        ( rf_enable_tag           ),
    .pc_enable_tag        ( pc_enable_tag           )
  );
`endif

  ////////////////////////////////////////////////////////////////
  //  __  __ _   _ _   _____ ___ ____  _     ___ _____ ____     //
  // |  \/  | | | | | |_   _|_ _|  _ \| |   |_ _| ____|  _ \    //
  // | |\/| | | | | |   | |  | || |_) | |    | ||  _| | |_) |   //
  // | |  | | |_| | |___| |  | ||  __/| |___ | || |___|  _ <    //
  // |_|  |_|\___/|_____|_| |___|_|   |_____|___|_____|_| \_\   //
  //                                                            //
  ////////////////////////////////////////////////////////////////

  riscv_mult mult_i
  (
    .clk             ( clk                  ),
    .rst_n           ( rst_n                ),

    .enable_i        ( mult_en_i            ),
    .operator_i      ( mult_operator_i      ),

    .short_subword_i ( mult_sel_subword_i   ),
    .short_signed_i  ( mult_signed_mode_i   ),

    .op_a_i          ( mult_operand_a_i     ),
    .op_b_i          ( mult_operand_b_i     ),
    .op_c_i          ( mult_operand_c_i     ),
    .imm_i           ( mult_imm_i           ),

    .dot_op_a_i      ( mult_dot_op_a_i      ),
    .dot_op_b_i      ( mult_dot_op_b_i      ),
    .dot_op_c_i      ( mult_dot_op_c_i      ),
    .dot_signed_i    ( mult_dot_signed_i    ),

    .result_o        ( mult_result          ),

    .multicycle_o    ( mult_multicycle_o    ),
    .ready_o         ( mult_ready           ),
    .ex_ready_i      ( ex_ready_o           )
  );


  ///////////////////////////////////////
  // EX/WB Pipeline Register           //
  ///////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
  begin : EX_WB_Pipeline_Register
    if (~rst_n)
    begin
      regfile_waddr_wb_o   <= '0;
      regfile_we_wb_o      <= 1'b0;
    end
    else
    begin
      if (ex_valid_o) // wb_ready_i is implied
      begin
        regfile_we_wb_o    <= regfile_we_i;
        if (regfile_we_i) begin
          regfile_waddr_wb_o <= regfile_waddr_i;
        end
      end else if (wb_ready_i) begin
        // we are ready for a new instruction, but there is none available,
        // so we just flush the current one out of the pipe
        regfile_we_wb_o    <= 1'b0;
      end
    end
  end

  // As valid always goes to the right and ready to the left, and we are able
  // to finish branches without going to the WB stage, ex_valid does not
  // depend on ex_ready.
  assign ex_ready_o = (alu_ready & mult_ready & lsu_ready_ex_i & wb_ready_i) | branch_in_ex_i;
  assign ex_valid_o = (alu_ready & mult_ready & lsu_ready_ex_i & wb_ready_i);

endmodule
