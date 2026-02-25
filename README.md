
## Digital Systems Design | ESCOM-IPN

This repository contains my laboratory practices and projects for the **Design of Digital Systems** course at the School of Computer Science (ESCOM). All hardware descriptions are implemented using **VHDL**.

Overview

The goal of this repository is to document the design, simulation, and implementation of digital logic circuits, ranging from basic combinational gates to complex sequential systems and Finite State Machines (FSM).

* **Language:** VHDL
* **Tools:** Gowin
* **Hardware:** Tang Nano 9K

---

## Repository Structure

I follow a modular structure to keep the source code separated from constraints and simulations:

* `src/`: Hardware description files (`.vhd`).
* `sim/`: Testbenches for functional verification.
* `constraints/`: Pin mapping files (`.xdc` or `.qsf`).
* `docs/`: RTL schematics and simulation waveforms.

---

## Projects Index

Got it. I’ve updated the table to reflect your specific labs. I also took the liberty of refining the descriptions and key components to match standard **VHDL** terminology for those topics.

Here is the updated **Projects Index** section for your `README.md`:

---

## Projects Index

| Project Name | Description | Key Components |
| --- | --- | --- |
| **Lab 01: Frequency Divider** | A clock divider to reduce the FPGA's high-frequency internal clock for human-readable output. | Counters, Flip-Flops, Frequency Scaling |
| **Lab 02: Shift Registers** | Implementation of Serial-In/Parallel-Out (SIPO) and PISO registers for data manipulation. | D Flip-Flops, Shift Logic, Bus Handling |

---

How to Run

1. Clone the repository: `git clone https://github.com/youruser/DSD-ESCOM.git`
2. Open your preferred IDE (Vivado/Quartus).
3. Create a new project and add the files from the `/src` folder.
4. Import the constraints from the `/constraints` folder.
5. Run Synthesis and Implementation.

---

## Authors
* Yair Emmanuel Arciniega Valdez
* Lorena Zuñiga Gonzales
* Raul Abdiel Compaired Nieto
* Victor Ariel Marcial Jimenez
---
