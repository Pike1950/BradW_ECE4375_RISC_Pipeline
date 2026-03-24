`default_nettype none
`timescale 1ns / 1ps

module IF_SECT(
    input  logic [31:0] pc,           // Current program counter
    output logic [31:0] pc1,          // PC + 1
    output logic [31:0] ir            // Fetched instruction
);

assign pc1 = pc + 1;

Instruction_Mem IM0(.PC(pc1), .IR(ir));

endmodule
`default_nettype wire
