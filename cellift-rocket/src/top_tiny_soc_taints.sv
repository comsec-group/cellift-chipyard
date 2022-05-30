
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

  logic  mem_req_t0;
  logic  mem_gnt_t0;
  addr_t mem_addr_t0;
  data_t mem_wdata_t0;
  strb_t mem_strb_t0;
  logic  mem_we_t0;
  data_t mem_rdata_t0;

  rocket_mem_top i_mem_top (
    .clock(clk_i),
    .reset_wire_reset(~rst_ni),

    .mmio_aw_addr(mmio_aw_addr_o),
    .mmio_aw_valid(mmio_aw_valid_o),
    .mmio_aw_addr_t0(),
    .mmio_aw_valid_t0(),

    .req_o(mem_req),
    .req_o_t0(mem_req_t0),
    .we_o(mem_we),
    .we_o_t0(mem_we_t0),
    .addr_o(mem_addr),
    .addr_o_t0(mem_addr_t0),
    .be_o(mem_strb),
    .be_o_t0(mem_strb_t0),
    .data_o(mem_wdata),
    .data_o_t0(mem_wdata_t0),
    .data_i(mem_rdata_o),
    .data_i_t0(mem_rdata_t0)
  );

  ///////////////////////////////
  // Instruction SRAM instance //
  ///////////////////////////////

  ift_sram_mem #(
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
    .rdata_o(mem_rdata_o),

    .req_i_t0(mem_req_t0),
    .write_i_t0(mem_we_t0),
    .addr_i_t0(mem_addr_t0 >> 3), // 64-bit words
    .wdata_i_t0(mem_wdata_t0),
    .wmask_i_t0({{8{mem_strb_t0[7]}}, {8{mem_strb_t0[6]}}, {8{mem_strb_t0[5]}}, {8{mem_strb_t0[4]}}, {8{mem_strb_t0[3]}}, {8{mem_strb_t0[2]}}, {8{mem_strb_t0[1]}}, {8{mem_strb_t0[0]}}}),
    .rdata_o_t0(mem_rdata_t0)
  );

endmodule;
