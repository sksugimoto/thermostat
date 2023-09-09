// tb_spi_handler.valid
// Author: Samuel Sugimoto
// Date: 

// Testbench for the SPI handler

`timescale 1us/1us

module testbench;
  // SPI Handler signals
  reg           r_clk;
  reg           r_reset_n;
  reg           r_read_program;
  wire[16895:0] w_program_data;
  wire[16895:0] w_expt_program;
  wire          w_program_ready;
  reg           r_read_therm;
  wire[9:0]     w_temperature;
  wire          w_therm_ready;
  reg           r_spi_disconnect;
  reg           r_program_mismatch;
  // SPI connectors
  wire      w_spi_clk;
  wire[1:0] w_spi_cs_n_pullup;
  wire[1:0] w_spi_cs_n;
  wire      w_spi_si;
  wire      w_spi_so;
  // Flash model signals
  wire[1048575:0] w_mem;
  // Thermometer model signals;
  reg r_heat, r_cool, r_amb_hc;
  // Testbench signals
  genvar  g_i;
  integer fh, scan_file, i;
  reg [63:0]    r_mem_array[16383:0];
  reg [16895:0] r_program;
  wire[63:0]    w_program_array[263:0];
  reg [9:0]     r_temperature;

  // -------------------------------------------
  // --         MODULE INSTANTIATIONS         --
  // -------------------------------------------
  wrapper_spi_handler UUT (
    // System clock
    .i_clk(r_clk),                        // : in  std_logic;
    .i_reset_n(r_reset_n),                // : in  std_logic;
    // Programming Request Controls
    .i_read_program(r_read_program),      // : in  std_logic;
    .o_program_data(w_program_data),      // : out std_logic_vector(16895 downto 0);
    .o_program_ready(w_program_ready),    // : out std_logic;
    // Temperatrue Request Controls
    .i_read_therm(r_read_therm),          // : in  std_logic;
    .o_temperature(w_temperature),        // : out std_logic_vector(9 downto 0);
    .o_therm_ready(w_therm_ready),        // : out std_logic;
    // SPI Port
    .i_spi_disconnect(r_spi_disconnect),  // : in  std_logic;
    .o_spi_clk(w_spi_clk),                // : out std_logic;  -- 10KHz clock
    .o_spi_cs_n(w_spi_cs_n),              // : out std_logic_vector(1 downto 0);
    .o_spi_si(w_spi_si),                  // : out std_logic;
    .i_spi_so(w_spi_so)                   // : in  std_logic
  );

  wrapper_flash_model flash_0 (
    // Normal SST25VG010A connections
    .i_sck(w_spi_clk),              // : in  std_logic;    -- SPI Clock (20MHz max)
    .i_ce_n(w_spi_cs_n_pullup[1]),  // : in  std_logic;    -- Chip Enable
    .i_wp_n(1'b1),                   // : in  std_logic;    -- Write Protect
    .i_hold_n(1'b1),                 // : in  std_logic;    -- Hold
    .i_si(w_spi_si),                // : in  std_logic;    -- SPI In
    .o_so(w_spi_so),                // : out std_logic;    -- SPI Out
    // Additional I/O for simulation/model purposes
    .i_mem(w_mem)     // : in  std_logic_vector(1048575 downto 0)
  );

  thermometer_model therm_0 (
    // -- Normal TI TMP125 connections
    .i_spi_clk(w_spi_clk),              // : in  std_logic;  -- 10MHz Max SPI clock, set to 1KHz
    .i_spi_cs_n(w_spi_cs_n_pullup[0]),  // : in  std_logic;
    .i_spi_si(w_spi_si),                // : in  std_logic;
    .o_spi_so(w_spi_so),                // : out std_logic;
    // Additional I/O for simulation/model purposes
    .i_heat(r_heat),                    // : in  std_logic;
    .i_cool(r_cool),                    // : in  std_logic;
    .i_amb_hc(r_amb_hc)                 // : in  std_logic
  );

  // --------------------------------------------
  // --            CLOCK GENERATION            --
  // --------------------------------------------
  // System clock generation (20KHz)
  initial r_clk <= 1'b1;
  always #25 r_clk <= ~r_clk;

  // --------------------------------------------
  // --         DATA ARRAY CONVERSIONS         --
  // --------------------------------------------
  // Convert r_mem_array 2d-array to 1d-wire w_mem.
  generate
    for(g_i = 0; g_i < 16384; g_i = g_i + 1) begin
      assign w_mem[(g_i*64+63):(g_i*64)] = r_mem_array[g_i];
    end
  endgenerate
  // Convert r_program 1d-array to 2d w_program_array;
  generate
    for(g_i = 0; g_i < 264; g_i = g_i + 1) begin
      assign w_program_array[g_i] = r_program[(g_i*64+63):(g_i*64)];
    end
  endgenerate

  // emulated external pullups for spi_cs_n
  assign w_spi_cs_n_pullup[0] = (w_spi_cs_n[0] == 1'b0) && (r_spi_disconnect == 1'b0) ? 1'b0 : 1'b1;
  assign w_spi_cs_n_pullup[1] = (w_spi_cs_n[1] == 1'b0) && (r_spi_disconnect == 1'b0) ? 1'b0 : 1'b1;

  // --------------------------------------------
  // --             EXPECTED DATA              --
  // --------------------------------------------
  assign w_expt_program = w_mem[16895:0];

  // --------------------------------------------
  // --             TEST PROCEDURE             --
  // --------------------------------------------
  initial begin
    // Read test file
    fh = $fopen("test_flash.dat", "r");
    if(fh == 0) begin
      $display("Error: File Handler was NULL");
      $stop;
    end
    for(i = 0; i < 16384; i = i + 1) begin
      if(i == 0) begin
        $display("Reading file...");
      end
      scan_file <= i == 16383 ? $fscanf(fh, "%h", r_mem_array[i]) : $fscanf(fh,"%x\n", r_mem_array[i]);
    end
    $display("Done reading file.");
    $fclose(fh);

    // Set initial values
    r_reset_n           <= 1'b1;  // reg
    r_read_program      <= 1'b0;  // reg
    r_read_therm        <= 1'b0;  // reg
    r_spi_disconnect    <= 1'b0;  // reg
    r_heat              <= 1'b0;  // reg
    r_cool              <= 1'b0;  // reg
    r_amb_hc            <= 1'b0;  // reg
    r_program_mismatch  <= 1'b0;

    // Run Test
    // Wait 0.15 sec for first temperature to load
    #150000

    // Request temperature data
    @(posedge r_clk) r_read_therm   <= 1'b1;
    // Request programming data on next clock cycle
    @(posedge r_clk) r_read_program <= 1'b1;
    // Wait for temperature data to become valid, then record
    wait(w_therm_ready == 1'b1);
    @(posedge r_clk) r_temperature <= w_temperature;
    r_read_therm <= 1'b0;
    // Pulse SPI disconnect mid xfer
    repeat(11) @(posedge r_clk);
    r_spi_disconnect <= 1'b1;
    repeat(50) @(posedge r_clk);
    r_spi_disconnect <= 1'b0;
    // Wait for programming data to become valid, then record.
    wait(w_program_ready == 1'b1);
    @(posedge r_clk) r_program <= w_program_data;
    r_read_program <= 1'b0;
    wait(w_program_ready == 1'b0);
    if(r_program != w_expt_program) begin
      r_program_mismatch <= 1'b1;
    end
    // Wait 10 clock cycles before requesting temperature again
    repeat (10) @(posedge r_clk);
    r_read_therm <= 1'b1;
    // Pulse SPI disconnect mid xfer
    repeat(10) @(posedge r_clk);
    r_spi_disconnect <= 1'b1;
    repeat(50) @(posedge r_clk);
    r_spi_disconnect <= 1'b0;
    // Wait for temperature data to become valid, then record
    wait(w_therm_ready == 1'b1);
    repeat(10) @(posedge r_clk);
    @(posedge r_clk) r_temperature <= w_temperature;
    r_read_therm <= 1'b0;
    wait(w_therm_ready == 1'b0);
    // Wait 10 clock cycles before stopping test
    repeat(10) @(posedge r_clk);
    if(r_program_mismatch == 1'b0) begin
      $display("Programming data out matches expected data.");
    end else begin
      $display("Error: Programming data out does not match expected data.");
    end
    $stop;
  end
endmodule
