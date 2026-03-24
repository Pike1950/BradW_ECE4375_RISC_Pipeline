`default_nettype none
`timescale 1ns / 1ps

module RISC_CPU_PIPELINE(input logic clk,
                         input logic rst);

// ============================================================================
// Pipeline Registers
// Naming convention: signal_stage (stage the signal is used IN after latching)
// ============================================================================

// IF -> DOF boundary
logic [31:0] pc_if;         // Program counter, feeds IF stage
logic [31:0] pc1_dof;       // PC+1, latched from IF for DOF
logic [31:0] ir_dof;        // Instruction register, latched from IF for DOF

// DOF -> EX boundary
logic [31:0] pc2_ex;        // PC+2, latched from DOF for EX adder
logic        rw_ex;         // Read/write enable for EX instruction
logic [4:0]  da_ex;         // Destination address for EX instruction
logic [1:0]  md_ex;         // MUX D select for EX instruction
logic [1:0]  bs_ex;         // Branch select for EX instruction
logic        ps_ex;         // Polarity select for EX instruction
logic        mw_ex;         // Memory write for EX instruction
logic [4:0]  fs_ex;         // Function select for EX instruction
logic [4:0]  sh_ex;         // Shift amount for EX instruction
logic [31:0] bus_a_ex;      // A operand, latched from DOF for EX
logic [31:0] bus_b_ex;      // B operand, latched from DOF for EX

// EX -> WB boundary
logic        rw_wb;         // Read/write enable for WB instruction
logic [4:0]  da_wb;         // Destination address for WB instruction
logic [1:0]  md_wb;         // MUX D select for WB instruction
logic        vxorn_wb;      // V XOR N status, latched from EX for WB
logic [31:0] f_wb;          // ALU result, latched from EX for WB
logic [31:0] data_out_wb;   // Memory read data, latched from EX for WB

// ============================================================================
// Combinational wires
// Naming convention: signal_stage (stage that PRODUCES the signal)
// ============================================================================

// IF stage outputs
logic [31:0] pc1_if;        // PC+1 computed in IF
logic [31:0] ir_if;         // Instruction fetched in IF

// MUXC output
logic [31:0] pc_next;       // Next PC value from branch/increment logic

// DOF stage outputs
logic [31:0] bus_a_dof;     // A operand from DOF muxes
logic [31:0] bus_b_dof;     // B operand from DOF muxes
logic        rw_dof;        // Read/write from DOF decoder
logic [4:0]  da_dof;        // Destination address from DOF decoder
logic [1:0]  md_dof;        // MUX D select from DOF decoder
logic [1:0]  bs_dof;        // Branch select from DOF decoder
logic        ps_dof;        // Polarity select from DOF decoder
logic        mw_dof;        // Memory write from DOF decoder
logic [4:0]  fs_dof;        // Function select from DOF decoder
logic [4:0]  sh_dof;        // Shift amount from DOF decoder
logic [4:0]  aa_dof;        // Source A address from DOF decoder
logic [4:0]  ba_dof;        // Source B address from DOF decoder

// EX stage outputs
logic [31:0] f_ex;          // ALU result wire from EX
logic [31:0] data_out_ex;   // Memory read data wire from EX
logic        vxorn_ex;      // V XOR N wire from EX
logic        z_ex;          // Zero flag wire from EX
logic [31:0] bra_ex;        // Branch address from EX
logic [31:0] raa_ex;        // Register A address (for JMR) from EX
logic [31:0] bus_d_prime;   // MUX D' output: forwarded value from EX/WB boundary

// WB stage outputs
logic [31:0] bus_d_wb;      // Write-back data from WB

// Register file outputs
logic [31:0] a_data_rf;     // Register file A read output
logic [31:0] b_data_rf;     // Register file B read output

