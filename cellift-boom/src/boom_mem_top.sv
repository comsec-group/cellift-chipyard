// Copyright 2022 Flavien Solt, ETH Zurich.
// Licensed under the General Public License, Version 3.0, see LICENSE for details.
// SPDX-License-Identifier: GPL-3.0-only

module boom_mem_top #(
  parameter int unsigned ID_WIDTH      = 4,
  parameter int unsigned ADDR_WIDTH    = 32,
  parameter int unsigned DATA_WIDTH    = 64,
) (
  input logic clock,
  input logic reset_wire_reset,

  // End-of-benchmark signaling interface,
  output logic [30:0] mmio_aw_addr,
  output logic mmio_aw_valid,

  // Memory interface.
  output logic                    req_o,
  output logic                    we_o,
  output logic [ADDR_WIDTH-1:0]   addr_o,
  output logic [DATA_WIDTH/8-1:0] be_o,
  output logic [DATA_WIDTH-1:0]   data_o,
  input  logic [DATA_WIDTH-1:0]   data_i
);

  ///////////////////////////
  // AXI signals
  ///////////////////////////

  logic        axi4_mem_0_clock;
  logic        axi4_mem_0_reset;
  logic        axi4_mem_0_bits_aw_ready;
  logic        axi4_mem_0_bits_aw_valid;
  logic [3:0]  axi4_mem_0_bits_aw_bits_id;
  logic [31:0] axi4_mem_0_bits_aw_bits_addr;
  logic [7:0]  axi4_mem_0_bits_aw_bits_len;
  logic [2:0]  axi4_mem_0_bits_aw_bits_size;
  logic [1:0]  axi4_mem_0_bits_aw_bits_burst;
  logic        axi4_mem_0_bits_aw_bits_lock;
  logic [3:0]  axi4_mem_0_bits_aw_bits_cache;
  logic [2:0]  axi4_mem_0_bits_aw_bits_prot;
  logic [3:0]  axi4_mem_0_bits_aw_bits_qos;
  logic        axi4_mem_0_bits_w_ready;
  logic        axi4_mem_0_bits_w_valid;
  logic [63:0] axi4_mem_0_bits_w_bits_data;
  logic [7:0]  axi4_mem_0_bits_w_bits_strb;
  logic        axi4_mem_0_bits_w_bits_last;
  logic        axi4_mem_0_bits_b_ready;
  logic        axi4_mem_0_bits_b_valid;
  logic [3:0]  axi4_mem_0_bits_b_bits_id;
  logic [1:0]  axi4_mem_0_bits_b_bits_resp;
  logic        axi4_mem_0_bits_ar_ready;
  logic        axi4_mem_0_bits_ar_valid;
  logic [3:0]  axi4_mem_0_bits_ar_bits_id;
  logic [31:0] axi4_mem_0_bits_ar_bits_addr;
  logic [7:0]  axi4_mem_0_bits_ar_bits_len;
  logic [2:0]  axi4_mem_0_bits_ar_bits_size;
  logic [1:0]  axi4_mem_0_bits_ar_bits_burst;
  logic        axi4_mem_0_bits_ar_bits_lock;
  logic [3:0]  axi4_mem_0_bits_ar_bits_cache;
  logic [2:0]  axi4_mem_0_bits_ar_bits_prot;
  logic [3:0]  axi4_mem_0_bits_ar_bits_qos;
  logic        axi4_mem_0_bits_r_ready;
  logic        axi4_mem_0_bits_r_valid;
  logic [3:0]  axi4_mem_0_bits_r_bits_id;
  logic [63:0] axi4_mem_0_bits_r_bits_data;
  logic [1:0]  axi4_mem_0_bits_r_bits_resp;
  logic        axi4_mem_0_bits_r_bits_last;

  ChipTop i_chip_top (
    .reset(reset_wire_reset),
    .clock_clock(clock),

    .custom_boot(1'b0),

    .axi4_mem_0_clock(axi4_mem_0_clock),
    .axi4_mem_0_reset(axi4_mem_0_reset),
    .axi4_mem_0_bits_aw_ready(axi4_mem_0_bits_aw_ready),
    .axi4_mem_0_bits_aw_valid(axi4_mem_0_bits_aw_valid),
    .axi4_mem_0_bits_aw_bits_id(axi4_mem_0_bits_aw_bits_id),
    .axi4_mem_0_bits_aw_bits_addr(axi4_mem_0_bits_aw_bits_addr),
    .axi4_mem_0_bits_aw_bits_len(axi4_mem_0_bits_aw_bits_len),
    .axi4_mem_0_bits_aw_bits_size(axi4_mem_0_bits_aw_bits_size),
    .axi4_mem_0_bits_aw_bits_burst(axi4_mem_0_bits_aw_bits_burst),
    .axi4_mem_0_bits_aw_bits_lock(axi4_mem_0_bits_aw_bits_lock),
    .axi4_mem_0_bits_aw_bits_cache(axi4_mem_0_bits_aw_bits_cache),
    .axi4_mem_0_bits_aw_bits_prot(axi4_mem_0_bits_aw_bits_prot),
    .axi4_mem_0_bits_aw_bits_qos(axi4_mem_0_bits_aw_bits_qos),
    .axi4_mem_0_bits_w_ready(axi4_mem_0_bits_w_ready),
    .axi4_mem_0_bits_w_valid(axi4_mem_0_bits_w_valid),
    .axi4_mem_0_bits_w_bits_data(axi4_mem_0_bits_w_bits_data),
    .axi4_mem_0_bits_w_bits_strb(axi4_mem_0_bits_w_bits_strb),
    .axi4_mem_0_bits_w_bits_last(axi4_mem_0_bits_w_bits_last),
    .axi4_mem_0_bits_b_ready(axi4_mem_0_bits_b_ready),
    .axi4_mem_0_bits_b_valid(axi4_mem_0_bits_b_valid),
    .axi4_mem_0_bits_b_bits_id(axi4_mem_0_bits_b_bits_id),
    .axi4_mem_0_bits_b_bits_resp(axi4_mem_0_bits_b_bits_resp),
    .axi4_mem_0_bits_ar_ready(axi4_mem_0_bits_ar_ready),
    .axi4_mem_0_bits_ar_valid(axi4_mem_0_bits_ar_valid),
    .axi4_mem_0_bits_ar_bits_id(axi4_mem_0_bits_ar_bits_id),
    .axi4_mem_0_bits_ar_bits_addr(axi4_mem_0_bits_ar_bits_addr),
    .axi4_mem_0_bits_ar_bits_len(axi4_mem_0_bits_ar_bits_len),
    .axi4_mem_0_bits_ar_bits_size(axi4_mem_0_bits_ar_bits_size),
    .axi4_mem_0_bits_ar_bits_burst(axi4_mem_0_bits_ar_bits_burst),
    .axi4_mem_0_bits_ar_bits_lock(axi4_mem_0_bits_ar_bits_lock),
    .axi4_mem_0_bits_ar_bits_cache(axi4_mem_0_bits_ar_bits_cache),
    .axi4_mem_0_bits_ar_bits_prot(axi4_mem_0_bits_ar_bits_prot),
    .axi4_mem_0_bits_ar_bits_qos(axi4_mem_0_bits_ar_bits_qos),
    .axi4_mem_0_bits_r_ready(axi4_mem_0_bits_r_ready),
    .axi4_mem_0_bits_r_valid(axi4_mem_0_bits_r_valid),
    .axi4_mem_0_bits_r_bits_id(axi4_mem_0_bits_r_bits_id),
    .axi4_mem_0_bits_r_bits_data(axi4_mem_0_bits_r_bits_data),
    .axi4_mem_0_bits_r_bits_resp(axi4_mem_0_bits_r_bits_resp),
    .axi4_mem_0_bits_r_bits_last(axi4_mem_0_bits_r_bits_last),

    .axi4_mmio_0_clock(),
    .axi4_mmio_0_reset(),
    .axi4_mmio_0_bits_aw_ready(1'b1),
    .axi4_mmio_0_bits_aw_valid(mmio_aw_valid),
    .axi4_mmio_0_bits_aw_bits_id(),
    .axi4_mmio_0_bits_aw_bits_addr(mmio_aw_addr),
    .axi4_mmio_0_bits_aw_bits_len(),
    .axi4_mmio_0_bits_aw_bits_size(),
    .axi4_mmio_0_bits_aw_bits_burst(),
    .axi4_mmio_0_bits_aw_bits_lock(),
    .axi4_mmio_0_bits_aw_bits_cache(),
    .axi4_mmio_0_bits_aw_bits_prot(),
    .axi4_mmio_0_bits_aw_bits_qos(),
    .axi4_mmio_0_bits_w_ready('0),
    .axi4_mmio_0_bits_w_valid(),
    .axi4_mmio_0_bits_w_bits_data(),
    .axi4_mmio_0_bits_w_bits_strb(),
    .axi4_mmio_0_bits_w_bits_last(),
    .axi4_mmio_0_bits_b_ready(),
    .axi4_mmio_0_bits_b_valid('0),
    .axi4_mmio_0_bits_b_bits_id('0),
    .axi4_mmio_0_bits_b_bits_resp('0),
    .axi4_mmio_0_bits_ar_ready('0),
    .axi4_mmio_0_bits_ar_valid(),
    .axi4_mmio_0_bits_ar_bits_id(),
    .axi4_mmio_0_bits_ar_bits_addr(),
    .axi4_mmio_0_bits_ar_bits_len(),
    .axi4_mmio_0_bits_ar_bits_size(),
    .axi4_mmio_0_bits_ar_bits_burst(),
    .axi4_mmio_0_bits_ar_bits_lock(),
    .axi4_mmio_0_bits_ar_bits_cache(),
    .axi4_mmio_0_bits_ar_bits_prot(),
    .axi4_mmio_0_bits_ar_bits_qos(),
    .axi4_mmio_0_bits_r_ready(),
    .axi4_mmio_0_bits_r_valid('0),
    .axi4_mmio_0_bits_r_bits_id('0),
    .axi4_mmio_0_bits_r_bits_data('0),
    .axi4_mmio_0_bits_r_bits_resp('0),
    .axi4_mmio_0_bits_r_bits_last('0)
  );

  boom_axi_to_mem #(
    .AXI_ID_WIDTH(ID_WIDTH),
    .AXI_ADDR_WIDTH(ADDR_WIDTH),
    .AXI_DATA_WIDTH(DATA_WIDTH)
  ) i_boom_axi_to_mem (
    .axi4_mem_0_clock(axi4_mem_0_clock),
    .axi4_mem_0_reset(axi4_mem_0_reset),
    .axi4_mem_0_bits_aw_ready(axi4_mem_0_bits_aw_ready),
    .axi4_mem_0_bits_aw_valid(axi4_mem_0_bits_aw_valid),
    .axi4_mem_0_bits_aw_bits_id(axi4_mem_0_bits_aw_bits_id),
    .axi4_mem_0_bits_aw_bits_addr(axi4_mem_0_bits_aw_bits_addr),
    .axi4_mem_0_bits_aw_bits_len(axi4_mem_0_bits_aw_bits_len),
    .axi4_mem_0_bits_aw_bits_size(axi4_mem_0_bits_aw_bits_size),
    .axi4_mem_0_bits_aw_bits_burst(axi4_mem_0_bits_aw_bits_burst),
    .axi4_mem_0_bits_aw_bits_lock(axi4_mem_0_bits_aw_bits_lock),
    .axi4_mem_0_bits_aw_bits_cache(axi4_mem_0_bits_aw_bits_cache),
    .axi4_mem_0_bits_aw_bits_prot(axi4_mem_0_bits_aw_bits_prot),
    .axi4_mem_0_bits_aw_bits_qos(axi4_mem_0_bits_aw_bits_qos),
    .axi4_mem_0_bits_w_ready(axi4_mem_0_bits_w_ready),
    .axi4_mem_0_bits_w_valid(axi4_mem_0_bits_w_valid),
    .axi4_mem_0_bits_w_bits_data(axi4_mem_0_bits_w_bits_data),
    .axi4_mem_0_bits_w_bits_strb(axi4_mem_0_bits_w_bits_strb),
    .axi4_mem_0_bits_w_bits_last(axi4_mem_0_bits_w_bits_last),
    .axi4_mem_0_bits_b_ready(axi4_mem_0_bits_b_ready),
    .axi4_mem_0_bits_b_valid(axi4_mem_0_bits_b_valid),
    .axi4_mem_0_bits_b_bits_id(axi4_mem_0_bits_b_bits_id),
    .axi4_mem_0_bits_b_bits_resp(axi4_mem_0_bits_b_bits_resp),
    .axi4_mem_0_bits_ar_ready(axi4_mem_0_bits_ar_ready),
    .axi4_mem_0_bits_ar_valid(axi4_mem_0_bits_ar_valid),
    .axi4_mem_0_bits_ar_bits_id(axi4_mem_0_bits_ar_bits_id),
    .axi4_mem_0_bits_ar_bits_addr(axi4_mem_0_bits_ar_bits_addr),
    .axi4_mem_0_bits_ar_bits_len(axi4_mem_0_bits_ar_bits_len),
    .axi4_mem_0_bits_ar_bits_size(axi4_mem_0_bits_ar_bits_size),
    .axi4_mem_0_bits_ar_bits_burst(axi4_mem_0_bits_ar_bits_burst),
    .axi4_mem_0_bits_ar_bits_lock(axi4_mem_0_bits_ar_bits_lock),
    .axi4_mem_0_bits_ar_bits_cache(axi4_mem_0_bits_ar_bits_cache),
    .axi4_mem_0_bits_ar_bits_prot(axi4_mem_0_bits_ar_bits_prot),
    .axi4_mem_0_bits_ar_bits_qos(axi4_mem_0_bits_ar_bits_qos),
    .axi4_mem_0_bits_r_ready(axi4_mem_0_bits_r_ready),
    .axi4_mem_0_bits_r_valid(axi4_mem_0_bits_r_valid),
    .axi4_mem_0_bits_r_bits_id(axi4_mem_0_bits_r_bits_id),
    .axi4_mem_0_bits_r_bits_data(axi4_mem_0_bits_r_bits_data),
    .axi4_mem_0_bits_r_bits_resp(axi4_mem_0_bits_r_bits_resp),
    .axi4_mem_0_bits_r_bits_last(axi4_mem_0_bits_r_bits_last),

    .req_o(req_o),
    .we_o(we_o),
    .addr_o(addr_o),
    .be_o(be_o),
    .data_o(data_o),
    .data_i(data_i)
  );

endmodule