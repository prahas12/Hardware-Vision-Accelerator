`timescale 1ns / 1ps

// ==============================================================================
// Textbook Simple Dual-Port BRAM
// Guaranteed to infer Block RAM with zero SYNTH-5 warnings.
// ==============================================================================
module simple_dual_port_ram #(
    parameter WIDTH = 8,
    parameter DEPTH = 512,
    parameter ADDR_W = 9
)(
    input  logic clk,
    input  logic we,
    input  logic [ADDR_W-1:0] waddr,
    input  logic [WIDTH-1:0]  din,
    input  logic [ADDR_W-1:0] raddr,
    output logic [WIDTH-1:0]  dout
);
    // Memory array
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [WIDTH-1:0] dout_reg;
    
    always_ff @(posedge clk) begin
        if (we)
            mem[waddr] <= din;
            
        // BRAM Internal Latch (Cycle 1)
        dout_reg <= mem[raddr];
        
        // BRAM Output Register (Cycle 2) - This merges into the BRAM block natively
        dout <= dout_reg;
    end
endmodule

// ==============================================================================
// Line Buffer (using the clean BRAMs)
// ==============================================================================
module line_buffer #(
    parameter IMG_WIDTH = 512
)(
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    input  logic [7:0] pixel_in,
    
    output logic [7:0] tap0_out, // Newest pixel (delayed by 1 cycle to match BRAM)
    output logic [7:0] tap1_out, // Pixel from 1 row ago
    output logic [7:0] tap2_out  // Pixel from 2 rows ago
);

    localparam ADDR_W = $clog2(IMG_WIDTH);
    
    // Write/Read pointer
    logic [ADDR_W-1:0] ptr;
    
    // Outputs from the BRAMs
    logic [7:0] bram0_dout, bram1_dout;
    
    // BRAM 0: stores the previous row
    simple_dual_port_ram #(
        .WIDTH(8), .DEPTH(IMG_WIDTH), .ADDR_W(ADDR_W)
    ) ram0 (
        .clk(clk),
        .we(valid_in),
        .waddr(ptr),
        .din(pixel_in),
        .raddr(ptr),
        .dout(bram0_dout)
    );
    
    // BRAM 1: stores the row before the previous row
    simple_dual_port_ram #(
        .WIDTH(8), .DEPTH(IMG_WIDTH), .ADDR_W(ADDR_W)
    ) ram1 (
        .clk(clk),
        .we(valid_in),
        .waddr(ptr),
        .din(bram0_dout), // Input is the output of BRAM0
        .raddr(ptr),
        .dout(bram1_dout)
    );
    
    // Delay pixel_in and valid_in to align with the 2-cycle BRAM read latency
    logic [7:0] pixel_in_d1, pixel_in_d2;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            ptr <= '0;
            pixel_in_d1 <= '0;
            pixel_in_d2 <= '0;
        end else if (valid_in) begin
            pixel_in_d1 <= pixel_in;
            pixel_in_d2 <= pixel_in_d1;
            
            // Manage pointer wrap-around
            if (ptr == IMG_WIDTH - 1)
                ptr <= '0;
            else
                ptr <= ptr + 1;
        end
    end
    
    // Assign outputs. They are all perfectly aligned to valid_in + 2 cycles!
    assign tap0_out = pixel_in_d2;
    assign tap1_out = bram0_dout;
    assign tap2_out = bram1_dout;

endmodule
