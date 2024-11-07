/* 
Izhikevich model 

    System:
        v' = 0.04*v^2 + 5*v + 140 - u + I
        u' = a*(b*v - u)
    Aux Reset:
        if v >= 30 then {v = c; u = u + d}

    Where 
        v = membrane potential
        u = membrane recovery (Na and K, neg feedback to v)
        a = time scale of the recovery variable u (small = slow recovery)
        b = sensitivity of the recovery variable u to  v
        c = after spike reset value of v
        d = after spike reset value of u
        I = input current

        ** Constants are chosen by fitting dynamics 
            to cortical nueron data, see refrerence below.

    Using Q9.7 because we need over 140 for the v' equation
        - 16-bit signed fixed point
            - Ex: 16'b000000000_0011000 = 24/2^7 = 0.1875
            - Shift of >>7 is equivalent to dividing by 2^7

    References:`
    https://www.izhikevich.org/publications/spikes.pdf

*/



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
    reg [7:0] a = 8'b00011000;   // 24/2^7 = 0.1875
    reg [7:0] b = 8'b00001000;   // 8/2^7 = 0.0625
    reg [7:0] c = 8'b00111100;   // 30/2^7 = 0.234375
    reg [7:0] d = 8'b00000100;   // 1/2^7 = 0.0078125
    reg [7:0] threshold = 8'b11101000;  // 30 

    reg [7:0] u;
    reg [7:0] u_next, v_next;


    /* 
    Sequential logic 
          (update state at each clock cycle)
    */
    always @(posedge clk) begin

        // If reset cycle, reset state
        if (!reset_n) begin
            v <= 8'b00000000;
            u <= 8'b00000000;

        // If not a reset cycle, update state
        end else begin
            v <= v_next;
            u <= u_next;   
        end
    end


    /*
    Combinational logic 
        (Calculate values and spike detection)
    */
    always @(*) begin
        if (v >= threshold) begin
            v_next = c;            // Spike condition
            u_next = u + d;        // Reset u after spike
        end else begin
            v_next = v + (((8'd2 * v * v) >> 7) + (8'd5 * v) - u + current);
            u_next = u + ((a * (b * v - u)) >> 7);
        end
    end
    
    // Check for spike and assign 0 or 1
    assign spike = (v >= threshold) ? 1'b1 : 1'b0;

endmodule
