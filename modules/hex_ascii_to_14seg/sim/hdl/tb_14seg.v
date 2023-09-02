// tb_14seg.v
// Author: Samuel Sugimoto
// Date:

// Testbench for hex_ascii_to_14seg module.

`timescale 1us/1us

module testbench;
  // Control signals
  reg[6:0]    r_data;
  reg         r_ascii;
  reg         r_dp_en;
  wire[14:0]  w_14seg;
  // Test signals
  integer i;

  // 14 Segment conversion module
  hex_ascii_to_14seg UUT (
    .i_data(r_data),    // : in  std_logic_vector(6 downto 0);
    .i_ascii(r_ascii),   // : in  std_logic;
    .i_dp_en(r_dp_en),   // : in  std_logic;
    .o_14_seg(w_14seg)  // : out std_logic_vector(14 downto 0)
  );

  // Run Test Suite
  initial begin
    // Set UUT's initial control inputs
    r_data  <= 7'b0;
    r_ascii <= 1'b0;
    r_dp_en <= 1'b0;
    // Wait for 10 us
    #10;
    // Run Test
    // Hex conversion
    for (i = 0; i < 16; i = i + 1) begin
      r_data  <= i[6:0];
      #10;
    end
    // ASCII conversion
    r_ascii <= 1'b1;
    for (i=32; i < 91; i = i + 1) begin
      if(i == 60 | i == 80) begin
        r_dp_en <= 1'b1;
      end
      else begin
        r_dp_en <= 1'b0;
      end
      r_data <= i[6:0];
      #10;
    end
    #50 $stop;
  end
endmodule
