// ============================================================================
// File: bmu_bitwise_permute.sv (Phase 1)
// Description: Logical, single-bit, sign-extension, and byte permutation unit
// Operations: ANDN, ORN, XNOR, BSET, BCLR, BINV, SEXT_B, SEXT_H, REV8
// ============================================================================

module bmu_bitwise_permute
  import bmu_pkg::*;
(
    input  bmu_op_e      op_i,
    input  logic [31:0]  rs1_i,
    input  logic [31:0]  rs2_i,
    output logic [31:0]  result_o
);

  logic [31:0] single_bit_mask;
  logic [31:0] bclr_bit_mask;

  assign single_bit_mask = 32'h1 << rs2_i[4:0];

  assign bclr_bit_mask = (rs2_i[4:0] == 5'd31) ? 32'h0000_0001 : (32'h1 << rs2_i[4:0]);

  always_comb begin
    case (op_i)
      // Logical with Inverted Operand (Zbb)
      BMU_ANDN:   result_o = rs1_i & ~rs2_i;
      BMU_ORN:    result_o = rs1_i | ~rs2_i;
      BMU_XNOR:   result_o = ~(rs1_i ^ rs2_i);

      // Single-Bit Instructions (Zbs)
      BMU_BSET:   result_o = rs1_i |  single_bit_mask;
      BMU_BCLR:   result_o = rs1_i & ~bclr_bit_mask;
      BMU_BINV:   result_o = rs1_i ^  single_bit_mask;

      // Sign-Extension (Zbb)
      BMU_SEXT_B: result_o = {{24{rs1_i[6]}},  rs1_i[7:0]};
      BMU_SEXT_H: result_o = {{16{rs1_i[15]}}, rs1_i[15:0]};

      // Byte Permutation (Zbb)
      BMU_REV8:   result_o = {rs1_i[7:0], rs1_i[15:8], rs1_i[23:16], rs1_i[31:24]};

      default:    result_o = 32'h0;
    endcase
  end

endmodule : bmu_bitwise_permute
