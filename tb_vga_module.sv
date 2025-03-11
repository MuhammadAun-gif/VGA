`timescale 1ns / 1ps

module vga_module_tb;

    logic clock_25;
    logic rst;
    logic [7:0] color_in;
    logic [9:0] next_x;
    logic [9:0] next_y;
    logic vga_hsync;
    logic vga_vsync;
    logic [7:0] vga_red;
    logic [7:0] vga_green;
    logic [7:0] vga_blue;
    logic vga_sync;
    logic vga_clk_n;
    logic vga_blank_n;

    // Instantiate the VGA module
    vga uut (
        .clock_25(clock_25),
        .rst(rst),
        .color_in(color_in),
        .next_x(next_x),
        .next_y(next_y),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .vga_sync(vga_sync),
        .vga_clk_n(vga_clk_n),
        .vga_blank_n(vga_blank_n)
    );

    // Clock generation (25 MHz)
    always #20 clock_25 = ~clock_25; // Period = 40ns -> 25MHz

    initial begin
        // Initialize inputs
        clock_25 = 0;
        rst = 1;
        color_in = 8'b11001100;
        next_x = 10'd0;
        next_y = 10'd0;

        // Apply reset
        #100;
        rst = 0;
        
        // Run simulation for a few horizontal and vertical cycles
        #200000;
        
        // Stop simulation
        $stop;
    end

    // Monitor key signals
    initial begin
        $display("Starting VGA Testbench");
        $monitor("Time=%0t | HSYNC=%b | VSYNC=%b | X=%d | Y=%d", 
                 $time, vga_hsync, vga_vsync, next_x, next_y);
    end

endmodule
