module vga (        input clock_50, rst,
                    input [7:0] color_in,
                    output logic [9:0] next_x,
                    output logic [9:0] next_y,
                    output logic vga_hsync,
                    output logic vga_vsync,
                    output logic [7:0] vga_red,
                    output logic vga_sync,
                    output logic vga_clk_n,
                    output logic vga_blank_n);  

    logic clk_25;

    clk_divider clk_div_inst (
        .clk_50(clk_50),
        .rst(rst),
        .clk_25(clk_25) // Output of clock divider
    );
    
    typedef enum logic [1:0] {H_active_state , H_front_state, H_sync_state, H_back_state} h_state_t;
    h_state_t h_state;

    typedef enum logic[1:0] {V_active_state, V_front_state, V_sync_state, V_back_state} v_state_t;
    v_state_t v_state;

    parameter [9:0] H_active = 10'd640;
    parameter [9:0] H_front = 10'd16;
    parameter [9:0] H_pusle = 10'd96;
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
    logic High = 1'b1;
    logic Low = 1'b0;

    always_ff @(posedge clock_25) 
    begin
        if(~rst)
        begin
            h_counter <= 10'd0;
            v_counter <= 10'd0;

            h_state <= H_active_state;
            v_state <= V_active_state;

            vga_hsync <= High;
            vga_vsync <= High;

            vga_red   <= 8'd0;

            h_done <= Low;
        end 
        else begin
            case (h_state)
                H_active_state :    begin
                                        if(h_counter == H_active - 10'd1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_front_state;
                                            vga_hsync <= High;
                                            h_done <= Low;
                                        end 
                                        else begin
                                            h_counter <= h_counter + 10'd1;
                                            h_done <= Low;
                                        end
                                    end
            
                H_front_state :     begin
                                        if(h_counter == H_front - 10'd1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_sync_state;
                                            vga_hsync <= High;
                                            h_done <= Low;
                                        end
                                        else begin
                                            h_counter <= h_counter + 10'd1;
                                            h_done <= Low;
                                        end
                                    end

                H_sync_state :     begin
                                        if(h_counter == H_pusle - 10'd1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_back_state;
                                            vga_hsync <= Low;
                                            h_done <= Low;
                                        end
                                        else begin
                                            h_counter <= h_counter + 10'd1;
                                            h_done <= Low;
                                        end
                                    end             
            
                H_back_state :      begin
                                        if(h_counter == H_back - 10'd1)
                                        begin
                                            h_counter <= 10'd0;
                                            h_state <= H_active_state;
                                            vga_hsync <= High;
                                            h_done <= High;
                                        end
                                        else begin
                                            h_counter <= h_counter + 10'd1;
                                            h_done <= Low;
                                        end
                                    end

                default:            begin
                                        h_counter <= 10'd0;
                                        h_state <= H_active_state;
                                        h_done <= Low;
                                    end
            endcase 

            if (h_done == 1'b1)
            begin
            case(v_state)
                V_active_state :    begin
                                        if(v_counter == V_active - 10'd1)
                                        begin
                                            v_counter <= 10'd0;
                                            v_state <= V_front_state;
                                            vga_vsync <= High;
                                        end
                                        else begin
                                            v_counter <= v_counter + 10'd1;
                                        end
                                    end

                V_front_state :     begin
                                        if(v_counter == V_front - 10'd1)
                                        begin
                                            v_counter <= 10'd0;
                                            v_state <= V_sync_state; 
                                            vga_vsync <= High;
                                        end
                                        else begin
                                            v_counter <= v_counter + 10'd1;
                                        end
                                    end

                 V_sync_state :     begin
                                        if(v_counter == V_pusle - 10'd1)
                                        begin
                                            v_counter <= 10'd0;
                                            v_state <= V_back_state; 
                                            vga_vsync <= Low;
                                        end
                                        else begin
                                            v_counter <= v_counter + 10'd1;
                                        end
                                    end

                V_back_state :     begin
                                        if(v_counter == V_back - 10'd1)
                                        begin
                                            v_counter <= 10'd0;
                                            v_state <= V_active_state; 
                                            vga_vsync <= High;
                                        end
                                        else begin
                                            v_counter <= v_counter + 10'd1;
                                        end
                                    end
					default			:    begin
                                        v_counter <= 10'd0;
                                        v_state <= V_active_state;
                                   end
            endcase
            end

            next_x <= (h_state == H_active_state) ? h_counter : 10'd0;
            next_y <= (v_state == V_active_state) ? v_counter : 10'd0;

            // color_in[7:0] can either be hard_coded like 8'hFF
            // else it can be continuously changed using a always process
            // or color_in[7:0] can be assigned to push buttons on fpga 
            vga_red <= (h_state == H_active_state) ? ((v_state == V_active_state) ? color_in[7:0] : 8'd0) : 8'd0;

            // This is to continuously change the color

            /*always_ff @(posedge clock_25) 
            begin
                if (~rst)
                    vga_red   <= 8'd0;
                else 
                    vga_red <= (h_state == H_active_state) ? ((v_state == V_active_state) ? next_x[7:0] : 8'd0) : 8'd0;
            end*/

            
        end
    end

    assign vga_clk_n = clock_25;
    assign vga_sync = 1'b0;
    assign vga_blank_n = vga_hsync && vga_vsync;
endmodule