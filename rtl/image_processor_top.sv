`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Open Source Hardware
// Engineer: 
// 
// Create Date: 2026
// Module Name: image_processor_top
// Description: Top level wrapper for the Image Processing pipeline.
//              Combines the Line Buffers (Memory) with the Sobel Core (DSP).
//////////////////////////////////////////////////////////////////////////////////

module image_processor_top #(
    parameter IMG_WIDTH = 512
)(
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    input  logic [7:0] pixel_in,
    
    output logic [7:0] pixel_out,
    output logic       valid_out
);

    // Wires to connect Line Buffer to Shift Registers
    logic [7:0] tap0, tap1, tap2;
    
    // Instantiate Line Buffer
    line_buffer #(
        .IMG_WIDTH(IMG_WIDTH)
    ) u_line_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .pixel_in(pixel_in),
        .tap0_out(tap0),
        .tap1_out(tap1),
        .tap2_out(tap2)
    );
    
    // Shift registers to form the 3x3 window
    logic [7:0] p00, p01, p02;
    logic [7:0] p10, p11, p12;
    logic [7:0] p20, p21, p22;
    
    // Delay valid signal by 2 cycles to match Line buffer's 2-cycle BRAM read latency
    logic valid_d1, valid_d2;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            valid_d1 <= 1'b0;
            valid_d2 <= 1'b0;
            p00 <= '0; p01 <= '0; p02 <= '0;
            p10 <= '0; p11 <= '0; p12 <= '0;
            p20 <= '0; p21 <= '0; p22 <= '0;
        end else begin
            valid_d1 <= valid_in;
            valid_d2 <= valid_d1;
            if (valid_d2) begin
                // Shift in the new column from the line buffer
                // Top row (Oldest row, tap2)
                p00 <= p01; p01 <= p02; p02 <= tap2;
                // Middle row (tap1)
                p10 <= p11; p11 <= p12; p12 <= tap1;
                // Bottom row (Newest row, tap0)
                p20 <= p21; p21 <= p22; p22 <= tap0;
            end
        end
    end
    
    // Delay valid_d2 by 1 more cycle for the shift register propagation
    logic valid_window;
    always_ff @(posedge clk) begin
        if (!rst_n) valid_window <= 1'b0;
        else        valid_window <= valid_d2;
    end

    // Instantiate Sobel Math Core
    sobel_core u_sobel_core (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_window),
        
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        
        .pixel_out(pixel_out),
        .valid_out(valid_out)
    );

endmodule
