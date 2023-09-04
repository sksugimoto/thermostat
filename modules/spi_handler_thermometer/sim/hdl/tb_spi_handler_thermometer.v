// tb_spi_handler.v
// Author: Samuel Sugimoto
// Date: 

// Testbench for SPI hander module.  Utilizes thermometer model.

`timescale 1us/1us

module testbench;
  // Control signals
  reg         r_sys_clk;
  reg         r_reset_n;
  reg         r_data_request;
  wire[15:0]  w_data;
  wire        w_data_valid;
  reg[15:0]   r_coll_data;
  wire[9:0]   w_temperature_trunc;
  // SPI signals
  reg   w_spi_clk;
  wire  w_spi_cs_n;
  wire  w_spi_si;
  wire  w_spi_so;
  // Thermometer signals
  reg   r_heat;
  reg   r_cool;
  reg   r_amb_hc;

  // SPI Handler module
  spi_handler_thermometer sh_0 (
    .i_clk(r_sys_clk),
    .i_reset_n(r_reset_n),
    .i_data_request(r_data_request),
    .o_data(w_data),
    .o_data_valid(w_data_valid),
    .i_spi_clk(w_spi_clk),
    .o_spi_cs_n(w_spi_cs_n),
    .o_spi_si(w_spi_si),
    .i_spi_so(w_spi_so)
  );

  // Thermometer module
  thermometer_model therm0 (
    .i_spi_clk(w_spi_clk),
    .i_spi_cs_n(w_spi_cs_n),
    .i_spi_si(w_spi_si),
    .o_spi_so(w_spi_so),
    .i_heat(r_heat),
    .i_cool(r_cool),
    .i_amb_hc(r_amb_hc)
  );
  
  assign w_temperature_trunc = r_coll_data[14:5];

  // System clock generation (20kHz)
  initial r_sys_clk <= 1'b1;
  always  #25 r_sys_clk <= ~r_sys_clk;

  // SPI clck generation (10KHz)
  initial w_spi_clk <= 1'b1;
  always #50 w_spi_clk <= ~w_spi_clk;

  // Run test suite
  initial begin
    r_reset_n       <= 1'b1;
    r_data_request  <= 1'b0;
    r_heat          <= 1'b0;
    r_cool          <= 1'b0;
    r_amb_hc        <= 1'b0;

    // Wait 0.15 sec for first temperature to load
    #150000

    // Request Thermometer data
    read_spi_therm;
    #500000 // Wait 0.5 sec
    read_spi_therm;
    #1000 $stop;
  end

  task read_spi_therm;
  begin
    // Wait for posedge system clock, then set data request high
    @(posedge r_sys_clk) r_data_request <= 1'b1;
    wait (w_data_valid == 1'b1);
    @(posedge r_sys_clk) r_coll_data <= w_data;
    r_data_request <= 1'b0;
  end
  endtask
endmodule
