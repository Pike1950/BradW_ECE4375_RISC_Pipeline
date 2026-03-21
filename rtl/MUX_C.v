`timescale 1ns / 1ps

module MUX_C(   input [31:0] BrA, RAA, PC_1, // BrA, RAA come from execute, PC+1 comes from instruction fetch section, one of these goes to PC output
                input [1:0] MC, // from combinational circuits to the right of MUX C in Fig. 10-15 before the instruction fetch section
                output reg [31:0] PC // sets the newest value of program counter to the top module
                );

always_comb begin
        case(MC)
            0: PC = PC_1; // pass incremented PC
            1,3: PC = BrA; // set PC to branch address
            2: PC = RAA;
            default: PC = PC_1;
        endcase
end

endmodule
