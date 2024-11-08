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

    // Internal Components     
    reg [15:0] a = 16'b000000000_0011000;   // 24/2^7 = 0.1875 (16-bit)
    reg [15:0] b = 16'b000000000_1100100   // 8/2^7 = 0.0625 (16-bit)
    reg [15:0] c = 16'b111111111_1010000    // -.0078 V
    reg [15:0] d = 16'b000001000_0000000    // -.00078 V
    reg [15:0] threshold = 16'b000000001_1010000;  // 30 (16-bit)

    reg [15:0] u = 16'b0;
    reg [15:0] u_next = 16'b0, v_next = 16'b0;


    /* 
    Sequential logic 
          (update state at each clock cycle)
    */
    always @(posedge clk) begin

        // If reset cycle, reset state
        if (!reset_n) begin
            v <= 8'b0;
            u <= 16'b0;

        // If not a reset cycle, update state
        end else begin
            v <= v_next[7:0];
            u <= u_next;   
        end
    end


    /*
    Combinational logic 
        (Calculate values and spike detection)
    */
    always @(*) begin

        // Initialize next state
        v_next = {8'b0, v};
        u_next = u;

        if ({8'b0, v} >= threshold) begin
            v_next = c;            // Spike condition
            u_next = u + d;        // Reset u after spike

        end else begin
            v_next = (({8'b0, v} * {8'b0, v} * 16'd2) >> 7) + 
                        (({8'b0, v} * 16'd5) >> 7) - u + {8'b0, current};
            v_next = v_next[15:0];
            u_next = u + ((a * (b * {8'b0, v} - u)) >> 7); 
        end
    end
    
    // Check for spike and assign 0 or 1
    assign spike = ({8'b0, v} >= threshold) ? 1'b1 : 1'b0;

endmodule