`timescale 1ns / 1ps

module Instruction_Mem( input [31:0] PC,
                        output reg [31:0] IR
                        );
`include "OPCODES.INC";
`include "REGISTERS.INC";

reg [6:0] opcode = 0; // values come from Fig.10-13 RISC CPU Instruction Formats
reg [31:0] M [1025];
integer i;

initial begin

    for(i = 0; i < 100; i = i + 1) begin
        M[i] = 0; // NOP
    end


    //         7-bit | 5-bit|5-bit| 5-bit + 10-bit |
    //        OPCODE | DEST | SA  | TARGET JUMP    | 15-bit
    //        OPCODE | DEST | SA  | IMMEDIATE      | 15-bit
    //        OPCODE | DEST | SA  | SB  | JUNK     | 5-bit, 10-bit
    //
    // Branch offset formula (per pipeline timing):
    //   offset = TargetAddr - BranchAddr - 1
    //   (BrA = pc2_ex + offset; fetch = M[BrA + 1] = M[TargetAddr])
    //
    // Branch delay: BZ/BNZ resolve in EX (2 cycles after fetch).
    // The 2 instructions after a branch always execute regardless of
    // whether the branch is taken. These slots must contain NOPs.

    // Setting 1st number = 3
    // 00000000000000000000000000000011
    M[0]    = {ADI,    R1,     R0,     15'b000000000000000};      // Add first 15 bits
    M[1]    = {LSL,    R2,     R1,     15'd15};                   // Shift left 15
    M[2]    = {ADI,    R1,     R2,     15'b000000000000000};      // Add second 15 bits
    M[3]    = {LSL,    R2,     R1,     15'd2};                    // Shift left 2
    M[4]    = {ADI,    R1,     R2,     15'b000000000000011};      // Add last 2 bits

    // Setting 2nd number = 7
    // 00000000000000000000000000000111
    M[5]    = {ADI,    R2,     R0,     15'b000000000000000};      // Add first 15 bits
    M[6]    = {LSL,    R3,     R2,     15'd15};                   // Shift left 15
    M[7]    = {ADI,    R2,     R3,     15'b000000000000001};      // Add second 15 bits
    M[8]    = {LSL,    R3,     R2,     15'd2};                    // Shift left 2
    M[9]    = {ADI,    R2,     R3,     15'b000000000000011};      // Add last 2 bits

    // Checking 1st value if negative or positive, and getting magnitude of value
    M[10]   = {LSR,    R3,     R1,     15'd31};                   // Get sign bit from value in R1
    M[11]   = {BZ,     R1,     R3,     15'd4};                    // If positive, skip SUB+MOV (target M[16])
    // M[12], M[13]: branch delay slots (NOP, already zeroed)
    M[14]   = {SUB,    R4,     R0,  R1,   10'd0};                 // Convert negative value to positive value
    M[15]   = {MOV,    R1,     R4,     15'd0};                    // Move converted value back to R1

    // Checking 2nd value if negative or positive, and getting magnitude of value
    M[16]   = {LSR,    R4,     R2,     15'd31};                   // Get sign bit from value in R2
    M[17]   = {BZ,     R1,     R4,     15'd4};                    // If positive, skip SUB+MOV (target M[22])
    // M[18], M[19]: branch delay slots (NOP, already zeroed)
    M[20]   = {SUB,    R5,     R0,  R2,   10'd0};                 // Convert negative value to positive value
    M[21]   = {MOV,    R2,     R5,     15'd0};                    // Move converted value back to R2

    // Shift and add loop setup
    M[22]   = {ADI,    R9,     R0,     15'd1};                    // Add 1 to R9, will be loop counter
    M[23]   = {LSL,    R10,    R9,     15'd31};                   // Shift counter value left to the MSB
    M[24]   = {MOV,    R9,     R10,    15'd0};                    // Move back to R9

    // Shift and add loop body (M[25] is the loop-back target)
    M[25]   = {AND,    R10,    R9,  R2,   10'd0};                 // Mask R2 with R9 to see if bit is 1 or 0
    M[26]   = {MOV,    R11,    R7,     15'd0};                    // Save low accumulator
    M[27]   = {BZ,     R1,     R10,    15'd3};                    // If bit is zero, skip ADD (target M[31])
    // M[28], M[29]: branch delay slots (NOP, already zeroed)
    M[30]   = {ADD,    R11,    R1,  R7,   10'd0};                 // Add the first number to the lower 32 bit register
    M[31]   = {LSR,    R12,    R11,    15'd31};                   // Shift 31 bits to the right to find the MSB
    M[32]   = {ADD,    R13,    R12, R8,   10'd0};                 // Add the MSB to the upper 32 bit register
    M[33]   = {LSL,    R7,     R11,    15'd1};                    // Shift lower 32 left 1
    M[34]   = {LSL,    R8,     R13,    15'd1};                    // Shift upper 32 left 1
    M[35]   = {LSR,    R14,    R9,     15'd1};                    // Shift mask bit right 1
    M[36]   = {MOV,    R9,     R14,    15'd0};                    // Put mask bit back into R9
    M[37]   = {BNZ,    R1,     R14,    15'b111111111110011};      // Loop back to AND at M[25] (offset = -13)
    // M[38], M[39]: branch delay slots (NOP, already zeroed)
    M[40]   = {LSR,    R12,    R13,    15'd1};                    // Final shift of high result

    // Checking if output is positive or negative, branch past if positive otherwise set output as negative
    M[41]   = {XOR,    R10,    R3,  R4,   10'd0};                 // Check sign bits
    M[42]   = {BZ,     R1,     R10,    15'd6};                    // If positive output, skip negation (target M[49])
    // M[43], M[44]: branch delay slots (NOP, already zeroed)
    M[45]   = {SUB,    R9,     R0,  R12,   10'd0};                // Make negative value from upper register
    M[46]   = {SBI,    R12,    R9,     15'd1};                    // Subtract 1 from upper register
    M[47]   = {SUB,    R9,     R0,  R11,   10'd0};                // Make negative value from lower register
    M[48]   = {MOV,    R11,    R9,     15'd0};                    // Move value back into R11

    // Set R20 (HIGH 32) and R21 (LOW 32) with portions of product
    M[49]   = {LSR,    R20,    R12,     15'd0};
    M[50]   = {MOV,    R21,    R11,     15'd0};

end

always_comb begin
    IR = M[PC];
end

endmodule
