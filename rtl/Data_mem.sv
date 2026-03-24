`default_nettype none
`timescale 1ns / 1ps

module Data_mem(
    input  logic [31:0] Address, Data_in,
    input  logic        clk, MW, rst,
    output logic [31:0] Data_out
);

logic [31:0] DATA [256];

integer i;

// Combinational read port
always_comb begin
    Data_out = DATA[Address[7:0]]; // Limit to 8-bit address range
end

// Synchronous write on negedge clk
always_ff @(negedge clk) begin
    if (rst) begin
        for (i = 0; i < 256; i = i + 1)
            DATA[i] = 0;
    end else if (MW) begin
        if (Address > 255)
            DATA[255] <= Data_in;
        else
            DATA[Address[7:0]] <= Data_in;
    end
end

endmodule
`default_nettype wire
