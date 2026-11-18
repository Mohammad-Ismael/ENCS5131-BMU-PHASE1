// ============================================================================
// File: bmu_bit_counter.sv (Phase 1)
// Description: Bit-counting unit for leading zeros, trailing zeros, and popcount
// Operations: CLZ, CTZ, CPOP
// ============================================================================

module bmu_bit_counter
  import bmu_pkg::*;
(
    input  bmu_op_e      op_i,
    input  logic [31:0]  rs1_i,
    output logic [31:0]  result_o
);

  logic [5:0] clz_count;
  logic [5:0] ctz_count;
  logic [5:0] cpop_count;

  // Count Leading Zeros
  always_comb begin
    clz_count = 6'd0;
    for (int i = 31; i >= 0; i--) begin
      if (rs1_i[i]) begin
        clz_count = 6'd31 - 6'(i);
        break;
      end
    end
  end

  // Count Trailing Zeros
  always_comb begin
    ctz_count = 6'd32;
    for (int i = 0; i < 31; i++) begin
      if (rs1_i[i]) begin
        ctz_count = 6'(i);
        break;
      end
    end
  end

  // Population Count (Hamming Weight)
  always_comb begin
    cpop_count = 6'd0;
    for (int i = 0; i < 32; i++) begin
      cpop_count += 6'(rs1_i[i]);
    end
  end

  // Result Selection
  always_comb begin
    case (op_i)
      BMU_CLZ:  result_o = {26'b0, clz_count};
      BMU_CTZ:  result_o = {26'b0, ctz_count};
      BMU_CPOP: result_o = {26'b0, cpop_count};
      default:  result_o = 32'h0;
    endcase
  end

endmodule : bmu_bit_counter
