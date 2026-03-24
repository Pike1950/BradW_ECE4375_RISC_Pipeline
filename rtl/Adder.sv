`default_nettype none
`timescale 1ns / 1ps

module Adder(
    input  logic [31:0] B, PC_2,
    output logic [31:0] BrA
);

always_comb begin
    BrA = B + PC_2;
end

endmodule
`default_nettype wire
