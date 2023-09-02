// thermometer_model.vhd
// Author: Samuel Sugimoto
// Date:

// Testbench for TMP125 thermometer emulator

`timescale 1us/1us

module testbench;
  // UUT Signals
  reg   r_spi_clk;
  reg   r_spi_cs_n;
  reg   r_spi_si;
  wire  w_spi_so;
  reg   r_heat;
  reg   r_cool;
  reg   r_amb_hc;

  // Testbench Signals
  reg[15:0] r_spi_in;
  wire[9:0] w_conv_temp;
  integer i;

  // Thermoter Module
  thermometer_model therm0 (
    .i_spi_clk(r_spi_clk),
    .i_spi_cs_n(r_spi_cs_n),
    .i_spi_si(r_spi_si),
    .o_spi_so(w_spi_so),
    .i_heat(r_heat),
    .i_cool(r_cool),
    .i_amb_hc(r_amb_hc)
  );

  assign w_conv_temp = r_spi_in[14:5];

  // SPI Clock Generation (1KHz), SPI clock 10MHz max
  initial r_spi_clk <= 1'b1;
  always #500 r_spi_clk <= ~r_spi_clk;

  // Run test suite
  initial begin
    // Initialization
    r_spi_cs_n  <= 1'b1;
    r_spi_si    <= 1'b0;
    r_heat      <= 1'b0;
    r_cool      <= 1'b0;
    r_amb_hc    <= 1'b0;
    #5000
    
    // Ambient cooling, hvac off
    read_temp;
    #1000000  //Wait 1 sec
    read_temp;
    #1000000 $stop;
  end

  task read_temp;
  begin
    // Wait for posedge of spi clock, then set spi select low
    #1000 @(posedge r_spi_clk) r_spi_cs_n  <= 1'b0;
    // Read in 16 bits of data from spi line
    for(i = 0; i < 16; i = i + 1) begin
      @(posedge r_spi_clk) r_spi_in[15-i] <= w_spi_so;
      // Deassert CS after 16 clock cycles
      if(i == 15) begin
        r_spi_cs_n <= 1'b1;
      end
    end
  end
  endtask

  
endmodule