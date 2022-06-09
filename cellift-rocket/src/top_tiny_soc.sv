// Copyright 2022 Flavien Solt, ETH Zurich.
// Licensed under the General Public License, Version 3.0, see LICENSE for details.
// SPDX-License-Identifier: GPL-3.0-only

module top_tiny_soc #(
    parameter int unsigned NumTaints = 1,

    parameter int unsigned NumWords = 1 << 17,
    parameter int unsigned AddrWidth = 32,
    parameter int unsigned DataWidth = 64,

    parameter int unsigned StrbWidth = DataWidth >> 3,
    localparam type addr_t = logic [AddrWidth-1:0],
    localparam type data_t = logic [DataWidth-1:0],
    localparam type strb_t = logic [StrbWidth-1:0]
) (
  input logic clk_i,
  input logic rst_ni,

  // End-of-benchmark signaling interface,
  output logic [30:0] mmio_aw_addr_o,
  output logic mmio_aw_valid_o,

  output data_t mem_rdata_o // To prevent the whole internal logic from being optimized out.
);

  logic  mem_req;
  logic  mem_gnt;
  addr_t mem_addr;
  data_t mem_wdata;
  strb_t mem_strb;
  logic  mem_we;

  rocket_mem_top i_mem_top (
    .clock(clk_i),
    .reset_wire_reset(~rst_ni),

    .mmio_aw_addr(mmio_aw_addr_o),
    .mmio_aw_valid(mmio_aw_valid_o),

    .req_o(mem_req),
    .we_o(mem_we),
    .addr_o(mem_addr),
    .be_o(mem_strb),
    .data_o(mem_wdata),
    .data_i(mem_rdata_o)
  );

  ///////////////////////////////
  // Instruction SRAM instance //
  ///////////////////////////////

  noift_sram_mem #(
    .Width(DataWidth),
    .Depth(NumWords),
    .NumTaints(NumTaints),
    .RelocateRequestUp(64'h10000000) // 80000000 >> 3
  ) i_sram (
    .clk_i,
    .rst_ni,

    .req_i(mem_req),
    .write_i(mem_we),
    .addr_i(mem_addr >> 3), // 64-bit words
    .wdata_i(mem_wdata),
    .wmask_i({{8{mem_strb[7]}}, {8{mem_strb[6]}}, {8{mem_strb[5]}}, {8{mem_strb[4]}}, {8{mem_strb[3]}}, {8{mem_strb[2]}}, {8{mem_strb[1]}}, {8{mem_strb[0]}}}),
    .rdata_o(mem_rdata_o)
  );

endmodule;
