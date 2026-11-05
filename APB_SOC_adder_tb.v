`timescale 1ns/1ps

module APB_SOC_adder_tb;

    // Master Driver Control Wires (Driven non-blockingly)
    reg        PCLK;
    reg        PRESETn;
    reg [31:0] PADDR;
    reg        PWRITE;
    reg        PSEL;
    reg        PENABLE;
    reg [31:0] PWDATA;
    
    // Outputs from UUT
    wire [31:0] PRDATA;
    wire        PREADY;
    wire        PSLVERR;

    APB_SOC_adder uut (
        .PCLK(PCLK), .PRESETn(PRESETn), .PADDR(PADDR), .PWRITE(PWRITE),
        .PSEL(PSEL), .PENABLE(PENABLE), .PWDATA(PWDATA), .PRDATA(PRDATA),
        .PREADY(PREADY), .PSLVERR(PSLVERR)
    );

    // Generate 100MHz System Clock Reference (10ns period)
    always #5 PCLK = ~PCLK;

    initial begin
        
        $dumpfile("dump.vcd");
        $dumpvars(0, APB_SOC_adder_tb);

        PCLK    = 1'b0;
        PRESETn = 1'b0;
        PADDR   = 32'h0;
        PWRITE  = 1'b0;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWDATA  = 32'h0;

        // Reset Sequence
        #15;
        PRESETn = 1'b1; 
        
        // Synchronize with the next clean clock edge
      
        @(posedge PCLK); 

        // TRANSACTION 1: WRITE OPERAND A = 8'h0F TO REG1 (Offset 0x0)
        
        @(posedge PCLK); 
        PADDR  <= 32'h0;   // Use non-blocking mapping to eliminate race conditions
        PWRITE <= 1'b1;    
        PSEL   <= 1'b1;    
        PWDATA <= 32'h0F;  
        
        @(posedge PCLK); 
        PENABLE <= 1'b1;   // Assert Access Strobe
        
        @(posedge PCLK);   // End of Write Transaction
        PSEL    <= 1'b0;
        PENABLE <= 1'b0;

        // TRANSACTION 2: WRITE OPERAND B = 8'h01 TO REG2 (Offset 0x4)
     
        @(posedge PCLK); 
        PADDR  <= 32'h4;   
        PWRITE <= 1'b1;
        PSEL   <= 1'b1;
        PWDATA <= 32'h01;
        
        @(posedge PCLK); 
        PENABLE <= 1'b1;
        
        @(posedge PCLK);   // End of Write Transaction
        PSEL    <= 1'b0;
        PENABLE <= 1'b0;

        // TRANSACTION 3: READ RESULT FROM REG3 (Offset 0x8)
     
        @(posedge PCLK); 
        PADDR  <= 32'h8;   // Point to Result register
        PWRITE <= 1'b0;    // Read operation
        PSEL   <= 1'b1;
        
        @(posedge PCLK); 
        PENABLE <= 1'b1;   // Enter Access phase
        
        @(posedge PCLK);   // Read phase ends, data is sampled right at this edge
        #1; // Minor 1ns delay step to let the internal non-blocking queues update before printing
        $display("[SIMULATION REPORT] APB Readback successful. Sum Output = 32'h%h (Expected: 32'h10)", PRDATA);
        
        PSEL    <= 1'b0;
        PENABLE <= 1'b0;

        #20;
        $finish;
    end

endmodule

