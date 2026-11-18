// ============================================================================
// File: bmu_top.sv (Phase 1)
// Description: Top-Level Bit Manipulation Unit (BMU)
// ============================================================================

module bmu_top
  import bmu_pkg::*;
(
    input  logic         clk,
    input  logic         rst_n,

    // Control & Handshake
    input  logic         valid_i,
    input  bmu_op_e      op_i,

    // Operands
    input  logic [31:0]  rs1_i,
    input  logic [31:0]  rs2_i,

    // Outputs
    output logic         valid_o,
    output logic [31:0]  rd_o
);

  // Sub-unit result buses
  logic [31:0] shifter_res;
  logic [31:0] adder_res;
  logic [31:0] counter_res;
  logic [31:0] bitwise_res;
  logic [31:0] res_comb;

  // 1. Shifter / Rotator Sub-Unit
  bmu_barrel_shifter u_shifter (
    .op_i     (op_i),
    .rs1_i    (rs1_i),
    .rs2_i    (rs2_i),
    .result_o (shifter_res)
  );

  // 2. Address Generation & Min/Max Adder Sub-Unit
  bmu_address_adder u_adder (
    .op_i     (op_i),
    .rs1_i    (rs1_i),
    .rs2_i    (rs2_i),
    .result_o (adder_res)
  );

  // 3. Bit-Counting Sub-Unit
  bmu_bit_counter u_counter (
    .op_i     (op_i),
    .rs1_i    (rs1_i),
    .result_o (counter_res)
  );

  // 4. Bitwise, Logic & Permutation Sub-Unit
  bmu_bitwise_permute u_bitwise (
    .op_i     (op_i),
    .rs1_i    (rs1_i),
    .rs2_i    (rs2_i),
    .result_o (bitwise_res)
  );

  // Multiplexing Results based on Opcode
  always_comb begin
    case (op_i)
      BMU_ROL, BMU_ROR, BMU_BEXT:
        res_comb = shifter_res;

      BMU_SH1ADD, BMU_SH2ADD, BMU_SH3ADD,
      BMU_MIN, BMU_MAX, BMU_MINU, BMU_MAXU:
        res_comb = adder_res;

      BMU_CLZ, BMU_CTZ, BMU_CPOP:
        res_comb = counter_res;

      BMU_ANDN, BMU_ORN, BMU_XNOR,
      BMU_BSET, BMU_BCLR, BMU_BINV,
      BMU_SEXT_B, BMU_SEXT_H,
      BMU_REV8:
        res_comb = bitwise_res;

      default:
        res_comb = 32'h0;
    endcase
  end

  // Pipeline Output Stage
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_o <= 1'b0;
      rd_o    <= 32'h0;
    end else begin
      valid_o <= valid_i;
      if (valid_i) begin
        rd_o <= res_comb;
      end else begin
        rd_o <= 32'h0;
      end
    end
  end

endmodule : bmu_top
