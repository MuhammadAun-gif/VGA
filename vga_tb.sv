`timescale 1ns/1ps

module vga_tb;
    reg clock_25;
    reg rst;
    reg [7:0] color_in;
    wire [9:0] next_x;
    wire [9:0] next_y;
    wire vga_hsync;
    wire vga_vsync;
    wire [7:0] vga_red;
    wire [7:0] vga_green;
    wire [7:0] vga_blue;
    wire vga_sync;
    wire vga_clk_n;
    wire vga_blank_n;

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

    // Clock generation
    always #20 clock_25 = ~clock_25; // 25MHz clock (T = 40ns)

    initial begin
        // Initialize signals
        clock_25 = 0;
        rst = 0;
        color_in = 8'b11100100; // Some random color

        // Apply reset
        #100;
        rst = 1;
        
        // Run simulation for a few milliseconds to observe the output
        #500000;
        $stop;
    end

    // Monitor signals
    initial begin
       // $monitor("Time=%0t, next_x=%d, next_y=%d, HSYNC=%b, VSYNC=%b, R=%d, G=%d, B=%d", 
                 //$time, next_x, next_y, vga_hsync, vga_vsync, vga_red, vga_green, vga_blue);
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule