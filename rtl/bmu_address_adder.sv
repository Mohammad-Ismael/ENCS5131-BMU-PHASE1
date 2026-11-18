// ============================================================================
// File: bmu_address_adder.sv (Phase 1)
// Description: Address generation adder and relational min/max comparison unit
// Operations: SH1ADD, SH2ADD, SH3ADD, MIN, MAX, MINU, MAXU
// ============================================================================

module bmu_address_adder
  import bmu_pkg::*;
(
    input  bmu_op_e      op_i,
    input  logic [31:0]  rs1_i,
    input  logic [31:0]  rs2_i,
    output logic [31:0]  result_o
);

  logic [31:0] shifted_rs1;
  logic [31:0] sum_out;
  logic        signed_less;
  logic        unsigned_less;

  // Shift generation for Zba address arithmetic
  always_comb begin
    case (op_i)
      BMU_SH1ADD: shifted_rs1 = {rs1_i[30:0], 1'b0};
      BMU_SH2ADD: shifted_rs1 = {rs1_i[29:0], 2'b00};
      BMU_SH3ADD: shifted_rs1 = {rs1_i[29:0], 2'b00};
      default:    shifted_rs1 = rs1_i;
    endcase
  end

  assign sum_out = shifted_rs1 + rs2_i;

  // Comparison flags for min/max
  assign signed_less   = ($signed(rs1_i) < $signed(rs2_i));
  assign unsigned_less = (rs1_i < rs2_i);

  // Result selection
  always_comb begin
    case (op_i)
      BMU_SH1ADD,
      BMU_SH2ADD,
      BMU_SH3ADD: result_o = sum_out;

      BMU_MIN:    result_o = signed_less   ? rs2_i : rs1_i;
      BMU_MAX:    result_o = signed_less   ? rs2_i : rs1_i;
      BMU_MINU:   result_o = unsigned_less ? rs1_i : rs2_i;
      BMU_MAXU:   result_o = unsigned_less ? rs2_i : rs1_i;

      default:    result_o = 32'h0;
    endcase
  end

endmodule : bmu_address_adder
