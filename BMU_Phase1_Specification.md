> # ENCS5131, HARDWARE DESIGN LAB
# RISC-V 32-Bit Bit Manipulation Unit (BMU)
## Phase 1 Architecture & Functional Specification

**Document Version:** 1.0  
**Target Architecture:** RV32 (32-bit RISC-V)  
**Supported Extensions:** Zba, Zbb, Zbs  

---

## 1. Overview

The **Bit Manipulation Unit (BMU)** is a dedicated arithmetic and logic execution block for RV32 processor architectures. It accelerates bit-level operations, pointer math, count operations, and single-bit modifications.

This document describes the intended functional behavior, interface timing, and operational requirements of the BMU. Verification engineers must use this specification as the golden truth against which the RTL under test is validated.

---

## 2. Hardware Interface & Port Definitions

The top-level module is `bmu_top`. All signals are synchronous to `clk` with an active-low asynchronous reset `rst_n`.

```
                           +----------------------+
                           |       bmu_top        |
             clk --------->|                      |
           rst_n --------->|                      |
                           |                      |
         valid_i --------->|                      |----------> valid_o
      op_i [5:0] --------->|                      |----------> rd_o [31:0]
    rs1_i [31:0] --------->|                      |
    rs2_i [31:0] --------->|                      |
                           +----------------------+
```

### 2.1 Interface Signals

| Signal | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 | Master system clock (rising-edge active). |
| `rst_n` | Input | 1 | Asynchronous active-low reset. |
| `valid_i` | Input | 1 | Input instruction valid strobe. When asserted, `op_i`, `rs1_i`, and `rs2_i` are sampled on the rising clock edge. |
| `op_i` | Input | 6 | Operation selector enum (`bmu_pkg::bmu_op_e`). |
| `rs1_i` | Input | 32 | Primary 32-bit input operand (RS1). |
| `rs2_i` | Input | 32 | Secondary 32-bit input operand (RS2). For shift, rotate, and single-bit instructions, bits `[4:0]` specify the 5-bit index/shift amount. |
| `valid_o` | Output | 1 | Output valid flag. Asserted exactly 1 cycle after a valid input request (`valid_i = 1`). |
| `rd_o` | Output | 32 | Destination output data register. Captures operation result 1 cycle after `valid_i = 1`. **When `valid_i = 0`, `rd_o` must retain its previous value (hold state).** |

---

## 3. Timing & Latency Specification

- **Pipeline Latency:** Fixed **1 clock cycle** latency.
- **Throughput:** Maximum rate of **1 operation per cycle** (back-to-back streaming supported).
- **Reset Behavior:** While `rst_n == 0`, `valid_o` must be driven to `1'b0` and `rd_o` must be cleared to `32'h0000_0000`.
- **Value Retention:** When `valid_i` deasserts, `valid_o` drops to `0` on the next cycle, and `rd_o` **must retain** the last calculated result until the next valid transaction is processed.

---

## 4. Supported Operations (`bmu_pkg::bmu_op_e`)

The following operations are supported in the Phase 1 BMU design:

| Enum Identifier | Opcode Value | Category | Description |
| :--- | :---: | :--- | :--- |
| `BMU_SH1ADD` | `6'd0` | Zba | Shift left `rs1` by 1 and add to `rs2`. |
| `BMU_SH2ADD` | `6'd1` | Zba | Shift left `rs1` by 2 and add to `rs2`. |
| `BMU_SH3ADD` | `6'd2` | Zba | Shift left `rs1` by 3 and add to `rs2`. |
| `BMU_ANDN`   | `6'd3` | Zbb | Bitwise AND with inverted operand: `rs1 & ~rs2`. |
| `BMU_ORN`    | `6'd4` | Zbb | Bitwise OR with inverted operand: `rs1 \| ~rs2`. |
| `BMU_XNOR`   | `6'd5` | Zbb | Bitwise Exclusive-NOR: `~(rs1 ^ rs2)`. |
| `BMU_CLZ`    | `6'd6` | Zbb | Count leading zeros in `rs1` (from bit 31 downwards). |
| `BMU_CTZ`    | `6'd7` | Zbb | Count trailing zeros in `rs1` (from bit 0 upwards). |
| `BMU_CPOP`   | `6'd8` | Zbb | Count set bits (Hamming weight) in `rs1`. |
| `BMU_SEXT_B` | `6'd9` | Zbb | Sign-extend byte: Replicate bit 7 through bits [31:8]. |
| `BMU_SEXT_H` | `6'd10` | Zbb | Sign-extend halfword: Replicate bit 15 through bits [31:16]. |
| `BMU_MIN`    | `6'd11` | Zbb | Signed minimum of `rs1` and `rs2`. |
| `BMU_MAX`    | `6'd12` | Zbb | Signed maximum of `rs1` and `rs2`. |
| `BMU_MINU`   | `6'd13` | Zbb | Unsigned minimum of `rs1` and `rs2`. |
| `BMU_MAXU`   | `6'd14` | Zbb | Unsigned maximum of `rs1` and `rs2`. |
| `BMU_ROL`    | `6'd15` | Zbb | Rotate left `rs1` by `rs2[4:0]`. |
| `BMU_ROR`    | `6'd16` | Zbb | Rotate right `rs1` by `rs2[4:0]`. |
| `BMU_REV8`   | `6'd17` | Zbb | Byte swap (reverse byte order of `rs1`). |
| `BMU_BSET`   | `6'd18` | Zbs | Set single bit `rs2[4:0]` in `rs1`. |
| `BMU_BCLR`   | `6'd19` | Zbs | Clear single bit `rs2[4:0]` in `rs1`. |
| `BMU_BINV`   | `6'd20` | Zbs | Invert single bit `rs2[4:0]` in `rs1`. |
| `BMU_BEXT`   | `6'd21` | Zbs | Extract single bit `rs2[4:0]` from `rs1` (zero-extended). |
| `BMU_NOP`    | `6'd63` | Control | No operation (returns `32'h0000_0000`). |

