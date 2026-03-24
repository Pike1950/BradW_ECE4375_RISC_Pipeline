`default_nettype none
`timescale 1ns / 1ps

module Register_file(
    input  logic        clk, rst,
    input  logic        rw,           // Read/write enable (from WB stage)
    input  logic [4:0]  da,           // Destination address (from WB stage)
    input  logic [4:0]  aa, ba,       // Source A/B addresses (from DOF decoder)
    input  logic [31:0] d_data,       // Write-back data (from WB stage)
    output logic [31:0] a_data,       // Source A data output
    output logic [31:0] b_data        // Source B data output
);

logic [31:0] REGISTER [32]; // 32 x 32-bit registers

integer i;

// Combinational read ports
always_comb begin
    a_data = REGISTER[aa];
    b_data = REGISTER[ba];
end

// Synchronous write on posedge clk (preserves write-before-read timing with negedge pipeline regs)
always_ff @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            REGISTER[i] = 0;
    end else begin
        if (rw && da != 5'd0)
            REGISTER[da] <= d_data;
    end
end

endmodule
`default_nettype wire
