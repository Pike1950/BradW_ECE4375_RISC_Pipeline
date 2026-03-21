`timescale 1ns / 1ps

module MUX_D(
    input [1:0] MD_1,
    input [31:0] F, Data_out, status,
    output reg [31:0] Bus_D
    );

always_comb begin
    case(MD_1)
            0:  Bus_D = F;
            1:  Bus_D = Data_out;
            2:  Bus_D = status;
     endcase
end

endmodule
