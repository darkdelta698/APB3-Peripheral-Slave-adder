AMBA APB3 Peripheral Slave Wrapper for 8-Bit Adder Core

A robust, fully synthesis-ready Verilog implementation of an 8-bit core arithmetic adder integrated into an ARM AMBA APB3 (Advanced Peripheral Bus) slave wrapper. This repository demonstrates standard SoC peripheral interconnect design, memory-mapped register addressing, wait-state protocol compliance, and APB protocol error generation (PSLVERR).

📌 Project Overview

This design decouples bus management logic from arithmetic core logic by wrapping a baseline 8-bit adder IP inside an APB protocol bridge.

The wrapper handles bus handshaking, address decoding, zero-extension of output data, and error assertion, allowing the underlying adder core to operate seamlessly as a memory-mapped SoC peripheral.

🗺️ Register Map & Address Offset Definitions

All registers are 32 bits wide on the APB data bus. Address decoding utilizes the lowest nibble (PADDR[3:0]) to route control and data signals internally:

Offset 0x00 (REG1) — Read / Write

Hardware mapping: reg1[7:0]

Description: Holds Operand A for the 8-bit adder core.

Offset 0x04 (REG2) — Read / Write

Hardware mapping: reg2[7:0]

Description: Holds Operand B for the 8-bit adder core.

Offset 0x08 (REG3) — Read-Only

Hardware mapping: {23'b0, w_sum}

Description: Stores the 9-bit arithmetic sum result, zero-extended to 32 bits. Attempting to write to this address will assert PSLVERR.

Offset 0x0C (REG4) — Read / Write

Hardware mapping: reg4[31:0]

Description: Scratchpad register reserved for system testing and general data staging.

⚡ Key Architectural Features

Zero Wait-State Transfer: PREADY is driven permanently high (1'b1), enabling the peripheral to process read and write transactions in standard 2-clock cycles (Setup Phase followed by Access Phase).

Protocol Error Generation (PSLVERR):

Automatically raised high if a write access targets the read-only Result Register (0x08).

Automatically raised high when accessing invalid or out-of-bounds register offsets.

Data Formatting: The core adder outputs a 9-bit sum (w_sum), which is padded with 23 leading zeros during read operations to align with standard 32-bit APB data buses.

📁 Repository Files

adder.v: The baseline 8-bit combinational adder module.

APB_SOC_adder.v: The APB3 peripheral wrapper, address decoder, and memory-mapped register bank.

APB_SOC_adder_tb.v: The simulation testbench verifying write, readback, and error logic.

README.md: Project documentation and usage guide.

🛠️ Simulation & Verification
xilings vivado
