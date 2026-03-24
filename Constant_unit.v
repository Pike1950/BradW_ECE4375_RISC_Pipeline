`timescale 1ns / 1ps

module Constant_unit(
    input [14:0] IM,
    input CS,
    output [31:0] CONST_DATA
    );

assign CONST_DATA = (CS)? {{17{IM[14]}},IM} : {17'b0,IM}; // If 1, sign bit is extended 17 times,
                                                          // otherwise fill the 17 bits with zeros

endmodule
