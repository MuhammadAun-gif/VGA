module vga_module (input logic clock_25, rst,
                    input [7:0] color_in,
                    output [9:0] next_x,
                    output [9:0] next_y,
                    output logic vga_hsync,
                    output logic vga_vsync,
                    output logic [7:0] vga_red,
                    output logic [7:0] vga_green,
                    output logic [7:0] vga_yellow,
                    output vga_sync,
                    output vga_clk_n,
                    output vga_blank_n);
    
    typedef enum logic[9:0] {H_active_state , H_front_state, H_sync_state, H_back_state} h_state_t;
    h_state_t h_state;

    typedef enum logic[1:0] {V_active_state, V_front_state, V_sync_state, V_back_state} v_state_t;
    v_state_t v_state;

    parameter [9:0] H_active = 10'd640;
    parameter [9:0] H_front = 10'd16;
    parameter [9:0] H_pusle = 10'd92;
    parameter [9:0] H_back = 10'd48;
    parameter [9:0] H-total = H_active + H_front + H_pusle + H_back;

    parameter [9:0] V_active = 10'd480;
    parameter [9:0] V_front = 10'd10;
    parameter [9:0] V_pusle = 10'd2;
    parameter [9:0] V_back = 10'd33;
    parameter [9:0] V-total = V_active + V_front + V_pusle + V_back;


    logic [9:0] h_counter = 10'd0; 
    logic [9:0] v_counter = 10'd0; 

    always_ff @(posedge clock_25) 
    begin
        if(rst)
        begin
            h_counter <= 10'd0;
            v_counter <= 10'd0;

            h_state <= H_active;
            v_state <= V_active;
        end
    end



endmodule