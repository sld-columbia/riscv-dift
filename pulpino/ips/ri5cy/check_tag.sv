////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    Check tag                                                  //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Check decoder                                              //
//                 This unit reads the CHECK field of the Tag Check           //
//                 Register and sends the proper signals to the EX stage      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_check_tag
(
  // From IF/ID pipeline
  input  logic [31:0] instr_rdata_i,

  // From CSRs
  input  logic [31:0] tcr_i,

  // To EX
  output logic        source_1_o,
  output logic        source_2_o,
  output logic        dest_o,

  // To IF
  output logic        execute_pc_o
);

  always_comb
  begin
    source_1_o   = 1'b0;
    source_2_o   = 1'b0;
    dest_o       = 1'b0;
    execute_pc_o = tcr_i[EXECUTE_PC];

    unique case (instr_rdata_i[6:0])

      ////////////////////////////////
      //      _ _   _ __  __ ____   //
      //     | | | | |  \/  |  _ \  //
      //  _  | | | | | |\/| | |_) | //
      // | |_| | |_| | |  | |  __/  //
      //  \___/ \___/|_|  |_|_|     //
      //                            //
      ////////////////////////////////

      OPCODE_JAL,
      OPCODE_JALR: begin   // Jump and Link
        source_1_o = tcr_i[JUMP_CHECK_S1];
        source_2_o = tcr_i[JUMP_CHECK_S2];
        dest_o     = tcr_i[JUMP_CHECK_D];
      end

     //////////////////////////////////////////////
     //  ____  ____      _    _   _  ____ _   _  //
     // | __ )|  _ \    / \  | \ | |/ ___| | | | //
     // |  _ \| |_) |  / _ \ |  \| | |   | |_| | //
     // | |_) |  _ <  / ___ \| |\  | |___|  _  | //
     // |____/|_| \_\/_/   \_\_| \_|\____|_| |_| //
     //                                          //
     //////////////////////////////////////////////

      OPCODE_BRANCH: begin // Branch
        source_1_o = tcr_i[BRANCH_CHECK_S1];
        source_2_o = tcr_i[BRANCH_CHECK_S2];
        dest_o     = 1'b0;
      end

      //////////////////////////////////
      //  _     ____    ______ _____  //
      // | |   |  _ \  / / ___|_   _| //
      // | |   | | | |/ /\___ \ | |   //
      // | |___| |_| / /  ___) || |   //
      // |_____|____/_/  |____/ |_|   //
      //                              //
      //////////////////////////////////

      OPCODE_STORE,
      OPCODE_STORE_POST,
      OPCODE_LUI,
      OPCODE_AUIPC
      : begin
        source_1_o = tcr_i[LOADSTORE_CHECK_DA];
        source_2_o = tcr_i[LOADSTORE_CHECK_S];
        dest_o     = tcr_i[LOADSTORE_CHECK_D];
      end

      /////////////////////////////////////////////////////////////////////////////////
      //   ___ _____ _   _ _____ ____     ____ _        _    ____ ____  _____ ____   //
      //  / _ \_   _| | | | ____|  _ \   / ___| |      / \  / ___/ ___|| ____/ ___|  //
      // | | | || | | |_| |  _| | |_) | | |   | |     / _ \ \___ \___ \|  _| \___ \  //
      // | |_| || | |  _  | |___|  _ <  | |___| |___ / ___ \ ___) |__) | |___ ___) | //
      //  \___/ |_| |_| |_|_____|_| \_\  \____|_____/_/   \_\____/____/|_____|____/  //
      //                                                                             //
      /////////////////////////////////////////////////////////////////////////////////

      OPCODE_OPIMM: begin
        unique case (instr_rdata_i[14:12])
          3'b000: begin  // ADDI
            source_1_o = tcr_i[INTEGER_CHECK_S1];
            source_2_o = tcr_i[INTEGER_CHECK_S2];
            dest_o     = tcr_i[INTEGER_CHECK_D];
          end
          3'b001: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLLI
                source_1_o = tcr_i[SHIFT_CHECK_S1];
                source_2_o = tcr_i[SHIFT_CHECK_S2];
                dest_o     = tcr_i[SHIFT_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b010, 3'b011: begin  // SLTI, SLTIU
            source_1_o = tcr_i[COMPARISON_CHECK_S1];
            source_2_o = tcr_i[COMPARISON_CHECK_S2];
            dest_o     = tcr_i[COMPARISON_CHECK_D];
          end
          3'b100, 3'b110, 3'b111: begin  // XORI, ORI, ANDI
            source_1_o = tcr_i[LOGICAL_CHECK_S1];
            source_2_o = tcr_i[LOGICAL_CHECK_S2];
            dest_o     = tcr_i[LOGICAL_CHECK_D];
          end
          3'b101: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000, 7'b0100000: begin // SRLI, SRAI
                source_1_o = tcr_i[SHIFT_CHECK_S1];
                source_2_o = tcr_i[SHIFT_CHECK_S2];
                dest_o     = tcr_i[SHIFT_CHECK_D];
              end
              default: ;
            endcase
          end
          default: ;
        endcase
      end

      OPCODE_OP: begin
        unique case (instr_rdata_i[14:12])
          3'b000: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000, 7'b0100000: begin // ADD, SUB
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              7'b0000001: begin // MUL
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b001: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLL
                source_1_o = tcr_i[SHIFT_CHECK_S1];
                source_2_o = tcr_i[SHIFT_CHECK_S2];
                dest_o     = tcr_i[SHIFT_CHECK_D];
              end
              7'b0000001: begin // MULH
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b010: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLT
                source_1_o = tcr_i[COMPARISON_CHECK_S1];
                source_2_o = tcr_i[COMPARISON_CHECK_S2];
                dest_o     = tcr_i[COMPARISON_CHECK_D];
              end
              7'b0000001: begin // MULHSU
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b011: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLTU
                source_1_o = tcr_i[COMPARISON_CHECK_S1];
                source_2_o = tcr_i[COMPARISON_CHECK_S2];
                dest_o     = tcr_i[COMPARISON_CHECK_D];
              end
              7'b0000001: begin // MULHU
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b100: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // XOR
                source_1_o = tcr_i[LOGICAL_CHECK_S1];
                source_2_o = tcr_i[LOGICAL_CHECK_S2];
                dest_o     = tcr_i[LOGICAL_CHECK_D];
              end
              7'b0000001: begin // DIV
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b101: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000, 7'b0100000: begin // SRL, SRA
                source_1_o = tcr_i[SHIFT_CHECK_S1];
                source_2_o = tcr_i[SHIFT_CHECK_S2];
                dest_o     = tcr_i[SHIFT_CHECK_D];
              end
              7'b0000001: begin // DIVU
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b110: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // OR
                source_1_o = tcr_i[LOGICAL_CHECK_S1];
                source_2_o = tcr_i[LOGICAL_CHECK_S2];
                dest_o     = tcr_i[LOGICAL_CHECK_D];
              end
              7'b0000001: begin // REM
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          3'b111: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // AND
                source_1_o = tcr_i[LOGICAL_CHECK_S1];
                source_2_o = tcr_i[LOGICAL_CHECK_S2];
                dest_o     = tcr_i[LOGICAL_CHECK_D];
              end
              7'b0000001: begin // REMU
                source_1_o = tcr_i[INTEGER_CHECK_S1];
                source_2_o = tcr_i[INTEGER_CHECK_S2];
                dest_o     = tcr_i[INTEGER_CHECK_D];
              end
              default: ;
            endcase
          end
          default: ;
        endcase
      end
      default: ;
    endcase
  end

endmodule
