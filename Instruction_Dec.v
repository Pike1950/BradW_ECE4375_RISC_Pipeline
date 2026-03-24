`timescale 1ns / 1ps

module Instruction_Dec(
    input [31:0] IR,
    output reg RW, PS, MA, MB, CS, MW,
    output reg [1:0] MD, BS,
    output reg [4:0] FS, AA, BA, DA
    );
`include "OPCODES.INC";

// total output must be 35-bits:
//RW = 1bit,    DA = 5bit,  MD = 2bit,  BS = 2bit,  PS = 1bit,  MW = 1bit,  FS = 5bit,  SH = 5bit,  MA = 1bit,  MB = 1bit,  AA = 5bit,  BA = 5bit,  CS = 1bit
//ReadWrite,    DestAddr,   MuxD,       Top,        Polarity,   MemWrite,   ALU code,   Shifter,   MuxA,        MuxB,       AddressA,   AddressB,   Constant Select


always_comb begin
        FS = IR[29:25]; // 5 lowest bits from Opcode
        DA = IR[24:20];
        BA = IR[14:10];
        AA = IR[19:15];

        // Control word values set from Table 10-20 Control Words for Instructions
        case(IR[31:25])
        NOP:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000000000;
        ADD:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        SUB:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        SLT:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1100000000;
        AND:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        OR:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        XOR:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        ST:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000001000;
        LD:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1010000000;
        ADI:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000101;
        SBI:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000101;
        NOT:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        ANI:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        ORI:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        XRI:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        AIU:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        SIU:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
        MOV:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        LSL:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        LSR:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
        JMR:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0001000000;
        BZ:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000100101;
        BNZ:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000110101;
        JMP:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0001100101;
        JML:
        {RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1001100111;
    endcase

end

endmodule
