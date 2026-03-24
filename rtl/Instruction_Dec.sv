`default_nettype none
`timescale 1ns / 1ps

module Instruction_Dec(
    input  logic [31:0] IR,
    output logic        RW, PS, MA, MB, CS, MW,
    output logic [1:0]  MD, BS,
    output logic [4:0]  FS, AA, BA, DA
);

`include "OPCODES.INC";

always_comb begin
    FS = IR[29:25];
    DA = IR[24:20];
    BA = IR[14:10];
    AA = IR[19:15];

    // Control word values from Table 10-20
    case(IR[31:25])
        NOP:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000000000;
        ADD:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        SUB:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        SLT:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1100000000;
        AND:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        OR:      {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        XOR:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        ST:      {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000001000;
        LD:      {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1010000000;
        ADI:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000101;
        SBI:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000101;
        NOT:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        ANI:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        ORI:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        XRI:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        AIU:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        SIU:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        MOV:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        LSL:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        LSR:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        JMR:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0001000000;
        BZ:      {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000100101;
        BNZ:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000110101;
        JMP:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0001100101;
        JML:     {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1001100111;
        default: {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000000000;
    endcase
end

endmodule
`default_nettype wire
