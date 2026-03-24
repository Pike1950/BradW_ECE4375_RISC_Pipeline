`default_nettype none
`timescale 1ns / 1ps

module DOF_SECT(
    input  logic [31:0] ir,           // Instruction word from IF
    input  logic [31:0] pc1,          // PC+1 from IF
    input  logic [31:0] a_data,       // Register file A output
    input  logic [31:0] b_data,       // Register file B output
    input  logic [31:0] f_fwd,        // Bus D': forwarded value from MUX D' (per Fig. 10-19)
    input  logic [4:0]  da_ex,        // Destination address from EX stage (for hazard detection)
    input  logic        rw_ex,        // Read/write enable from EX stage (for hazard detection)
    output logic [31:0] bus_a,        // A operand output to EX
    output logic [31:0] bus_b,        // B operand output to EX
    output logic        rw,           // Read/write from decoder
    output logic        ps,           // Polarity select from decoder
    output logic        mw,           // Memory write from decoder
    output logic [4:0]  da,           // Destination address from decoder
    output logic [4:0]  fs,           // Function select from decoder
    output logic [4:0]  sh,           // Shift amount from IR
    output logic [1:0]  md,           // MUX D select from decoder
    output logic [1:0]  bs,           // Branch select from decoder
    output logic [4:0]  aa,           // Source A address from decoder
    output logic [4:0]  ba            // Source B address from decoder
);

logic [31:0] const_data;
logic        ha, ma, hb, mb, cs;
logic [14:0] im;

// MUX A data inputs: 0=register file, 1=PC+1, 2=forwarded, 3=forwarded
logic [31:0] mux_a_data [4];
assign mux_a_data[0] = a_data;
assign mux_a_data[1] = pc1;
assign mux_a_data[2] = f_fwd;
assign mux_a_data[3] = f_fwd;

// MUX B data inputs: 0=register file, 1=constant, 2=forwarded, 3=forwarded
logic [31:0] mux_b_data [4];
assign mux_b_data[0] = b_data;
assign mux_b_data[1] = const_data;
assign mux_b_data[2] = f_fwd;
assign mux_b_data[3] = f_fwd;

// Hazard detection: forward from EX when source address matches EX destination
// Conditions: (1) not using alternate source (MA/MB=0), (2) addresses match,
//             (3) EX instruction is writing (RW=1), (4) destination is not R0
assign ha = (!ma) & (aa == da_ex) & rw_ex & (|da_ex);
assign hb = (!mb) & (ba == da_ex) & rw_ex & (|da_ex);

always_comb begin
    im = ir[14:0];
    sh = ir[4:0];
end

Constant_unit CU0(
    .IM(im), .CS(cs), .CONST_DATA(const_data)
);

MUX #(.NUM_INPUTS(4)) MA0(
    .sel({ha, ma}), .data(mux_a_data), .out(bus_a)
);

MUX #(.NUM_INPUTS(4)) MB0(
    .sel({hb, mb}), .data(mux_b_data), .out(bus_b)
);

Instruction_Dec ID0(
    .IR(ir), .RW(rw), .DA(da), .MD(md), .BS(bs), .PS(ps),
    .MW(mw), .FS(fs), .MA(ma), .MB(mb), .AA(aa), .BA(ba), .CS(cs)
);

endmodule
`default_nettype wire
