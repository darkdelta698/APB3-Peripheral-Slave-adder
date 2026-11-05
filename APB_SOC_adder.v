`timescale 1ns/1ps



// APB SLAVE WRAPPER (The Standard Interface)

module APB_SOC_adder(
  
    // Core APB System Interface Ports
  
    input  wire        PCLK,       // Bus Clock
    input  wire        PRESETn,    // Active-LOW Bus Reset
    
    // APB Master Control Command Bus
    input  wire [31:0] PADDR,      // 32-bit Address Bus
    input  wire        PWRITE,     // 1 = Write, 0 = Read
    input  wire        PSEL,       // Peripheral Selection Line
    input  wire        PENABLE,    // Strobe / Access Phase Enable
    input  wire [31:0] PWDATA,     // Write Data Payload Bus
    
    // APB Response Output Bus back to Master
  
    output reg  [31:0] PRDATA,     // Read Data Return Bus
    output wire        PREADY,     // Slave Ready Status Handshake
    output reg         PSLVERR     // Slave Protocol Error Flag
);
  
    // Internal Wrapper Peripheral Storage Registers
  
    reg [31:0] reg1; // Offset 0x00: Operand A
    reg [31:0] reg2; // Offset 0x04: Operand B
    reg [31:0] reg4; // Offset 0x0C: Scratchpad Register
    
    // Interconnect wire between Core IP output and Wrapper Mux
  
    wire [8:0] w_sum;
  
    // Standardized Memory Map Registers Offset Addressing
  
    parameter ADDR_REG1 = 4'h0,  // Operand A
              ADDR_REG2 = 4'h4,  // Operand B
              ADDR_REG3 = 4'h8,  // Read-Only Result Zone
              ADDR_REG4 = 4'hC;  // Scratchpad
  
    // APB3 Handshake Engine: This slave is always ready in 2 cycles (zero wait-states)
    assign PREADY = 1'b1; 
  
    // APB REGISTER WRITE INTERFACE LOGIC 
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            reg1    <= 32'h0;
            reg2    <= 32'h0;
            reg4    <= 32'h0;
            PSLVERR <= 1'b0;
        end  
        else begin
            PSLVERR <= 1'b0; // Default clear error flag

            // APB Write must strictly occur only when PSEL=1, PENABLE=1, and PWRITE=1
            if (PSEL && PWRITE && PENABLE) begin
                case (PADDR[3:0]) // Decoding the lowest nibble for offset mapping
                    ADDR_REG1: reg1 <= PWDATA;
                    ADDR_REG2: reg2 <= PWDATA;
                    ADDR_REG4: reg4 <= PWDATA;
                    ADDR_REG3: PSLVERR <= 1'b1; // Error: Attempted to write to a read-only result zone
                    default:   PSLVERR <= 1'b1; // Error: Address out-of-bounds
                endcase
            end
        end
    end

    // APB REGISTER READ INTERFACE LOGIC 
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= 32'h0;
        end  
        else begin
            // APB Read occurs during the active selection window when PWRITE=0
            if (PSEL && !PWRITE) begin
                case (PADDR[3:0])
                    ADDR_REG1: PRDATA <= reg1;
                    ADDR_REG2: PRDATA <= reg2;
                    // Zero-extend the 9-bit core sum to match 32-bit data lines
                    ADDR_REG3: PRDATA <= {23'b0, w_sum}; 
                    ADDR_REG4: PRDATA <= reg4;
                    default: begin
                        PRDATA  <= 32'hDEADBEEF; // Error feedback signature
                        // Note: PSLVERR will be set high in the synchronous block above
                    end
                endcase
            end
            else begin
                PRDATA <= 32'h0; // Maintain zero baseline if not targeted
            end
        end
    end
  
    // CORE IP HARDWARE INSTANTIATION
    adder inst1 (
        .a(reg1[7:0]),
        .b(reg2[7:0]),
        .sum(w_sum)
    );
  
endmodule

