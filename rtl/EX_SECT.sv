`default_nettype none
`timescale 1ns / 1ps

module EX_SECT(
    input  logic [31:0] a, b, pc2,    // A/B operands from DOF, PC+2 for branch calc
    input  logic [4:0]  sh, fs,       // Shift amount and function select
    input  logic        clk, rst, mw, // Clock, reset, memory write
    output logic [31:0] f,            // ALU result
    output logic [31:0] data_out,     // Memory read data
    output logic [31:0] bra,          // Branch address
    output logic [31:0] raa,          // Register A address (for JMR)
    output logic        vxorn,        // V XOR N status
    output logic        z             // Zero flag
);

logic C, N, V;

Adder A0(
    .B(b), .PC_2(pc2),
    .BrA(bra)
);

ALU A1(
    .A(a), .B(b), .SH(sh), .FS(fs),
    .Z(z), .F(f), .V(V), .C(C), .N(N)
);

Data_mem D0(
    .Address(a), .Data_in(b),
    .clk(clk), .rst(rst), .MW(mw),
    .Data_out(data_out)
);

assign vxorn = V ^ N;
assign raa = a;

endmodule
`default_nettype wire
