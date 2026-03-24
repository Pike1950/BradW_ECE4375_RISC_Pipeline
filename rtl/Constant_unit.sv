`default_nettype none
`timescale 1ns / 1ps

module Constant_unit(
    input  logic [14:0] IM,
    input  logic        CS,
    output logic [31:0] CONST_DATA
);

// If CS=1, sign-extend the 15-bit immediate; otherwise zero-extend
assign CONST_DATA = CS ? {{17{IM[14]}}, IM} : {17'b0, IM};

endmodule
`default_nettype wire
