`timescale 1ns / 1ps

module Data_mem(
    input [31:0] Address, Data_in,
    input clk, MW, rst,
    output reg [31:0] Data_out
    );
reg [31:0] DATA [256];

integer i;

initial begin // Set generic value to data
    for(i = 0; i < 256; i = i + 1)
        DATA[i] = i;
end


always_comb begin
        Data_out = DATA[Address]; // address is 32 bit number, so can only map to 32 bits
end

always@(negedge clk) begin
        if (rst) begin
                for (i = 0; i < 256; i = i + 1)
                        DATA[i] = 0;
        end else begin
                if(Address > 255)
                        DATA[255] <= (MW)? Data_in : DATA[255];
                else
                        DATA[Address] <= (MW)? Data_in : DATA[Address];
        end
end

endmodule
