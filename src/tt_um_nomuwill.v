/*
 * Copyright (c) 2024 Your Name
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

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out [6:0] = 7'b0;
  assign uio_oe  = 8'b10000000;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

  // Internal signal
  wire [7:0] v;  // Still declaring as 16 bits

  // Instantiate the LIF module
  izh izh_1(
    .current(ui_in),  // current input from parent module, concatenated to 16 bits
    .clk(clk),        // clock driven by clock in parent module
    .reset_n(rst_n),  // reset driven by reset in parent module
    .spike(uio_out[7]),    // most significant bit of state output to parent module
    .v(v)   // Use lower 8 bits of v for state output
  );

  assign uo_out = v;  // Assign lower 8 bits of v to output

endmodule
