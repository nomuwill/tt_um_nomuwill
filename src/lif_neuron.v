

`default_nettype none

module test;
endmodule


// 'default_nettype none

// module lif (

//     // Define inputs 
//     input wire [7:0]    current,
//     input wire          clk,
//     input wire          reset_n,

//     // Define outputs
//     output reg [7:0]    state,
//     output wire         spike
// );

//     // Internal components
//     wire [7:0] next_state;
//     reg [7:0] threshold;

//     // // Flipflop
//     // always @(posedge clk) begin

//     //     // If reset_n is low, reset the state and threshold
//     //     if (!reset_n) begin
//     //         state <= 0;
//     //         threshold <= 200;

//     //     // Otherwise, update the state
//     //     end else begin
//     //         state <= next_state;
//     //     end
//     // end

//     // // Next state logic
//     //     // Shifting to right is the same as dividing by 2
//     // assign next_state = current + (spike ? 0 : (state >> 1));

//     // // Spiking logic
//     // assign spike = (state >= threshold);


// endmodule