////////////////////////////////////////////////////////////////////////////////
// Engineer        Christian Palmiero - cp3025@columbia.edu                   //
//                                                                            //
// Design Name:    Mode tag                                                   //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Mode decoder                                               //
//                 This unit reads the MODE field of the Tag Propagation      //
//                 Register and sends the proper signals to the EX stage      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module riscv_mode_tag
(
  // from IF/ID pipeline
  input  logic [31:0] instr_rdata_i,           // instruction read from instr memory/cache

  // from CSRs
  input  logic [31:0] tpr_i,

  // ALU signals
  output logic [ALU_MODE_WIDTH-1:0] alu_operator_o_mode // ALU tags operation
);

  always_comb
  begin
    alu_operator_o_mode          = ALU_MODE_OLD;

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
        alu_operator_o_mode  = tpr_i[JUMP_HIGH:JUMP_LOW];
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
        alu_operator_o_mode  = tpr_i[BRANCH_HIGH:BRANCH_LOW];
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
      //OPCODE_STORE_POST,
      OPCODE_LUI,
      OPCODE_AUIPC
      : begin
        alu_operator_o_mode  = tpr_i[LOADSTORE_HIGH:LOADSTORE_LOW];
      end

      OPCODE_LOAD
      //OPCODE_LOAD_POST,
      : begin
        alu_operator_o_mode = ALU_MODE_OLD;
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
            alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
          end
          3'b001: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLLI
                alu_operator_o_mode  = tpr_i[SHIFT_HIGH:SHIFT_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b010, 3'b011: begin  // SLTI, SLTIU
            alu_operator_o_mode  = tpr_i[COMPARISON_HIGH:COMPARISON_LOW];
          end
          3'b100, 3'b110, 3'b111: begin  // XORI, ORI, ANDI
            alu_operator_o_mode  = tpr_i[LOGICAL_HIGH:LOGICAL_LOW];
          end
          3'b101: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000, 7'b0100000: begin // SRLI, SRAI
                alu_operator_o_mode  = tpr_i[SHIFT_HIGH:SHIFT_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          default: begin
            alu_operator_o_mode         = ALU_MODE_OLD;
          end
        endcase
      end

      OPCODE_OP: begin
        unique case (instr_rdata_i[14:12])
          3'b000: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000, 7'b0100000: begin // ADD, SUB
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              7'b0000001: begin // MUL
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b001: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLL
                alu_operator_o_mode  = tpr_i[SHIFT_HIGH:SHIFT_LOW];
              end
              7'b0000001: begin // MULH
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b010: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLT
                alu_operator_o_mode  = tpr_i[COMPARISON_HIGH:COMPARISON_LOW];
              end
              7'b0000001: begin // MULHSU
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b011: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // SLTU
                alu_operator_o_mode  = tpr_i[COMPARISON_HIGH:COMPARISON_LOW];
              end
              7'b0000001: begin // MULHU
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b100: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // XOR
                alu_operator_o_mode  = tpr_i[LOGICAL_HIGH:LOGICAL_LOW];
              end
              7'b0000001: begin // DIV
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b101: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000, 7'b0100000: begin // SRL, SRA
                alu_operator_o_mode  = tpr_i[SHIFT_HIGH:SHIFT_LOW];
              end
              7'b0000001: begin // DIVU
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b110: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // OR
                alu_operator_o_mode  = tpr_i[LOGICAL_HIGH:LOGICAL_LOW];
              end
              7'b0000001: begin // REM
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          3'b111: begin
            unique case (instr_rdata_i[31:25])
              7'b0000000: begin // AND
                alu_operator_o_mode  = tpr_i[LOGICAL_HIGH:LOGICAL_LOW];
              end
              7'b0000001: begin // REMU
                alu_operator_o_mode  = tpr_i[INTEGER_HIGH:INTEGER_LOW];
              end
              default: begin
                alu_operator_o_mode         = ALU_MODE_OLD;
              end
            endcase
          end
          default: begin
            alu_operator_o_mode         = ALU_MODE_OLD;
          end
        endcase
      end
      default: begin
        alu_operator_o_mode         = ALU_MODE_OLD;
      end
    endcase
  end

endmodule