// MUX D' data inputs
logic [31:0] mux_d_data [4];
assign mux_d_data[0] = f_ex;
assign mux_d_data[1] = data_out_ex;
assign mux_d_data[2] = {31'd0, vxorn_ex};
assign mux_d_data[3] = {31'd0, vxorn_ex};

// ============================================================================
// Module instantiations
// ============================================================================

Register_file RF0(
    .clk(clk), .rst(rst),
    .rw(rw_wb),                          // Write enable from WB stage
    .da(da_wb),                          // Destination address from WB stage
    .aa(aa_dof), .ba(ba_dof),            // Source addresses from DOF decoder
    .d_data(bus_d_wb),                   // Write-back data from WB
    .a_data(a_data_rf),                  // A read output
    .b_data(b_data_rf)                   // B read output
);

MUXC_SECT T0(
    .bs(bs_ex), .ps(ps_ex),
    .z(z_ex),
    .pc1(pc1_if),
    .bra(bra_ex), .raa(raa_ex),
    .pc_next(pc_next)
);

IF_SECT IF0(
    .pc(pc_if),
    .pc1(pc1_if),
    .ir(ir_if)
);

DOF_SECT DOF0(
    .ir(ir_dof), .pc1(pc1_dof),
    .a_data(a_data_rf),
    .b_data(b_data_rf),
    .f_fwd(bus_d_prime),                 // Bus D': forwarded value from MUX D' (per Fig. 10-19)
    .da_ex(da_ex), .rw_ex(rw_ex),
    .bus_a(bus_a_dof),
    .bus_b(bus_b_dof),
    .rw(rw_dof), .ps(ps_dof), .mw(mw_dof),
    .da(da_dof), .fs(fs_dof), .sh(sh_dof),
    .md(md_dof), .bs(bs_dof),
    .aa(aa_dof), .ba(ba_dof)
);

EX_SECT E0(
    .a(bus_a_ex), .b(bus_b_ex),
    .pc2(pc2_ex),
    .sh(sh_ex), .fs(fs_ex),
    .clk(clk), .rst(rst), .mw(mw_ex),
    .f(f_ex),
    .data_out(data_out_ex),
    .bra(bra_ex), .raa(raa_ex),
    .vxorn(vxorn_ex), .z(z_ex)
);

WB_SECT WB0(
    .f(f_wb),
    .data_out(data_out_wb),
    .vxorn(vxorn_wb),
    .md(md_wb),
    .da(da_wb),
    .bus_d(bus_d_wb)
);

MUX #(.NUM_INPUTS(4)) MDP0(
    .sel(md_ex), .data(mux_d_data), .out(bus_d_prime)
);

// ============================================================================
// Pipeline registers: negedge clk captures combinational results
// ============================================================================

always_ff @(negedge clk) begin
    if (rst) begin
        {pc_if, pc1_dof, pc2_ex}                                    <= '0;
        ir_dof                                                       <= '0;
        {rw_ex, da_ex, md_ex, bs_ex, ps_ex, mw_ex, fs_ex, sh_ex}   <= '0;
        {rw_wb, da_wb, md_wb}                                        <= '0;
        {bus_a_ex, bus_b_ex}                                         <= '0;
        {vxorn_wb, f_wb, data_out_wb}                                <= '0;
    end else begin
        // IF -> DOF boundary
        pc_if       <= pc_next;
        pc1_dof     <= pc1_if;
        ir_dof      <= ir_if;

        // DOF -> EX boundary
        pc2_ex      <= pc1_dof;
        rw_ex       <= rw_dof;
        da_ex       <= da_dof;
        md_ex       <= md_dof;
        bs_ex       <= bs_dof;
        ps_ex       <= ps_dof;
        mw_ex       <= mw_dof;
        fs_ex       <= fs_dof;
        sh_ex       <= sh_dof;
        bus_a_ex    <= bus_a_dof;
        bus_b_ex    <= bus_b_dof;

        // EX -> WB boundary
        rw_wb       <= rw_ex;
        da_wb       <= da_ex;
        md_wb       <= md_ex;
        vxorn_wb    <= vxorn_ex;
        f_wb        <= f_ex;
        data_out_wb <= data_out_ex;
    end
end

endmodule
`default_nettype wire
