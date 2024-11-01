/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_lif (
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
  assign uio_out [6:0] = 0;
  assign uio_oe  = 1;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

  // Instantiate the LIF module
  lif lif_1 (
    .current(ui_in),  // current input from parent module
    .clk(clk),        // clock driven by clock in parent module
    .reset_n(rst_n),  // reset driven by reset in parent module
    .state(uo_out),   // state output to parent module
    .spike(uio_out[7])    // most significant bit of state output to parent module
                            // this means rest are not used and must be assigned to 0
  );

  // Instantiate the LIF module
  // lif lif_1 (
  //   .current({uio_out[7], 7'b0000000}),  // concatenation of spike and 7'b0 to 8-bit input
  //   .clk(clk),        // clock driven by clock in parent module
  //   .reset_n(rst_n),  // reset driven by reset in parent module
  //   .state(uo_out),   // state output to parent module
  //   .spike(uio_out[7])    // most significant bit of state output to parent module
  //                           // this means rest are not used and must be assigned to 0
  // );

endmodule
