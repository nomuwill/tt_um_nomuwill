/*
 * Copyright (c) 2024 Noah Williams
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_nomuwill (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. `If not used, assign to 0.
  assign uio_out [5:0] = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0, uio_in};

  // Internal signal
  wire [7:0] v1; 
  wire spike1;
  wire [7:0] v2; 
  wire spike2;

  // Instantiate the Izhikevich neuron
  izh izh_1(
    .current(ui_in),  // current input from parent module, concatenated to 16 bits
    .clk(clk),        // clock driven by clock in parent module
    .reset_n(rst_n),  // reset driven by reset in parent module
    .spike(spike1),    // most significant bit of state output to parent module
    .v(v1)   // Use lower 8 bits of v for state output
  );

  // Instantiate the Izhikevich neuron again!
  izh izh_2(
    .current(v1),   // Route the output of the first neuron to the second neuron
    .clk(clk),        
    .reset_n(rst_n),  
    .spike(spike2),    
    .v(v2)  
  );

  assign uo_out = v1; 
  assign uio_oe = v2;
  assign uio_out[7] = spike1;
  assign uio_out[6] = spike2;

endmodule