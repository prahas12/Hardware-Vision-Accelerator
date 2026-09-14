`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Open Source Hardware
// Engineer: 
// 
// Create Date: 2026
// Module Name: tb_image_processor
// Description: Testbench that uses File I/O to simulate an incoming camera stream.
//              Reads from input.hex, writes to output.hex.
//////////////////////////////////////////////////////////////////////////////////

module tb_image_processor;

    // Parameters
    parameter IMG_WIDTH  = 512;
    parameter IMG_HEIGHT = 512;
    parameter CLK_PERIOD = 10;
    
    // Signals
    logic clk;
    logic rst_n;
    logic valid_in;
    logic [7:0] pixel_in;
    
    logic [7:0] pixel_out;
    logic       valid_out;
    
    // File Handles
    int fd_in;
    int fd_out;
    int scan_file;
    
    // DUT Instantiation
    image_processor_top #(
        .IMG_WIDTH(IMG_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .pixel_in(pixel_in),
        .pixel_out(pixel_out),
        .valid_out(valid_out)
    );
    
    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Main Test Stimulus
    initial begin
        $display("Starting Image Processing Simulation...");
        
        // Open files (Using relative paths from Vivado's simulation directory)
        // Vivado runs simulation in: <project>/Vision_Project.sim/sim_1/behav/xsim/
        fd_in = $fopen("../../../../sim/input.hex", "r");
        if (fd_in == 0) begin
            $display("ERROR: Could not open input.hex. Did you run the python script?");
            $finish;
        end
        
        fd_out = $fopen("../../../../sim/output.hex", "w");
        if (fd_out == 0) begin
            $display("ERROR: Could not open output.hex for writing.");
            $finish;
        end
        
        // Initialize
        rst_n = 0;
        valid_in = 0;
        pixel_in = 0;
        
        // Wait 100ns and release reset
        #100;
        rst_n = 1;
        #20;
        
        // Stream image data
        $display("Streaming pixels...");
        while (!$feof(fd_in)) begin
            @(posedge clk);
            scan_file = $fscanf(fd_in, "%h\n", pixel_in);
            if (scan_file == 1) begin
                valid_in <= 1'b1;
            end else begin
                valid_in <= 1'b0;
            end
        end
        
        // Push some empty cycles to flush the pipeline
        valid_in <= 1'b0;
        repeat(10) @(posedge clk);
        
        $display("Simulation Complete! Closing files.");
        $fclose(fd_in);
        $fclose(fd_out);
        $finish;
    end
    
    // Output Monitor: Write processed pixels to output.hex
    always_ff @(posedge clk) begin
        if (valid_out) begin
            $fwrite(fd_out, "%02h\n", pixel_out);
        end
    end

endmodule
