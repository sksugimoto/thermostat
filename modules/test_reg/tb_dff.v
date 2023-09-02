`timescale 1us/1us

module testbench;
  reg   r_clk;
  reg   r_d;
  wire  w_q0, w_q1;

  // DFF
  DFF dff_0 (
    .i_clk(r_clk),
    .i_d(r_d),
    .o_q(w_q0)
  );

  DFF dff_1 (
    .i_clk(r_clk),
    .i_d(w_q0),
    .o_q(w_q1)
  );

  // Clock
  initial r_clk <= 1'b1;
  always #5 r_clk <= ~r_clk;

  // D
  initial r_d <= 1'b0;
  always #20  @(posedge r_clk) r_d <= ~r_d;
endmodule