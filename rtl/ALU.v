`timescale 1ns / 1ps

module ALU(
    input [31:0] A,B,
    input [4:0] SH,FS,
    output reg Z,C,N,V,
    output reg [31:0] F);
`include "FSCODES.INC";

always_comb begin
        V = 0; // Defaults for flags not set by every path
        C = 0;
        case(FS)
            ADD:
            begin
                {C,F} = A + B;
                V= (((A[31]) && (B[31])) && (!F[31]))? 1 :              // negative+negative=positive
                        (((!A[31]) && (!B[31])) && (F[31]))? 1 : 0;     // positive+positive=negative
            end
            SUB:
            begin
                F = A - B;
                V= (((A[31]) && (!B[31])) && (!F[31]))? 1 :              // negative-positive=positive
                        (((!A[31]) && (B[31])) && (F[31]))? 1 : 0;     // positive-negative=negative
            end
            AND:
                F = A&B;
            OR:
                F = A|B;
            XOR:
                F = A^B;
            NOT:
                F = ~A;
            MOV:
                F = A;
            LSL:
                F = A<<SH;
            LSR:
                F = A>>SH;
            JML:
                F = A;
    default: F = 0;
        endcase

        // Z: JML writes PC+1 (return address) to register file — updating Z based on a return address value would be misleading. Preserve previous Z.
        Z = (FS == JML) ? Z :
            (F == 0) ? 1 : 0;

        // N: MOV and JML pass through data without arithmetic. Preserve previous N so downstream branches can still test flags from the last arithmetic op.
        N = ((FS == MOV) || (FS == JML)) ? N :
            (F[31]) ? 1 : 0;
end

endmodule
