/**
* Created with the ESP Memory Generator
*
* Copyright (c) 2014-2017, Columbia University
*
* @author Paolo Mantovani <paolo@cs.columbia.edu>
*/

`timescale  1 ps / 1 ps

module xil_block_ram_8192x4b_1w1r(
    CLK,
    CE0,
    A0,
    D0,
    WE0,
    WEM0,
    CE1,
    A1,
    Q1
  );
  input CLK;
  input CE0;
  input [12:0] A0;
  input [3:0] D0;
  input WE0;
  input [3:0] WEM0;
  input CE1;
  input [12:0] A1;
  output [3:0] Q1;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][0:0][0:0][1:0][1:0];
  reg        [12:0] bank_A   [0:0][0:0][0:0][1:0][1:0];
  reg         [1:0] bank_D   [0:0][0:0][0:0][1:0][1:0];
  reg               bank_WE  [0:0][0:0][0:0][1:0][1:0];
  reg         [1:0] bank_WEM [0:0][0:0][0:0][1:0][1:0];
  wire        [1:0] bank_Q   [0:0][0:0][0:0][1:0][1:0];
  wire        [0:0] ctrld    [1:1];
  wire        [0:0] ctrlh    [1:0];
  wire        [0:0] ctrlv    [1:0];
  reg         [0:0] seld     [1:1];
  reg         [0:0] selh     [1:1];
  reg         [0:0] selv     [1:1];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][0:0][0:0][1:0][1:0];

  task check_access;
    input integer iface;
    input integer d;
    input integer h;
    input integer v;
    input integer hh;
    input integer p;
  begin
    if ((check_bank_access[d][h][v][hh][p] != -1) &&
        (check_bank_access[d][h][v][hh][p] != iface)) begin
      $display("ASSERTION FAILED in %m: port conflict on bank", h, "h", v, "v", hh, "hh", " for port", p, " involving interfaces", check_bank_access[d][h][v][hh][p], iface);
      $finish;
    end
    else begin
      check_bank_access[d][h][v][hh][p] = iface;
    end
  end
  endtask
// synthesis translate_on
// synopsys translate_on

  assign ctrld[1] = 0;
  assign ctrlh[0] = 0;
  assign ctrlh[1] = 0;
  assign ctrlv[0] = 0;
  assign ctrlv[1] = 0;

  always @(posedge CLK) begin
    seld[1] <= ctrld[1];
    selh[1] <= ctrlh[1];
    selv[1] <= ctrlv[1];
  end

  generate
  for (h = 0; h < 1; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 1; v = v + 1) begin : gen_ctrl_vbanks
      for (hh = 0; hh < 2; hh = hh + 1) begin : gen_ctrl_hhbanks

        always @(*) begin : handle_ops

          /** Default **/
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][0] = -1;
// synthesis translate_on
// synopsys translate_on
          bank_CE[0][h][v][hh][0]  = 0;
          bank_A[0][h][v][hh][0]   = 0;
          bank_D[0][h][v][hh][0]   = 0;
          bank_WE[0][h][v][hh][0]  = 0;
          bank_WEM[0][h][v][hh][0] = 0;
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][1] = -1;
// synthesis translate_on
// synopsys translate_on
          bank_CE[0][h][v][hh][1]  = 0;
          bank_A[0][h][v][hh][1]   = 0;
          bank_D[0][h][v][hh][1]   = 0;
          bank_WE[0][h][v][hh][1]  = 0;
          bank_WEM[0][h][v][hh][1] = 0;

          /** Handle 1w:1r **/
          // Duplicated bank set 0
          if (h % 1 == 0) begin
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synthesis translate_on
// synopsys translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[12:0];
              if (hh != 1) begin
                bank_D[0][h][v][hh][0]   = D0[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D0[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE0;
            end
          end
          // Always choose duplicated bank set 0
          if (h % 1 == 0) begin
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(1, 0, h, v, hh, 1);
// synthesis translate_on
// synopsys translate_on
                bank_CE[0][h][v][hh][1]  = CE1;
                bank_A[0][h][v][hh][1]   = A1[12:0];
            end
          end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 2; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 1 && (hh + 1) * 2 > 4) begin : gen_q_assign_hhbanks_last_1 
       assign Q1[3:2 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][1][1:0];
    end else begin : gen_q_assign_hhbanks_others_1 
      assign Q1[2 * (hh + 1) - 1:2 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][1];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 1; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 1; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 2; hh = hh + 1) begin : gen_wires_hhbanks

          BRAM_8192x2 bank_i(
              .CLK(CLK),
              .CE0(bank_CE[d][h][v][hh][0]),
              .A0(bank_A[d][h][v][hh][0]),
              .D0(bank_D[d][h][v][hh][0]),
              .WE0(bank_WE[d][h][v][hh][0]),
              .WEM0(bank_WEM[d][h][v][hh][0]),
              .Q0(bank_Q[d][h][v][hh][0]),
              .CE1(bank_CE[d][h][v][hh][1]),
              .A1(bank_A[d][h][v][hh][1]),
              .D1(bank_D[d][h][v][hh][1]),
              .WE1(bank_WE[d][h][v][hh][1]),
              .WEM1(bank_WEM[d][h][v][hh][1]),
              .Q1(bank_Q[d][h][v][hh][1])
            );

// synthesis translate_off
// synopsys translate_off
            always @(posedge CLK) begin
              if ((bank_CE[d][h][v][hh][0] & bank_CE[d][h][v][hh][1]) &&
                  (bank_WE[d][h][v][hh][0] | bank_WE[d][h][v][hh][1]) &&
                  (bank_A[d][h][v][hh][0] == bank_A[d][h][v][hh][1])) begin
                $display("ASSERTION FAILED in %m: address conflict on bank", h, "h", v, "v", hh, "hh");
                $finish;
              end
            end
// synthesis translate_on
// synopsys translate_on

        end
      end
    end
  end
  endgenerate

endmodule
