`timescale 1ns / 1ps

module Register_file_TB();

reg clk, rst, RW;
reg [4:0] DA, AA, BA;
reg [31:0] D_DATA;

wire [31:0] A_DATA, B_DATA;

integer i;

Register_file uut(.clk(clk), .rst(rst), .rw(RW),
                  .da(DA), .aa(AA), .ba(BA),
                  .d_data(D_DATA),
                  .a_data(A_DATA), .b_data(B_DATA));

initial begin
        {clk,rst,RW,DA,AA,BA,D_DATA} = 0;
        for(i = 0; i < 32; i = i + 1) begin
            #5 AA = i;
        end
        #10 AA = 0;
        RW = 1;
        #5;
        for(i = 0; i < 32; i = i + 1) begin
            #10 D_DATA = i;
            DA = i;
        end
        #5 RW = 0;
        for(i = 0; i < 32; i = i + 1) begin
            #5 BA = i;
        end
        #10 rst = 1;
        for(i = 0; i < 32; i = i + 1) begin
            #5 AA = i;
        end
    end

    always
        #5 clk = ~clk;

endmodule
