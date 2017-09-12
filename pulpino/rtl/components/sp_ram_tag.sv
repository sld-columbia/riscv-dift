// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module sp_ram_tag
  #(
    parameter ADDR_WIDTH,
    parameter DATA_WIDTH,
    parameter NUM_WORDS
  )(
    // Clock and Reset
    input  logic                    clk,

    input  logic                    en_i,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic                    wdata_i,
    output logic [DATA_WIDTH/8-1:0] rdata_o,
    input  logic                    we_i,
    input  logic [DATA_WIDTH/8-1:0] be_i
  );

  localparam words = NUM_WORDS/(DATA_WIDTH/8);

  logic [DATA_WIDTH/8-1:0] mem[words];
  logic [DATA_WIDTH/8-1:0] wdata;
  logic [ADDR_WIDTH-1-$clog2(DATA_WIDTH/8):0] addr;

  integer i;


  assign addr = addr_i[ADDR_WIDTH-1:$clog2(DATA_WIDTH/8)];


  always @(posedge clk)
  begin
    if (en_i && we_i)
    begin
      for (i = 0; i < DATA_WIDTH/8; i++) begin
        if (be_i[i])
          mem[addr][i] <= wdata_i;
      end
    end

    rdata_o <= mem[addr];
  end

endmodule
