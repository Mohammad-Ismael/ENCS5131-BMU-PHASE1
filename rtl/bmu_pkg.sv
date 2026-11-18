// ============================================================================
// File: bmu_pkg.sv (Phase 1)
// Description: Package containing operation definitions and types for the BMU
// ============================================================================

package bmu_pkg;

  // Bit Manipulation Operations for Phase 1
  typedef enum logic [5:0] {
    // Zba: Address generation
    BMU_SH1ADD  = 6'd0,
    BMU_SH2ADD  = 6'd1,
    BMU_SH3ADD  = 6'd2,

    // Zbb: Logical with invert
    BMU_ANDN    = 6'd3,
    BMU_ORN     = 6'd4,
    BMU_XNOR    = 6'd5,

    // Zbb: Count and Sign-Extension
    BMU_CLZ     = 6'd6,
    BMU_CTZ     = 6'd7,
    BMU_CPOP    = 6'd8,
    BMU_SEXT_B  = 6'd9,
    BMU_SEXT_H  = 6'd10,

    // Zbb: Min/Max
    BMU_MIN     = 6'd11,
    BMU_MAX     = 6'd12,
    BMU_MINU    = 6'd13,
    BMU_MAXU    = 6'd14,

    // Zbb: Rotates
    BMU_ROL     = 6'd15,
    BMU_ROR     = 6'd16,

    // Zbb: Byte Permutation
    BMU_REV8    = 6'd17,

    // Zbs: Single-Bit Operations
    BMU_BSET    = 6'd18,
    BMU_BCLR    = 6'd19,
    BMU_BINV    = 6'd20,
    BMU_BEXT    = 6'd21,

    // Default / NOP
    BMU_NOP     = 6'd63
  } bmu_op_e;

endpackage : bmu_pkg