---

## 5. Functional Details & Corner Cases

### 5.1 Zba: Address Generation
- **`BMU_SH1ADD`**: `rd = (rs1 << 1) + rs2`
- **`BMU_SH2ADD`**: `rd = (rs1 << 2) + rs2`
- **`BMU_SH3ADD`**: `rd = (rs1 << 3) + rs2`
  - *Note:* All additions wrap on standard 32-bit arithmetic modulo $2^{32}$.

### 5.2 Zbb: Count and Extension Operations
- **`BMU_CLZ`**:
  - Counts the number of continuous 0s starting at MSB (bit 31).
  - Returns `0` if `rs1[31] == 1`.
  - **Critical Requirement:** If `rs1 == 32'h0000_0000`, it **must return 32** (`32'd32`).
- **`BMU_CTZ`**:
  - Counts the number of continuous 0s starting at LSB (bit 0).
  - Returns `0` if `rs1[0] == 1`.
  - **Critical Requirement:** If `rs1 == 32'h0000_0000`, it **must return 32** (`32'd32`).
  - If only bit 31 is set (`32'h8000_0000`), it **must return 31** (`32'd31`).
- **`BMU_CPOP`**:
  - Returns the count of 1-bits in `rs1` (range 0 to 32).
- **`BMU_SEXT_B`**:
  - Replicates sign bit `rs1[7]` to bits `[31:8]`. Lower byte `rs1[7:0]` is passed through.
- **`BMU_SEXT_H`**:
  - Replicates sign bit `rs1[15]` to bits `[31:16]`. Lower halfword `rs1[15:0]` is passed through.

### 5.3 Zbb: Relational Min / Max
- **`BMU_MIN` / `BMU_MAX`**: Signed two's-complement comparison.
  - `MIN`: Returns smaller of `rs1` and `rs2`.
  - `MAX`: Returns larger of `rs1` and `rs2`.
- **`BMU_MINU` / `BMU_MAXU`**: Unsigned magnitude comparison.

### 5.4 Zbb: Rotates & Byte Reversal
- Shift amount is always masked to 5 bits: `shamt = rs2[4:0]`.
- **`BMU_ROL`**: `(rs1 << shamt) | (rs1 >> (32 - shamt))` (when `shamt == 0`, returns `rs1`).
- **`BMU_ROR`**: `(rs1 >> shamt) | (rs1 << (32 - shamt))` (when `shamt == 0`, returns `rs1`).
- **`BMU_REV8`**: `{rs1[7:0], rs1[15:8], rs1[23:16], rs1[31:24]}`.

### 5.5 Zbs: Single-Bit Operations
- Target bit index is always `shamt = rs2[4:0]`. Let `mask = 32'h1 << shamt`.
- **`BMU_BSET`**: `rs1 | mask`
- **`BMU_BCLR`**: `rs1 & (~mask)` (clears bit `shamt`, leaving all other 31 bits unchanged).
- **`BMU_BINV`**: `rs1 ^ mask`
- **`BMU_BEXT`**: `{31'b0, rs1[shamt]}` (returns `1` if bit is set, else `0` for all bit positions `0..31`).
