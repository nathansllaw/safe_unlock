# FPGA Combination Lock (FSM-Based)

A finite state machine (FSM)–driven **digital combination lock** implemented in **SystemVerilog** and designed for an FPGA development board (e.g. Intel DE10-Lite / MAX10).

The system allows a user to:
- Set a password
- Enter an attempt
- Verify correctness
- Display lock status and hints using LEDs and seven-segment displays

Two FSM implementations are included:
- **Behavioral FSM (synthesizable)**
- **Gate-level FSM**

---

## Overview

This project implements a secure lock mechanism using:
- A synchronous finite state machine
- Register-based password and attempt storage
- Bitwise comparison logic for validation
- Hint generation logic
- Seven-segment display output for lock state

The design demonstrates **FSM design, datapath control, and modular hardware architecture**.

---

## Top-Level Module: `safe`

### Inputs
- `SW[9:0]` – Switch inputs for password and attempt entry  
- `KEY[0]` – Active-low reset  
- `KEY[1]` – Enter button (active-low)  
- `MAX10_CLK1_50` – 50 MHz system clock  

### Outputs
- `LEDR[9:0]` – Displays hint and FSM state bits  
- `HEX5–HEX0` – Displays lock status text  

---

## Functional Description

### Password and Attempt Storage
- Password and attempt are stored in 10-bit registers
- Controlled by FSM signals:
  - `savePW` – Save password
  - `saveAT` – Save attempt

### Matching Logic
```text
MATCH = (ATTEMPT == PASSWORD)
