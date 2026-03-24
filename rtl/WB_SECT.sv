`default_nettype none
`timescale 1ns / 1ps

module WB_SECT(
    input  logic [31:0] f,            // ALU result from EX
    input  logic [31:0] data_out,     // Memory read data from EX
    input  logic        vxorn,        // V XOR N status from EX
    input  logic [1:0]  md,           // MUX D select
    input  logic [4:0]  da,           // Destination address
    output logic [31:0] bus_d         // Write-back data output
);

logic [31:0] status;
assign status = {31'd0, vxorn};

// MUX D data inputs: 0=ALU result, 1=memory read, 2=status
logic [31:0] mux_d_data [3];
assign mux_d_data[0] = f;
assign mux_d_data[1] = data_out;
assign mux_d_data[2] = status;

MUX #(.NUM_INPUTS(3)) MD0(
    .sel(md), .data(mux_d_data), .out(bus_d)
);

endmodule
`default_nettype wire
