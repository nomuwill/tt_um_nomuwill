`default_nettype none

module izh (
    input wire [7:0] current,    // Input current (8-bit)
    input wire clk,
    input wire reset_n,

    output wire spike,         // Spike output (1-bit)
    output reg [7:0] v        // State output (voltage)
);

    // Internal Constants (scaled values for fixed-point arithmetic)
    reg [15:0] a = 16'b000000000_0000010;  // 0.02 * 128 = 2.56
    reg [15:0] b = 16'b000000000_0011000;  // 0.15 * 128 = 19.2
    reg [15:0] c = 16'b111110000_1110000;  // -65 * 128 = -8320
    reg [15:0] d = 16'b000010100_0000000;  // 10 * 128 = 1280
    reg [15:0] thr = 16'b000000001_1100000;  // 30 * 128 = 3840

    // Internal Variables
    reg [15:0] u = 16'b0;                
    reg [15:0] u_next = 16'b0;
    reg [15:0] v_next = 16'b0;

    // Sequential logic (on clock)
    always @(posedge clk) begin

        // If reset is active, reset the state
        if (!reset_n) begin
            v <= 8'b0;       // Reset voltage
            u <= 16'b0;      // Reset recovery variable

        // Otherwise, update the state
        end else begin
            v <= v_next[7:0];  // Update voltage state
            u <= u_next;        // Update recovery state
        end
    end

    // Combinational logic (no clock)
    always @(*) begin
        v_next = {8'b0, v}; // Keep lower 8 bits for voltage
        u_next = u;

        // Check for spike condition
        if ({8'b0, v} >= thr) begin  
            v_next = c;          // Reset voltage to c
            u_next = u + d;      // Reset recovery variable

        // Update Izhikevich equation
        end else begin

            // Update voltage
            v_next = (({8'b0, v} * {8'b0, v} * 16'd2) >> 7) + 
                     (({8'b0, v} * 16'd5) >> 7) - u + ({8'b0, current} << 4);
            
            // Update recovery variable (decay of u)
            u_next = u + ((a * (b * {8'b0, v} - u)) >> 7);
        end
    end
    
    // Assign spike output 
    assign spike = ({8'b0, v} >= thr) ? 1'b1 : 1'b0;

endmodule