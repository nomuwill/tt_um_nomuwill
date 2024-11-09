`default_nettype none

module izh (

    // Inputs
    input wire [7:0] current,    // Input current (16-bit)
    input wire clk,
    input wire reset_n,

    // Outputs
    output wire spike,         // Spike output (1-bit)
    output reg [7:0] v       // State output
);

    // Scaling factor (2^7 = 128)
    parameter SCALE = 128;

    // Internal Constants (scaled values for fixed-point arithmetic)
    reg [15:0] a = 16'b000000000_0000010;  // 0.02 scaled by 128 = 2.56 -> 16'b000000000_0000010
    reg [15:0] b = 16'b000000000_0011101;  // 0.1 scaled by 128 = 12.8 -> 16'b000000000_0011101
    reg [15:0] c = 16'b000000000_0001101;  // 0.0125 scaled by 128 = 1.6 -> 16'b000000000_0001101
    reg [15:0] d = 16'b000000000_0000010;  // 0.02 scaled by 128 = 2.56 -> 16'b000000000_0000010

    reg [15:0] u = 16'b0;                  // Recovery variable
    reg [15:0] u_next = 16'b0, v_next = 16'b0;

    // Sequential logic: Update state at each clock cycle
    always @(posedge clk) begin
        if (!reset_n) begin
            v <= 8'b0;       // Reset voltage
            u <= 16'b0;       // Reset recovery variable
        end else begin
            v <= v_next[7:0];  // Update voltage state
            u <= u_next;        // Update recovery state
        end
    end

    // Combinational logic: Calculate values and detect spike
    always @(*) begin
        // Initialize next state values
        v_next = {8'b0, v}; // Keep lower 8 bits for voltage
        u_next = u;

        // Check for spike condition (voltage exceeding threshold)
        if ({8'b0, v} >= 16'b000000001_1010000) begin  // Threshold (30 scaled by 128)
            v_next = c;          // Reset voltage to constant c when spike occurs
            u_next = u + d;      // Update recovery variable
        end else begin
            // Update voltage: v_next = v^2 * 2 / 128 + v * 5 / 128 - u + current
            v_next = (({8'b0, v} * {8'b0, v} * 16'd2) >> 7) + 
                     (({8'b0, v} * 16'd5) >> 7) - u + {8'b0, current};

            // Update recovery variable: u_next = u + a * (b * v - u) / 128
            v_next = v_next[15:0]; // Keep the lower 16 bits of voltage
            u_next = u + ((a * (b * {8'b0, v} - u)) >> 7);
        end
    end
    
    // Check for spike and assign output
    assign spike = ({8'b0, v} >= 16'b000000001_1010000) ? 1'b1 : 1'b0;

endmodule