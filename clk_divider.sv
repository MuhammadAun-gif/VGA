module clk_divider(
    input logic clk_50, rst,
    output logic clk_25
);

    typedef enum logic {Low, High} statetype;
    statetype state, nextstate;

    // Sequential logic for state transition
    always_ff @(posedge clk_50 or posedge rst) begin
        if (rst)
            state <= Low;
        else
            state <= nextstate;
    end

    // Combinational logic for next state
    always_comb begin
        case (state)
            Low:   nextstate = High;
            High:  nextstate = Low;
            default: nextstate = Low;
        endcase
    end

    // Sequential logic for clk_25
    always_ff @(posedge clk_50 or posedge rst) begin
        if (rst)
            clk_25 <= 0;  // Reset output
        else if (state == Low)
            clk_25 <= 0;
        else
            clk_25 <= 1;
    end

endmodule
