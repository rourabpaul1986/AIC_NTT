
# Fault Injection Simulation Framework

This repository contains a Python-based fault injection framework designed to evaluate the impact of bit-level faults in **PQC** and **FHE** applications. The tool allows configurable fault models, injection modes, and sample sizes for systematic experimentation.

---

## 📌 Features
- Configurable **sample size** for statistical evaluation
- Bit-level **fault injection control**
- Support for **PQC** and **FHE** applications
- Multiple **fault injection types**
- Selective **operation-level fault injection**
- Partition-based execution using chunks
- Optional **verbose logging**

---

## 🛠️ Requirements
- Python **3.8+**
- Standard Python libraries (`argparse`, `numpy`, etc.)

---

## 🚀 Usage

Run the simulation using the command line:

```bash
python full_AIC_NTT.py -s <samples> -f <fault_bits> -a <application> \
               -i <injection_type> -m <mode> -c <chunks> [-v]

python partial_AIC_NTT.py -s <samples> -f <fault_bits> -a <application> \
               -i <injection_type> -m <mode> -c <chunks> [-v]
