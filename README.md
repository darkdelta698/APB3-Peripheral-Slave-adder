AMBA APB3 Peripheral Slave Wrapper for 8-Bit Adder Core

A robust, fully synthesis-ready Verilog implementation of an 8-bit core arithmetic adder integrated into an ARM AMBA APB3 (Advanced Peripheral Bus) slave wrapper. This repository demonstrates standard SoC peripheral interconnect design, memory-mapped register addressing, wait-state protocol compliance, and APB protocol error generation (PSLVERR).

📌 Architecture Overview

The system architecture decouples bus management logic from the arithmetic core logic by wrapping the baseline adder IP inside an APB protocol bridge.

       +--------------------------------------------------------------+
       | APB_SOC_adder (APB Slave Wrapper)                            |
       |                                                              |
       |   +------------------+         +-------------------------+   |
PADDR  |---> Decoding Logic   |         | Registers               |   |
PWDATA |---> & Write Control  |-------->| - reg1 (0x0): Operand A |---> | adder (Core IP)
PWRITE |---> Logic            |         | - reg2 (0x4): Operand B |---> |  a + b = sum
PSEL   |--->                  |         | - reg4 (0xC): Scratch   |   |     |
PENABLE|--->                  |         +-------------------------+   |     |
       |                      |                      |                |     |
       |   +------------------+                      v                |     |
PRDATA |<---| Read Mux Logic  |<---------------------+----------------|<----+
PREADY |<---| (Zero-Extended) |                                       |  (9-bit w_sum)
PSLVERR|<---| Error Logic     |                                       |
       +--------------------------------------------------------------+


🗺️ Memory Map & Register Description

All registers are 32 bits wide on the APB data bus. Address decoding utilizes the lowest nibble PADDR[3:0] to map internal registers.

+----------------+---------------+-------------+------------------+-----------------------------------------------------------------------+
| Address Offset | Register Name | Access Type | Hardware Mapping | Description                                                           |
+----------------+---------------+-------------+------------------+-----------------------------------------------------------------------+
| 0x00           | REG1          | Read/Write  | reg1[7:0]        | Operand A input to the adder core.                                    |
| 0x04           | REG2          | Read/Write  | reg2[7:0]        | Operand B input to the adder core.                                    |
| 0x08           | REG3          | Read-Only   | {23'b0, w_sum}   | Adder Sum Output (9-bit result, zero-extended). Writes trigger PSLVERR.|
| 0x0C           | REG4          | Read/Write  | reg4[31:0]       | Scratchpad Register for system testing/data staging.                  |
+----------------+---------------+-------------+------------------+-----------------------------------------------------------------------+


⚡ Protocol Features

Zero Wait-State Transfer: PREADY is tied to 1'b1, indicating the peripheral completes read and write requests in standard 2-clock cycles (Setup Phase + Access Phase).

Error Handling (PSLVERR):

Asserted high if a write transaction is attempted targeting the read-only Result Register (0x08).

Asserted high when accessing out-of-bounds register offsets (default address case).

Data Formatting: The 9-bit sum output from the arithmetic core is padded with 23 leading zeros to conform to 32-bit APB read operations.

📁 Repository Structure

.
├── adder.v            # Baseline 8-bit combinational adder module
├── APB_SOC_adder.v    # APB3 peripheral wrapper, decoder, and registers
├── APB_SOC_adder_tb.v # Testbench simulating APB write, read, and verification
└── README.md          # Project documentation


🛠️ Simulation & Verification
xilinx vivado
