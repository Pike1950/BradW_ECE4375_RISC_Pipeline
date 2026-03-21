`timescale 1ns / 1ps

module Instruction_Mem( input [31:0] PC,
                        output reg [31:0] IR
                        );
`include "OPCODES.INC";
`include "REGISTERS.INC";

reg [6:0] opcode = 0; // values come from Fig.10-13 RISC CPU Instruction Formats
reg [31:0] M [0:1024];
integer i;

initial begin

    for(i = 0; i < 100; i = i + 1) begin
        M[i] = 0; // NOP
    end


    //         7-bit | 5-bit|5-bit| 5-bit + 10-bit |
    //        OPCODE | DEST | SA  | TARGET JUMP    | 15-bit
    //        OPCODE | DEST | SA  | IMMEDIATE      | 15-bit
    //        OPCODE | DEST | SA  | SB  | JUNK     | 5-bit, 10-bit

    // Setting 1st number = 3
    // 00000000000000000000000000000011
    M[1]    = {ADI,    R1,     R0,     15'b000000000000000};      // Add first 15 bits
    M[3]    = {LSL,    R2,     R1,     15'd15};                   // Shift left 15
    M[5]    = {ADI,    R1,     R2,     15'b000000000000000};      // Add second 15 bits
    M[7]    = {LSL,    R2,     R1,     15'd2};                    // Shift left 2
    M[9]    = {ADI,    R1,     R2,     15'b000000000000011};      // Add last 2 bits

    // Setting 2nd number = 7
    // 00000000000000000000000000000111
    M[11]   = {ADI,    R2,     R0,     15'b000000000000000};      // Add first 15 bits
    M[13]   = {LSL,    R3,     R2,     15'd15};                   // Shift left 15
    M[15]   = {ADI,    R2,     R3,     15'b000000000000001};      // Add second 15 bits
    M[17]   = {LSL,    R3,     R2,     15'd2};                    // Shift left 2
    M[19]   = {ADI,    R2,     R3,     15'b000000000000011};      // Add last 2 bits

    // Checking 1st value if negative or positive, and getting magnitude of value
    M[21]   = {LSR,    R3,     R1,     15'd31};                   // Get sign bit from value in R1
    M[23]   = {BZ,     R1,     R3,     15'd6};                    // If positive, then branch past SUB and MOV otherwise continue
    M[26]   = {SUB,    R4,     R0,  R1,   10'd0};                 // Convert negative value to positive value
    M[28]   = {MOV,    R1,     R4,     15'd0};                    // Move converted value back to R1

    // Checking 2nd value if negative or positive, and getting magnitude of value
    M[30]   = {LSR,    R4,     R2,     15'd31};                   // Get sign bit from value in R2
    M[32]   = {BZ,     R1,     R4,     15'd6};                    // If positive, then branch past SUB and MOV otherwise continue
    M[35]   = {SUB,    R5,     R0,  R2,   10'd0};                 // Convert negative value to positive value
    M[37]   = {MOV,    R2,     R5,     15'd0};                    // Move converted value back to R2

    // Shift and add loop
    M[39]   = {ADI,    R9,     R0,     15'd1};                    // Add 1 to R9, will be loop counter
    M[41]   = {LSL,    R10,    R9,     15'd31};                   // Shift counter value left to the MSB
    M[43]   = {MOV,    R9,     R10,    15'd0};                    // Move back to R9
    M[45]   = {AND,    R10,    R9,  R2,   10'd0};                 // Mask R2 with R9 to see if bit is 1 or 0
    M[47]   = {MOV,    R11,    R7,     15'd0};
    M[49]   = {BZ,     R1,     R10,    15'd4};                    // If bit is zero, then skip the next ADD
    M[52]   = {ADD,    R11,    R1,  R7,   10'd0};                 // Add the first number to the lower 32 bit register
    M[54]   = {LSR,    R12,    R11,    15'd31};                   // Shift 31 bits to the right to the find the MSB
    M[56]   = {ADD,    R13,    R12, R8,   10'd0};                 // Add the MSB to the upper 32 bit register
    M[58]   = {LSL,    R7,     R11,    15'd1};                    // Shift lower 32 left 1
    M[60]   = {LSL,    R8,     R13,    15'd1};                    // Shift upper 32 left 1
    M[62]   = {LSR,    R14,    R9,     15'd1};                    // Shift mask bit right 1
    M[64]   = {MOV,    R9,     R14,    15'd0};                    // Put mask bit back into R9
    M[66]   = {BNZ,    R1,     R14,    15'b111111111101010};      // If loop isn't done, then go back to AND instruction on 45
    M[69]   = {LSR,    R12,    R13,    15'd1};

    // Checking if output is positive or negative, branch past if positive otherwise set output as negative
    M[71]   = {XOR,    R10,    R3,  R4,   10'd0};                 // Check sign bits
    M[73]   = {BZ,     R1,     R10,    15'd9};                    // If positive output expected, then branch past otherwise update product registers for negative values
    M[76]   = {SUB,    R9,     R0,  R12,   10'd0};                // Make negative value from upper register
    M[78]   = {SBI,    R12,    R9,     15'd1};                    // Subtract 1 from upper register
    M[80]   = {SUB,    R9,     R0,  R11,   10'd0};                // Make negative value from lower register
    M[82]   = {MOV,    R11,    R9,     15'd0};                    // Move value back into R11

    // Set R20 (HIGH 32) and R21 (LOW 32) with portions of product
    M[84]   = {LSR,    R20,    R12,     15'd0};
    M[86]   = {MOV,    R21,    R11,     15'd0};

end

always_comb begin
    IR = M[PC];
end

endmodule
