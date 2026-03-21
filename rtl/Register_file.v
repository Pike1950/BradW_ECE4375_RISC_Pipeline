`timescale 1ns / 1ps

module Register_file(
    input         clk, rst,
    input         rw,           // Read/write enable (from WB stage)
    input [4:0]   da,           // Destination address (from WB stage)
    input [4:0]   aa, ba,       // Source A/B addresses (from DOF decoder)
    input [31:0]  d_data,       // Write-back data (from WB stage)
    output reg [31:0] a_data,   // Source A data output
    output reg [31:0] b_data    // Source B data output
);

reg [31:0] REGISTER [31:0]; // 32 32-bit registers

integer i;

initial begin
        for(i = 0; i < 32; i = i + 1)
                REGISTER[i] = i;
end

always_comb begin
        a_data = REGISTER[aa];
        b_data = REGISTER[ba];
end

always @(posedge clk) begin
        REGISTER[da] <= ((rw) && (da == 0)) ? 0 :
                         (rw) ? d_data[31:0] : REGISTER[da];
end

always @(posedge rst) begin
        if(rst) begin
                for(i = 0; i < 32; i = i + 1)
                        REGISTER[i] <= 0;
        end
end

endmodule
