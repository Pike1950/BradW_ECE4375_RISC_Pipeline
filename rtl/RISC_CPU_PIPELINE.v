`timescale 1ns / 1ps

module RISC_CPU_PIPELINE(input clk,
                         input rst);

// ============================================================================
// Pipeline Registers
// Naming convention: signal_stage (stage the signal is used IN after latching)
// ============================================================================

// IF -> DOF boundary
reg [31:0] pc_if    = 0;    // Program counter, feeds IF stage
reg [31:0] pc1_dof  = 0;    // PC+1, latched from IF for DOF
reg [31:0] ir_dof   = 0;    // Instruction register, latched from IF for DOF

// DOF -> EX boundary
reg [31:0] pc2_ex   = 0;    // PC+2, latched from DOF for EX adder
reg        rw_ex    = 0;    // Read/write enable for EX instruction
reg [4:0]  da_ex    = 0;    // Destination address for EX instruction
reg [1:0]  md_ex    = 0;    // MUX D select for EX instruction
reg [1:0]  bs_ex    = 0;    // Branch select for EX instruction
reg        ps_ex    = 0;    // Polarity select for EX instruction
reg        mw_ex    = 0;    // Memory write for EX instruction
reg [4:0]  fs_ex    = 0;    // Function select for EX instruction
reg [4:0]  sh_ex    = 0;    // Shift amount for EX instruction
reg [31:0] bus_a_ex = 0;    // A operand, latched from DOF for EX
reg [31:0] bus_b_ex = 0;    // B operand, latched from DOF for EX

// EX -> WB boundary
reg        rw_wb    = 0;    // Read/write enable for WB instruction
reg [4:0]  da_wb    = 0;    // Destination address for WB instruction
reg [1:0]  md_wb    = 0;    // MUX D select for WB instruction
reg        vxorn_wb = 0;    // V XOR N status, latched from EX for WB
reg [31:0] f_wb     = 0;    // ALU result, latched from EX for WB
reg [31:0] data_out_wb;     // Memory read data, latched from EX for WB

// ============================================================================
// Combinational wires
// Naming convention: signal_stage (stage that PRODUCES the signal)
// ============================================================================

// IF stage outputs
wire [31:0] pc1_if;         // PC+1 computed in IF
wire [31:0] ir_if;          // Instruction fetched in IF

// MUXC output
wire [31:0] pc_next;        // Next PC value from branch/increment logic

// DOF stage outputs
wire [31:0] bus_a_dof;      // A operand from DOF muxes
wire [31:0] bus_b_dof;      // B operand from DOF muxes
wire        rw_dof;         // Read/write from DOF decoder
wire [4:0]  da_dof;         // Destination address from DOF decoder
wire [1:0]  md_dof;         // MUX D select from DOF decoder
wire [1:0]  bs_dof;         // Branch select from DOF decoder
wire        ps_dof;         // Polarity select from DOF decoder
wire        mw_dof;         // Memory write from DOF decoder
wire [4:0]  fs_dof;         // Function select from DOF decoder
wire [4:0]  sh_dof;         // Shift amount from DOF decoder
wire [4:0]  aa_dof;         // Source A address from DOF decoder
wire [4:0]  ba_dof;         // Source B address from DOF decoder

// EX stage outputs
wire [31:0] f_ex;           // ALU result wire from EX
wire [31:0] data_out_ex;    // Memory read data wire from EX
wire        vxorn_ex;       // V XOR N wire from EX
wire        z_ex;           // Zero flag wire from EX
wire [31:0] bra_ex;         // Branch address from EX
wire [31:0] raa_ex;         // Register A address (for JMR) from EX

// WB stage outputs
wire [31:0] bus_d_wb;       // Write-back data from WB

// Register file outputs
wire [31:0] a_data_rf;      // Register file A read output
wire [31:0] b_data_rf;      // Register file B read output

// ============================================================================
// Module instantiations
// module_name  #(parameters)  instance_name  (ports);
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
    .bs(bs_ex), .ps(ps_ex),             // Branch/polarity from EX stage
    .z(z_ex),                            // Zero flag from EX
    .pc1(pc1_if),                        // PC+1 from IF (default next PC)
    .bra(bra_ex), .raa(raa_ex),          // Branch/register targets from EX
    .pc_next(pc_next)                    // Next PC output
);

IF_SECT IF0(
    .pc(pc_if),                          // Current program counter
    .pc1(pc1_if),                        // PC+1 output
    .ir(ir_if)                           // Fetched instruction output
);

DOF_SECT DOF0(
    .ir(ir_dof), .pc1(pc1_dof),          // Instruction and PC+1 from IF
    .a_data(a_data_rf),                  // Register file A output
    .b_data(b_data_rf),                  // Register file B output
    .f_fwd(f_ex),                        // Forwarded ALU result from EX
    .da_ex(da_ex), .rw_ex(rw_ex),        // EX stage dest addr and write enable (for hazard detection)
    .bus_a(bus_a_dof),                   // A operand output
    .bus_b(bus_b_dof),                   // B operand output
    .rw(rw_dof), .ps(ps_dof), .mw(mw_dof),
    .da(da_dof), .fs(fs_dof), .sh(sh_dof),
    .md(md_dof), .bs(bs_dof),
    .aa(aa_dof), .ba(ba_dof)
);

EX_SECT E0(
    .a(bus_a_ex), .b(bus_b_ex),          // Operands from DOF
    .pc2(pc2_ex),                        // PC+2 for branch address calc
    .sh(sh_ex), .fs(fs_ex),              // Shift/function select
    .clk(clk), .rst(rst), .mw(mw_ex),   // Clock, reset, memory write
    .f(f_ex),                            // ALU result output
    .data_out(data_out_ex),              // Memory read output
    .bra(bra_ex), .raa(raa_ex),          // Branch/register address outputs
    .vxorn(vxorn_ex), .z(z_ex)           // Status outputs
);

WB_SECT WB0(
    .f(f_wb),                            // ALU result from EX
    .data_out(data_out_wb),              // Memory data from EX
    .vxorn(vxorn_wb),                    // Status from EX
    .md(md_wb),                          // MUX D select
    .da(da_wb),                          // Destination address
    .bus_d(bus_d_wb)                     // Write-back data output
);

// ============================================================================
// Pipeline registers - clock edge captures combinational results
// ============================================================================

always @(negedge clk) begin
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

always @(posedge rst) begin
    {pc_if, pc1_dof, pc2_ex} = 0;
    ir_dof = 0;
    {rw_ex, da_ex, md_ex, bs_ex, ps_ex, mw_ex, fs_ex, sh_ex} = 0;
    {rw_wb, da_wb, md_wb} = 0;
    {bus_a_ex, bus_b_ex} = 0;
end

endmodule
