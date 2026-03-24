`default_nettype none
`timescale 1ns / 1ps

module MUX_C(
    input  logic [31:0] BrA, RAA, PC_1,
    input  logic [1:0]  MC,
    output logic [31:0] PC
);

always_comb begin
    case(MC)
        2'd0:    PC = PC_1;    // Pass incremented PC
        2'd1:    PC = BrA;     // Branch address (conditional branch taken)
        2'd2:    PC = RAA;     // Register address (JMR)
        2'd3:    PC = BrA;     // Branch address (unconditional jump)
        default: PC = PC_1;
    endcase
end

endmodule
`default_nettype wire
