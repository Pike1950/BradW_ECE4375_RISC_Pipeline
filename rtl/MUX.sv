module MUX #(
  parameter int unsigned WIDTH = 32,
  parameter int unsigned NUM_INPUTS = 3,
  parameter int unsigned SEL_WIDTH = $clog2(NUM_INPUTS)
)(
  input  logic [SEL_WIDTH-1:0]  sel,
  input  logic [WIDTH-1:0]      data [NUM_INPUTS],
  output logic [WIDTH-1:0]      out
);

  assign out = data[sel];

endmodule
