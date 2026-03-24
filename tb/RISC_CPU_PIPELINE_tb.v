`timescale 1ns / 1ps

// =============================================================================
// RISC_CPU_PIPELINE_tb.v
// Self-checking testbench for the 4-stage pipelined RISC CPU
//
// Runs the 3 x 7 multiply program (M[0]-M[40]) and checks:
//   R20 = 0x00000000  (high 32 bits of product)
//   R21 = 0x00000015  (low 32 bits = 21 decimal)
//
// Produces: waveform.vcd for GTKWave inspection
// =============================================================================

module RISC_CPU_PIPELINE_tb();

reg clk, rst;

RISC_CPU_PIPELINE uut(.clk(clk), .rst(rst));

// ---- Clock: 10ns period (100 MHz) ----
initial clk = 0;
always #5 clk = ~clk;

// ---- VCD dump for GTKWave ----
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, RISC_CPU_PIPELINE_tb);
end

// ---- Reset and run ----
initial begin
    rst = 0;
    #10  rst = 1;     // Assert reset
    #50  rst = 0;     // Release reset at t=60ns

    // Wait for multiply program to complete
    // 41 instructions + 32 loop iterations * ~11 insns + branch penalties
    // Conservative: 10,000ns = 1000 cycles
    #10000;

    // ---- Check results ----
    $display("");
    $display("========================================");
    $display("  Multiply Program Results (3 x 7)");
    $display("========================================");
    $display("  R20 (high 32) = 0x%08h  (expected 0x00000000)", uut.RF0.REGISTER[20]);
    $display("  R21 (low  32) = 0x%08h  (expected 0x00000015)", uut.RF0.REGISTER[21]);
    $display("  R21 decimal   = %0d      (expected 21)",         uut.RF0.REGISTER[21]);
    $display("----------------------------------------");

    if (uut.RF0.REGISTER[20] === 32'h00000000 &&
        uut.RF0.REGISTER[21] === 32'h00000015) begin
        $display("  RESULT: PASS");
    end else begin
        $display("  RESULT: FAIL");
        $display("");
        $display("  Debug: dumping key registers...");
        $display("    R0  = 0x%08h", uut.RF0.REGISTER[0]);
        $display("    R1  = 0x%08h  (multiplicand = 3)", uut.RF0.REGISTER[1]);
        $display("    R2  = 0x%08h  (multiplier = 7)",   uut.RF0.REGISTER[2]);
        $display("    R3  = 0x%08h  (sign bit R1)",      uut.RF0.REGISTER[3]);
        $display("    R4  = 0x%08h  (sign bit R2)",      uut.RF0.REGISTER[4]);
        $display("    R7  = 0x%08h  (low accumulator)",  uut.RF0.REGISTER[7]);
        $display("    R8  = 0x%08h  (high accumulator)", uut.RF0.REGISTER[8]);
        $display("    R9  = 0x%08h  (loop mask)",        uut.RF0.REGISTER[9]);
        $display("    R11 = 0x%08h  (low result)",       uut.RF0.REGISTER[11]);
        $display("    R12 = 0x%08h  (high result)",      uut.RF0.REGISTER[12]);
        $display("    PC  = %0d",                        uut.pc_if);
    end

    $display("========================================");
    $display("");
    $finish;
end

endmodule
