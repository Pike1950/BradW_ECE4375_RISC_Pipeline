`timescale 1ns / 1ps

module EX_SECT(
    input [31:0]  a, b, pc2,    // A/B operands from DOF, PC+2 for branch calc
    input [4:0]   sh, fs,       // Shift amount and function select
    input         clk, rst, mw, // Clock, reset, memory write
    output [31:0] f,            // ALU result
    output [31:0] data_out,     // Memory read data
    output [31:0] bra,          // Branch address
    output [31:0] raa,          // Register A address (for JMR)
    output        vxorn,        // V XOR N status
    output        z             // Zero flag
);

wire C, N, V; // ALU produces these internally; only vxorn and z leave this stage

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
