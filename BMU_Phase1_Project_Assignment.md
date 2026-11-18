> # ENCS5131, HARDWARE DESIGN LAB
## Phase 1: UVM Verification & Bug Hunting of the RISC-V BMU

**Target DUT:** RISC-V 32-Bit Bit Manipulation Unit (`bmu_top`)  
**Methodology:** Universal Verification Methodology (UVM 1.2 / IEEE 1800.2)  
**Deliverables:** Verification Plan, UVM Testbench Environment, Functional Coverage Report, Bug Report  

---

## 1. Project Overview & Objectives

In this project, you will act as a **Design Verification (DV) Engineer** at a leading semiconductor company. You have received the RTL source files for a newly developed RISC-V Bit Manipulation Unit (BMU) along with its architectural specification document: [BMU_Phase1_Specification.md](BMU_Phase1_Specification.md).

The RTL implementation has been passed through basic linting and initial compilation, but it has **not** yet been thoroughly verified. Your objective is to build a complete, industry-standard **UVM Verification Environment** from scratch, develop an exhaustive **Verification Plan**, measure **Functional Coverage**, and identify, isolate, and document **all hardware bugs** planted in the design.

> [!IMPORTANT]
> The design contains multiple subtle design bugs (spanning arithmetic corner cases, boundary conditions, polarity inversions, and control pipeline timing). The exact number of bugs is **undisclosed**. A simple, naive directed test will miss most of them. Only a robust constrained-random UVM environment backed by high functional coverage will uncover all defects.

---

## 2. DUT Directory Structure

You are provided with the following files in this directory:

```text
phase1/
├── bmu_pkg.sv                       # Operation enumeration (bmu_op_e)
├── bmu_barrel_shifter.sv            # Rotator and bit-extraction sub-unit
├── bmu_address_adder.sv             # Address generation and min/max sub-unit
├── bmu_bit_counter.sv               # CLZ, CTZ, and CPOP sub-unit
├── bmu_bitwise_permute.sv           # Inverted logic, single-bit, and sign-extension sub-unit
├── bmu_top.sv                       # Top-level DUT module
├── BMU_Phase1_Specification.md      # Architectural Golden Specification
├── sanity_sequence_expected.txt     # Reference sanity sequence & expected outputs
└── BMU_Phase1_Project_Assignment.md # This assignment document
```

---

## 3. Tasks & Required Deliverables

### Task 1: Verification Plan (V-Plan)
Before writing code, create a comprehensive Verification Plan (`verification_plan.md` or `.pdf`):
1. **Features Under Test:** List all 22 supported operations and interface protocols.
2. **Corner Cases & Boundary Conditions:**
   - Zero operands.
   - Max values.
   - etc.
3. **Stimulus Strategy**.
4. **Coverage Matrix**.
5. **etc**

### Task 2: UVM Testbench Architecture
Implement a complete UVM environment:
- **`bmu_if.sv`:** SystemVerilog Interface with clocking blocks and modports.
- **`bmu_seq_item.sv`:** Transaction class containing randomized fields (`op`, `rs1`, `rs2`), constraints, and utility functions (`do_copy`, `do_compare`, `convert2string`).
- **`bmu_sequencer.sv` & `bmu_driver.sv`:** Drives transactions onto the interface respecting the 1-cycle latency protocol.
- **`bmu_monitor.sv`:** Passively monitors `valid_i`, `op_i`, `rs1_i`, `rs2_i`, and samples `valid_o`, `rd_o` exactly 1 cycle later.
- **`bmu_agent.sv`:** Encapsulates the sequencer, driver, and monitor.
- **`bmu_scoreboard.sv`:** Contains a golden software reference model / predictor to compare actual DUT outputs with golden expected outputs and report mismatches.
- **`bmu_coverage.sv`:** UVM subscriber collecting functional coverage using `covergroup` and `coverpoint`.
- **`bmu_env.sv` & `bmu_test.sv`:** Integrates the components and configures tests.
- **`top_tb.sv`:** Top-level simulation module instantiating DUT, clock generator, and interface.

### Task 3: Sanity Sequence Check
To ensure your interface and clocking blocks are connected correctly:
- Run the 10-transaction stimulus provided in [sanity_sequence_expected.txt](sanity_sequence_expected.txt).
- Verify that your monitor captures the exact cycle-by-cycle hex values listed in that file.

### Task 4: Functional Coverage Requirement
Your testbench must achieve:
- **100% Opcode Coverage:** All supported operations in `bmu_op_e` exercised.
- **100% Shift Amount Coverage:** All shift amounts `[0..31]` exercised for rotate and single-bit instructions.
- **> 90% Corner-Case Coverage:** All defined boundary values exercised.
- **Pipeline Transition Coverage:** Back-to-back operations and idle cycle recovery.

### Task 5: Bug Report
For **every bug** you find in the RTL, document it using the following format:
```markdown
### Bug Report #[ID]
- **Operation / Area:** [e.g., BMU_CLZ, Pipeline Handshake, etc.]
- **Failing File & Line:** [File name and approximate line number]
- **Description:** [What the bug is and why it fails]
- **Trigger Condition:** [Exact input vector: op, rs1, rs2]
- **Expected Output:** [Per Specification]
- **Actual DUT Output:** [Observed from simulation]
- **Recommended RTL Fix:** [How to fix the RTL code]
```

---

## 4. Grading (100 Points Total)

| Category | Points | Description |
| :--- | :---: | :--- |
| **Verification Plan** | 15 | Completeness of test cases, corner cases, and coverage mapping. |
| **UVM Environment Architecture** | 25 | Proper UVM hierarchy, phase usage, clean OOP practices, separation of concerns. |
| **Scoreboard & Golden Predictor** | 20 | Robust golden reference model correctly checking all operations. |
| **Functional Coverage** | 15 | Completeness of covergroups, cross-coverage, and boundary bins. |
| **Bug Discovery & Reports** | 20 | Number of planted bugs identified, isolated, and documented with reproducible vectors. |
| **Final Verification Report** | 5 | Clarity of final report, code cleanliness, and simulation logs. |

---

## 5. Submission Guidelines

Submit a single compressed archive (`bmu_phase1_<stName_stID>.zip`) containing:
1. Complete UVM source code (`tb/`, `env/`, `tests/`, `agents/`, `seq/`).
2. Simulation scripts (e.g., Makefile, run scripts for Verilator / VCS / Questa).
3. `Verification_Plan.md/PDF`.
4. `Functional_Coverage_Report.txt` / HTML summary (You Must Use Verdi).
5. `Bug_Report.md`.
