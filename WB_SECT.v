`timescale 1ns / 1ps

module WB_SECT(
    input [31:0]  f,            // ALU result from EX
    input [31:0]  data_out,     // Memory read data from EX
    input         vxorn,        // V XOR N status from EX
    input [1:0]   md,           // MUX D select
    input [4:0]   da,           // Destination address
    output [31:0] bus_d         // Write-back data output
);

wire [31:0] status;
assign status = {31'd0, vxorn};

MUX_D MD0(
    .MD_1(md), .F(f), .Data_out(data_out), .status(status),
    .Bus_D(bus_d)
);

endmodule
