// tb_spi_request_handler.v
// Author: Samuel Sugimoto
// Date:

`timescale 1us/1us

module testbench;
  // Parameters
  parameter p_clk_freq = 20000; // 500;
  parameter p_btn_init = 20000; // 500;
  parameter p_btn_hold = 4000;  // 100;

  // Request handler signals
  reg           r_clk;
  reg           r_reset_n;
  reg           r_sys_pwr_n;
  reg           r_reprogram_n;
  wire[5:0]     w_time_second;
  wire          w_program_req;
  wire          w_program_rdy;
  wire[16895:0] w_sh_prog_data;
  wire[16895:0] w_last_prog_data;
  wire          w_temp_req;
  wire          w_temp_rdy;
  wire[9:0]     w_sh_temp;
  wire[9:0]     w_last_temp;

  // SPI handler signals
  genvar  g_i;
  wire[63:0]    w_program_array[263:0];
  
  // Flash Module signals
  integer fh, scan_file, i;
  reg [63:0]      r_mem_array[16383:0];
  wire[1048575:0] w_mem;

  // Thermometer model signals;
  reg   r_amb_hc;

  // Time keeper signals
  wire[6:0] w_day;
  wire[4:0] w_hour;
  wire[5:0] w_minute;

  // SPI signals
  wire      w_spi_clk;
  wire[1:0] w_spi_cs_n;
  wire      w_spi_si;
  wire      w_spi_so;
  

  // -------------------------------------------
  // --         MODULE INSTANTIATIONS         --
  // -------------------------------------------
  wrapper_spi_data_handler UUT (
    .i_clk(r_clk),                  // : in  std_logic;
    .i_reset_n(r_reset_n),          // : in  std_logic;
    .i_sys_pwr_n(r_sys_pwr_n),      // : in  std_logic;
    .i_reprogram_n(r_reprogram_n),  // : in  std_logic;
    .i_time_second(w_time_second),  // : in  std_logic_vector(5 downto 0);
    // Program data signals
    .o_program_req(w_program_req),  // : out std_logic;
    .i_program_rdy(w_program_rdy),  // : in  std_logic;
    .i_sh_prog_data(w_sh_prog_data),
    .o_last_prog_data(w_last_prog_data),
    // Temperature data signals
    .o_temp_req(w_temp_req),        // : out std_logic;
    .i_temp_rdy(w_temp_rdy),        // : in  std_logic
    .i_sh_temp_data(w_sh_temp),
    .o_last_temp_data(w_last_temp)
  );

  wrapper_spi_handler spi_handler (
    // System clock
    .i_clk(r_clk),                      // : in  std_logic;
    .i_reset_n(r_reset_n),              // : in  std_logic;
    // Programming Request Controls
    .i_read_program(w_program_req),     // : in  std_logic;
    .o_program_data(w_sh_prog_data),    // : out std_logic_vector(16895 downto 0);
    .o_program_ready(w_program_rdy),    // : out std_logic;
    // Temperatrue Request Controls
    .i_read_therm(w_temp_req),        // : in  std_logic;
    .o_temperature(w_sh_temp),    // : out std_logic_vector(9 downto 0);
    .o_therm_ready(w_temp_rdy),      // : out std_logic;
    // SPI Port
    .i_spi_disconnect(!r_reprogram_n),   // : in  std_logic;
    .o_spi_clk(w_spi_clk),              // : out std_logic;  -- 10KHz clock
    .o_spi_cs_n(w_spi_cs_n),            // : out std_logic_vector(1 downto 0);
    .o_spi_si(w_spi_si),                // : out std_logic;
    .i_spi_so(w_spi_so)                 // : in  std_logic
  );

  wrapper_flash_model flash_0 (
    // Normal SST25VG010A connections
    .i_sck(w_spi_clk),              // : in  std_logic;    -- SPI Clock (20MHz max)
    .i_ce_n(w_spi_cs_n[1]),  // : in  std_logic;    -- Chip Enable
    .i_wp_n(1'b1),                   // : in  std_logic;    -- Write Protect
    .i_hold_n(1'b1),                 // : in  std_logic;    -- Hold
    .i_si(w_spi_si),                // : in  std_logic;    -- SPI In
    .o_so(w_spi_so),                // : out std_logic;    -- SPI Out
    // Additional I/O for simulation/model purposes
    .i_mem(w_mem)     // : in  std_logic_vector(1048575 downto 0)
  );

  // Thermoter Module
  thermometer_model # (
    .g_temp_chg_sec(60)
  ) therm_0 (
    .i_spi_clk(w_spi_clk),
    .i_spi_cs_n(w_spi_cs_n[0]),
    .i_spi_si(w_spi_si),
    .o_spi_so(w_spi_so),
    .i_heat(1'b0),
    .i_cool(1'b0),
    .i_amb_hc(r_amb_hc)
  );

  wrapper_time_keeper # (
    // Set to different value for simulation
    .g_clk_freq(p_clk_freq),  // : integer := 20000;
    .g_btn_init(p_btn_init),  // : integer := 20000;
    .g_btn_hold(p_btn_hold)   // : integer := 5000
  )
  time_keeper_0 (
    // Clock and Reset
    .i_clk(r_clk),
    .i_reset_n(r_reset_n),

    // User Interface
    .i_set_time_n(1'b1),
    .i_incr_day_n(1'b1),
    .i_incr_hr_n(1'b1),
    .i_incr_min_n(1'b1),

    // Time
    .o_day(w_day),
    .o_hour(w_hour),
    .o_minute(w_minute),
    .o_second(w_time_second)
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
  // Convert w_last_prog_data 1d-array to 2d w_program_array
  generate
    for(g_i = 0; g_i < 264; g_i = g_i + 1) begin
      assign w_program_array[g_i] = w_last_prog_data[(g_i*64+63):(g_i*64)];
    end
  endgenerate

  // r_amb_hc toggle
  initial r_amb_hc <= 1'b0;
  always begin
    repeat(10*p_clk_freq) @(posedge r_clk);
    r_amb_hc <= ~r_amb_hc;
  end

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
    r_reset_n     <= 1'b1;
    r_sys_pwr_n   <= 1'b1;
    r_reprogram_n <= 1'b1;

    // Wait for 1 second then turn system on
    repeat(p_clk_freq) @(posedge r_clk);
    r_sys_pwr_n   <= 1'b0;
    $display("Simulating for 5 minutes and 45 seconds...");
    // Assert r_reprogram_n at 1:59
    wait(w_minute == 6'h1);
    wait(w_time_second == 6'h3B);
    r_reprogram_n <= 1'b0;
    // Deassert r_reprogram_n at 2:29
    wait(w_minute == 6'h2);
    wait(w_time_second == 6'h1D); 
    r_reprogram_n <= 1'b1;
    wait(w_minute == 6'h5);
    wait(w_time_second == 6'h2D);

    $stop;
  end
endmodule
