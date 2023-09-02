// tb_spi_to_temp.v
// Author: Samuel Sugimoto
// Date:

// Testbench for SPI to Temperature module

`timescale 1us/1us

module testbench;
  // UUT Signals
  reg         r_use_f;
  reg[9:0]    r_spi_data;
  wire[15:0]  w_spi_data;
  wire[6:-2]  w_temp_data;
  wire[6:0]   w_temp_num;
  wire[1:0]   w_temp_dec;
  integer i, j;

  // UUT
  spi_to_temp s2t (
    .i_use_f(r_use_f),
    .i_spi_data(w_spi_data),
    .o_temp_data(w_temp_data)
  );

  assign w_spi_data = {1'b0, r_spi_data, {5{r_spi_data[0]}}};
  assign w_temp_num = w_temp_data[6:0];
  assign w_temp_dec = w_temp_data[-1:-2];

  // Run Test suite
  initial begin
    r_use_f     <= 1'b0;
    r_spi_data  <= 10'h54;  // 21C (70F)
    for(i = 0; i < 2; i = i + 1) begin
      r_use_f     <= i == 0 ? 1'b0 : 1'b1 ;
      r_spi_data  <= 10'h54;  // 21C (70F)
      for(j = 0; j < 16; j = j + 1) begin
        #50 r_spi_data <= r_spi_data - 10'h1;
      end
    end
    #100 $stop;
  end
endmodule