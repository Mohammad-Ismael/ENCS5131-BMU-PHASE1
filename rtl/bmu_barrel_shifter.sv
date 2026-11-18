// ============================================================================
// File: bmu_barrel_shifter.sv (Phase 1)
// Description: Unified rotate and bit-extract execution unit
// Operations: ROL, ROR, BEXT
// ============================================================================

module bmu_barrel_shifter
  import bmu_pkg::*;
(
    input  bmu_op_e      op_i,
    input  logic [31:0]  rs1_i,
    input  logic [31:0]  rs2_i,
    output logic [31:0]  result_o
);

  logic [4:0]  shamt;
  logic [4:0]  shamt_bext;
  logic [63:0] double_word;

  /* verilator lint_off UNUSEDSIGNAL */
  logic [63:0] ror_shift;
  logic [63:0] rol_shift;
  logic [31:5] unused_rs2;
  assign unused_rs2 = rs2_i[31:5];
  /* verilator lint_on UNUSEDSIGNAL */

  assign shamt = rs2_i[4:0];
  assign shamt_bext = {1'b0, rs2_i[3:0]};
  assign double_word = {rs1_i, rs1_i};

  // Right rotation: shift double word right by shamt
  assign ror_shift = double_word >> shamt;

  // Left rotation: shift double word left by shamt
  assign rol_shift = double_word << shamt;

  always_comb begin
    case (op_i)
      BMU_ROR:  result_o = ror_shift[31:0];
      BMU_ROL:  result_o = rol_shift[63:32];
      BMU_BEXT: result_o = {31'b0, rs1_i[shamt_bext]};
      default:  result_o = 32'h0;
    endcase
  end

endmodule : bmu_barrel_shifter
