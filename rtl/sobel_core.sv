`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Open Source Hardware
// Engineer: 
// 
// Create Date: 2026
// Module Name: sobel_core
// Description: Computes the 3x3 Sobel Convolution (Gx and Gy) and gradient magnitude.
//              Fully pipelined datapath.
//////////////////////////////////////////////////////////////////////////////////

module sobel_core (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    
    // 3x3 Window Inputs (p_row_col)
    input  logic [7:0] p00, p01, p02, // Top row
    input  logic [7:0] p10, p12,      // Middle row (p11 unused by Sobel)
    input  logic [7:0] p20, p21, p22, // Bottom row
    
    output logic [7:0] pixel_out,
    output logic       valid_out
);

    // ==========================================
    // Pipeline Stage 1: Calculate Gx and Gy
    // ==========================================
    // Sobel X kernel:
    // [-1  0  1]
    // [-2  0  2]
    // [-1  0  1]
    //
    // Sobel Y kernel:
    // [ 1  2  1]
    // [ 0  0  0]
    // [-1 -2 -1]
    
    logic signed [11:0] gx, gy;
    logic valid_p1;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            gx <= '0;
            gy <= '0;
            valid_p1 <= 1'b0;
        end else begin
            valid_p1 <= valid_in;
            if (valid_in) begin
                gx <= $signed({4'b0, p02}) + $signed({3'b0, p12, 1'b0}) + $signed({4'b0, p22}) - 
                      $signed({4'b0, p00}) - $signed({3'b0, p10, 1'b0}) - $signed({4'b0, p20});
                      
                gy <= $signed({4'b0, p00}) + $signed({3'b0, p01, 1'b0}) + $signed({4'b0, p02}) - 
                      $signed({4'b0, p20}) - $signed({3'b0, p21, 1'b0}) - $signed({4'b0, p22});
            end
        end
    end

    // ==========================================
    // Pipeline Stage 2: Absolute values (|Gx| + |Gy|)
    // ==========================================
    logic [11:0] abs_gx, abs_gy;
    logic valid_p2;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            abs_gx <= '0;
            abs_gy <= '0;
            valid_p2 <= 1'b0;
        end else begin
            valid_p2 <= valid_p1;
            if (valid_p1) begin
                abs_gx <= (gx[11]) ? -gx : gx;
                abs_gy <= (gy[11]) ? -gy : gy;
            end
        end
    end
    
    // ==========================================
    // Pipeline Stage 3: Magnitude Sum & Clamp
    // ==========================================
    logic [12:0] sum;
    assign sum = abs_gx + abs_gy;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pixel_out <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_p2;
            if (valid_p2) begin
                // Clamp to 255 (8-bit max) to prevent overflow artifacts
                pixel_out <= (sum > 13'd255) ? 8'd255 : sum[7:0];
            end
        end
    end

endmodule
