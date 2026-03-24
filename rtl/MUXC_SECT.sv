`default_nettype none
`timescale 1ns / 1ps

module MUXC_SECT(
    input  logic [1:0]  bs,           // Branch select from EX
    input  logic        ps,           // Polarity select from EX
    input  logic        z,            // Zero flag from EX
    input  logic [31:0] pc1,          // PC+1 from IF (default next PC)
    input  logic [31:0] bra,          // Branch address from EX
    input  logic [31:0] raa,          // Register A address from EX
    output logic [31:0] pc_next       // Next PC value
);

logic and_gate, or_gate, xor_gate;

// Combinational circuits that drive select for MUX C
assign xor_gate = ps ^ z;
assign or_gate  = bs[1] | xor_gate;
assign and_gate = bs[0] & or_gate;

logic [1:0] mc;
assign mc[1] = bs[1];
assign mc[0] = and_gate;

MUX_C M0(
    .BrA(bra), .PC_1(pc1), .RAA(raa),
    .MC(mc), .PC(pc_next)
);

endmodule
`default_nettype wire
