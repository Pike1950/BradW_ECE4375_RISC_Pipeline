`timescale 1ns / 1ps

module RISC_CPU_PIPELINE_tb();

reg clk, rst;

RISC_CPU_PIPELINE uut(.clk(clk),.rst(rst));

initial begin // Initialize clk and rst to 0, apply reset pulse for 50ns, then release to known state of 0 for clk & rst at 60ns after start of simulation
    clk = 0;
    rst = 0;
    #10 rst = 1;
    #50 rst = 0;
end

always
    #5 clk = ~clk; // Clock period of 10ns, frequency of 100MHz
endmodule
