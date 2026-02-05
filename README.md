# AIC_INT

**AIC_INT** is a hardware-oriented project focused on **fault injection, control-flow manipulation, and security evaluation** of cryptographic and signal-processing architectures.  
The repository is structured to clearly separate **fault emulation**, **functional simulation**, and **hardware implementation**, enabling reproducibility and systematic validation.

---

## 📁 Repository Structure


---

## 📂 Folder Description

### 🔹 `emulation/`
This directory contains modules and scripts used for **fault and error emulation**, including:
- Control-signal and data-path fault injection logic
- Bit-level and word-level error models
- Emulation of unconventional delays and control-flow disruptions

These components are primarily intended for **security analysis**, such as:
- Fault attacks
- Hardware Trojan activation
- Side-channel–assisted fault studies

---

### 🔹 `simulation/`
This folder includes all files required for **python  simulation**, such as:

The simulation framework is used to:
- Verify functional correctness
- Validate fault detection and correction logic
- Analyze behavior under injected faults

---

### 🔹 `implementation/`
This directory contains **FPGA-ready implementation files**, including:
- Synthesizable RTL designs
- Constraint files
- FPGA-specific wrappers
- Resource and timing evaluation setups

The implementation flow targets FPGA platforms and is used to:
- Measure area, timing, and power overheads
- Validate deployability on real hardware
- Compare baseline and fault-resilient designs

---

## 🎯 Objectives

- Enable **systematic fault injection and analysis**
- Support **secure hardware design evaluation**
- Provide a **reproducible framework** for emulation, simulation, and implementation
- Facilitate research on **fault attacks, hardware Trojans, and countermeasures**

---

## 🔬 Usage Workflow

1. **Emulation**  
   Configure fault models and injection logic in `emulation/`.

2. **Simulation**  
   Validate functionality and fault behavior using testbenches in `simulation/`.

3. **Implementation**  
   Synthesize and evaluate the design on FPGA using files in `implementation/`.

---

## 📌 Notes

- The directory separation is intentional to maintain **clarity and reproducibility**
- All modules are designed to be **modular and extensible**
- Suitable for academic research, prototyping, and security evaluation

---

## 📄 License

(Add license information here, if applicable)

---

## 📬 Contact

For questions, collaboration, or issues, please open a GitHub issue or contact the repository maintainer.
