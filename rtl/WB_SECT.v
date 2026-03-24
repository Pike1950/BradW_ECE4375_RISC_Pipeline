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

// MUX D data inputs: 0=ALU result, 1=memory read, 2=status
wire [31:0] mux_d_data [3];
assign mux_d_data[0] = f;
assign mux_d_data[1] = data_out;
assign mux_d_data[2] = status;

MUX #(.NUM_INPUTS(3)) MD0(
    .sel(md), .data(mux_d_data), .out(bus_d)
);

endmodule
