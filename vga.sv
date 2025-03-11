module vga (        input clock_25, rst,
                    input [7:0] color_in,
                    output logic [9:0] next_x,
                    output logic [9:0] next_y,
                    output logic vga_hsync,
                    output logic vga_vsync,
                    output logic [7:0] vga_red,
                    output logic [7:0] vga_green,
                    output logic [7:0] vga_blue,
                    output logic vga_sync,
                    output logic vga_clk_n,
                    output logic vga_blank_n);
    
    typedef enum logic [1:0] {H_active_state , H_front_state, H_sync_state, H_back_state} h_state_t;
    h_state_t h_state;

    typedef enum logic[1:0] {V_active_state, V_front_state, V_sync_state, V_back_state} v_state_t;
    v_state_t v_state;

    parameter [9:0] H_active = 10'd640;
    parameter [9:0] H_front = 10'd16;
    parameter [9:0] H_pusle = 10'd92;
    parameter [9:0] H_back = 10'd48;
    parameter [9:0] H_total = H_active + H_front + H_pusle + H_back;

    parameter [9:0] V_active = 10'd480;
    parameter [9:0] V_front = 10'd10;
    parameter [9:0] V_pusle = 10'd2;
    parameter [9:0] V_back = 10'd33;
    parameter [9:0] V_total = V_active + V_front + V_pusle + V_back;


    logic [9:0] h_counter = 10'd0; 
    logic [9:0] v_counter = 10'd0;
    logic h_done = 1'b0;

    always_ff @(posedge clock_25) 
    begin
        if(rst)
        begin
            h_counter <= 10'd0;
            v_counter <= 10'd0;

            h_state <= H_active_state;
            v_state <= V_active_state;

            vga_hsync <= 1'b0;
            vga_vsync <= 1'b0;

            h_done <= 1'b0;
        end 
        else begin
            case (h_state)
                H_active_state :    begin
                                        if(h_counter == H_active - 1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_front_state;
                                            vga_hsync <= 1'b1;
                                            h_done <= 1'b0;
                                        end 
                                        else begin
                                            h_counter <= h_counter + 10'd1;
                                        end
                                    end
            
                H_front_state :     begin
                                        if(h_counter == H_front - 1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_sync_state;
                                            vga_hsync <= 1'b1;
                                            h_done <= 1'b0;
                                        end
                                        else begin
                                            h_counter <= h_counter + 1;
                                        end
                                    end

                H_sync_state :     begin
                                        if(h_counter == H_pusle - 1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_back_state;
                                            vga_hsync <= 1'b0;
                                            h_done <= 1'b0;
                                        end
                                        else begin
                                            h_counter <= h_counter + 1;
                                        end
                                    end             
            
                H_back_state :      begin
                                        if(h_counter == H_back - 1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_active_state;
                                            vga_hsync <= 1'b1;
                                            h_done <= 1'b1;
                                        end
                                        else begin
                                            h_counter <= h_counter + 1;
                                        end
                                    end

                default:            begin
                                        h_counter <= 10'd0;
                                        h_state <= H_active_state;
                                    end
            endcase 

            if (h_done == 1'b1)
            begin
            case(v_state)
                V_active_state :    begin
                                        if(v_counter == V_active - 1)
                                        begin
                                            v_counter <= 0;
                                            v_state <= V_front_state;
                                            vga_vsync <= 1'b1;
                                        end
                                        else begin
                                            v_counter <= v_counter + 1;
                                        end
                                    end

                V_front_state :     begin
                                        if(v_counter == V_front - 1)
                                        begin
                                            v_counter <= 0;
                                            v_state <= V_sync_state; 
                                            vga_vsync <= 1'b1;
                                        end
                                        else begin
                                            v_counter <= v_counter + 1;
                                        end
                                    end

                 V_sync_state :     begin
                                        if(v_counter == V_pusle - 1)
                                        begin
                                            v_counter <= 0;
                                            v_state <= V_back_state; 
                                            vga_vsync <= 1'b0;
                                        end
                                        else begin
                                            v_counter <= v_counter + 1;
                                        end
                                    end

                V_back_state :     begin
                                        if(v_counter == V_back - 1)
                                        begin
                                            v_counter <= 0;
                                            v_state <= V_active_state; 
                                            vga_vsync <= 1'b1;
                                        end
                                        else begin
                                            v_counter <= v_counter + 1;
                                        end
                                    end
            endcase
        

            if (h_state == H_active_state && v_state == V_active_state) begin
                    vga_red <= {color_in[7:5], 5'b00000};
                    vga_green <= {color_in[4:2], 5'b00000};
                    vga_blue  <= {color_in[1:0], 6'b000000}; 
                    next_x <= h_counter;
                    next_y <= v_counter;
                end else begin
                    vga_red <= 0;
                    vga_green <= 0;
                    vga_blue <= 0;
                    next_x <= 0;
                    next_y <= 0;
                end
            end
        end
    end

    assign vga_clk_n = clock_25;
    assign vga_sync = 1'b0;
    assign vga_blank_n = vga_hsync & vga_vsync;
endmodule