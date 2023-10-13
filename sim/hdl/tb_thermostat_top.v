// tb_thermostat_top.v
// Author: Samuel Sugimoto
// Date:

// Testbench for the entire therostat design

`timescale 1us/1us

module testbench;
  // Parameters
  parameter p_clk_freq    = 20;  // Must be divisible by 20
  parameter p_btn_init    = p_clk_freq;
  parameter p_btn_hold    = p_clk_freq/4;
  parameter p_usr_ui_idle = 5*p_clk_freq;
  parameter p_controller_sc_delay_time = p_clk_freq*60*10; // 10 "minutes"

  // Thermostat signals
  // Control signals
  reg         r_clk;
  reg         r_reset_n;
  reg         r_sys_on_n;
  reg         r_use_f_n;
  reg         r_run_prog_n;
  reg         r_force_fan_n;
  reg[2:0]    r_heat_cool_n;
  reg         r_reprogram_n;
  reg         r_set_time_n;
  reg         r_incr_week_n;
  reg         r_incr_day_n;
  reg         r_incr_hr_n;
  reg         r_incr_min_n;
  reg         r_temp_up_n;
  reg         r_temp_down_n;
  // Output signals
  wire[14:0]  w_14seg_n [15:0];
  wire[6:0]   w_day_time_day_n;
  wire        w_prgm_error_n;
  wire        w_prgm_ovride_n;
  wire        w_heat_on_n;
  wire        w_cool_on_n;
  wire        w_force_fan_n;
  wire        w_sys_cycling_n;
  wire        w_green_fan;
  wire        w_yellow_ac;
  wire        w_white_heat;
  // others
  integer i;
  genvar  g_i;

  // SPI signals
  wire      w_spi_clk;
  wire[1:0] w_spi_cs_n;
  wire      w_spi_si;
  wire      w_spi_so;

  // SPI device signals
  wire[1048575:0] w_mem;
  reg [127:0]     r_prog_instance [62:0];
  reg [63:0]      r_prog_day  [63:0];
  reg [63:0]      r_prog_week [63:0];
  reg [7:0]       r_prog_pattern[51:0];
  reg             r_amb_hc;

  // -------------------------------------------
  // --         MODULE INSTANTIATIONS         --
  // -------------------------------------------
  // UUT
  thermostat_top # ( 
    .g_controller_sc_delay_time(p_controller_sc_delay_time),  // : integer := 12000000;  -- Short Cycle Delay, 10 Minutes
    .g_time_clk_freq(p_clk_freq),                             // : integer := 20000;     -- 20KHz
    .g_time_btn_init(p_btn_init),                             // : integer := 20000;     -- 1 second
    .g_time_btn_hold(p_btn_hold),                             // : integer := 5000;      -- 0.25 seconds
    .g_user_ui_idle_time(p_usr_ui_idle)                       // : integer := 100000     -- 5 seconds
  )
  UUT (
    // Clock and Reset
    .i_clk_20KHz(r_clk),            // : in  std_logic;  -- Clock crystal
    .i_reset_n(r_reset_n),          // : in  std_logic;  -- Physical button
    // User Controls
    .i_sys_on_n(r_sys_on_n),        // : in  std_logic;                    -- Physical Switch (2 position), active low
    .i_use_f_n(r_use_f_n),          // : in  std_logic;                    -- Physical Switch (2 position), active low
    .i_run_prog_n(r_run_prog_n),    // : in  std_logic;                    -- Physical Switch (2 position), active low
    .i_force_fan_n(r_force_fan_n),  // : in  std_logic;                    -- Physical Switch (2 position), active low
    .i_heat_cool_n(r_heat_cool_n),  // : in  std_logic_vector(2 downto 0); -- Physical switch (3 position, heat, cool, auto), one-hot active low
    .i_reprogram_n(r_reprogram_n),  // : in  std_logic;                    -- Switch, "disconnects" FPGA from SPI to allow for external SPI control, active low
    .i_set_time_n(r_set_time_n),    // : in  std_logic;                    -- Physical Switch (2 position), active low
    .i_incr_week_n(r_incr_week_n),  // : in  std_logic;                    -- Push button, active low
    .i_incr_day_n(r_incr_day_n),    // : in  std_logic;                    -- Push button, active low
    .i_incr_hr_n(r_incr_hr_n),      // : in  std_logic;                    -- Push button, active low
    .i_incr_min_n(r_incr_min_n),    // : in  std_logic;                    -- Push button, active low
    .i_temp_up_n(r_temp_up_n),      // : in  std_logic;                    -- Push button, active low
    .i_temp_down_n(r_temp_down_n),  // : in  std_logic;                    -- Push button, active low
    // SPI Signals
    .o_spi_clk(w_spi_clk),    // : out std_logic;  -- 10KHz
    .o_spi_cs_n(w_spi_cs_n),  // : out std_logic_vector(1 downto 0);
    .o_spi_si(w_spi_si),      // : out std_logic;
    .i_spi_so(w_spi_so),      // : in  std_logic;
    // 14 Segement display out
    .o_14seg_n_0(w_14seg_n[0]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_1(w_14seg_n[1]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_2(w_14seg_n[2]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_3(w_14seg_n[3]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_4(w_14seg_n[4]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_5(w_14seg_n[5]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_6(w_14seg_n[6]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_7(w_14seg_n[7]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_8(w_14seg_n[8]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_9(w_14seg_n[9]),   // : out std_logic_vector(14 downto 0);
    .o_14seg_n_10(w_14seg_n[10]), // : out std_logic_vector(14 downto 0);
    .o_14seg_n_11(w_14seg_n[11]), // : out std_logic_vector(14 downto 0);
    .o_14seg_n_12(w_14seg_n[12]), // : out std_logic_vector(14 downto 0);
    .o_14seg_n_13(w_14seg_n[13]), // : out std_logic_vector(14 downto 0);
    .o_14seg_n_14(w_14seg_n[14]), // : out std_logic_vector(14 downto 0);
    .o_14seg_n_15(w_14seg_n[15]), // : out std_logic_vector(14 downto 0);
    // LEDs
    .o_day_time_day_n(w_day_time_day_n),  // : out std_logic_vector(6 downto 0);  -- LED indicators to indicate day (Sun-Sat), active low
    .o_prgm_error_n(w_prgm_error_n),      // : out std_logic;  -- Pulled low when schedule's referenecs point to no-valid entries.
    .o_prgm_ovride_n(w_prgm_ovride_n),    // : out std_logic;  -- Pulled low when temporary program override is engaged
    .o_heat_on_n(w_heat_on_n),            // : out std_logic;  -- LED indicators for thermostat mode, active low
    .o_cool_on_n(w_cool_on_n),            // : out std_logic;  -- LED indicators for thermostat mode, active low
    .o_force_fan_n(w_force_fan_n),        // : out std_logic;  -- LED indicators for thermostat mode, active low
    .o_sys_cycling_n(w_sys_cycling_n),    // : out std_logic;  -- LED indicators for thermostat cycling, active low
    // 3-Wire Thermostat Control (4-wire with 24V power source)
    .o_green_fan(w_green_fan),  // : out std_logic;  -- Active high
    .o_yellow_ac(w_yellow_ac),  // : out std_logic;  -- Active high
    .o_white_heat(w_white_heat) // : out std_logic   -- Active high
  );

  // SPI FLASH Model
  wrapper_flash_model flash_0 (
    // Normal SST25VG010A connections
    .i_sck(w_spi_clk),      // : in  std_logic;    -- SPI Clock (20MHz max)
    .i_ce_n(w_spi_cs_n[1]), // : in  std_logic;    -- Chip Enable
    .i_wp_n(1'b1),          // : in  std_logic;    -- Write Protect
    .i_hold_n(1'b1),        // : in  std_logic;    -- Hold
    .i_si(w_spi_si),        // : in  std_logic;    -- SPI In
    .o_so(w_spi_so),        // : out std_logic;    -- SPI Out
    // Additional I/O for simulation/model purposes
    .i_mem(w_mem)           // : in  std_logic_vector(1048575 downto 0)
  );

  // SPI Thermometer Model
  thermometer_model # (
    .g_spi_clk_freq(p_clk_freq/2),
    .g_temp_chg_sec(300)
  ) therm_0 (
    .i_spi_clk(w_spi_clk),
    .i_spi_cs_n(w_spi_cs_n[0]),
    .i_spi_si(w_spi_si),
    .o_spi_so(w_spi_so),
    .i_heat(w_white_heat),
    .i_cool(w_yellow_ac),
    .i_amb_hc(r_amb_hc)
  );

  // --------------------------------------------
  // --            CLOCK GENERATION            --
  // --------------------------------------------
  // System clock generation (20KHz)
  initial r_clk <= 1'b1;
  always #4 r_clk <= ~r_clk;

  // -------------------------------------------
  // --      AMBIENT TEMPERATURE CONTROL      --
  // -------------------------------------------
  // 0:00-7:00:   ambient cool
  // 7:00-19:00:  ambient heat
  // 19:00-24:00: ambient cool
  initial r_amb_hc <= 1'b1;
  always begin
    wait(~w_14seg_n[3] == 15'h106);  // 1
    wait(~w_14seg_n[2] == 15'h222F); // 9
    wait(~w_14seg_n[1] == 15'h113F); // 0
    wait(~w_14seg_n[0] == 15'h113F); // 0
    r_amb_hc <= 1'b0;
    wait(~w_14seg_n[3] == 15'h113F); // 0
    wait(~w_14seg_n[2] == 15'h7);    // 7
    wait(~w_14seg_n[1] == 15'h113F); // 0
    wait(~w_14seg_n[0] == 15'h113F); // 0
    r_amb_hc <= 1'b1;
  end

  // --------------------------------------------
  // --          SCHEDULE ASSIGNMENTS          --
  // --------------------------------------------
  // Assign instances
  generate
    for(g_i = 0; g_i < 63; g_i = g_i + 1) begin
      assign w_mem[((g_i*128)+127):(g_i*128)] = r_prog_instance[g_i];
    end
  endgenerate
  // Reserved
  assign w_mem[8191:8064] = 128'h0;
  // Assign Days
  generate
    for(g_i = 0; g_i < 64; g_i = g_i + 1) begin
      assign w_mem[((g_i*64)+63+8192):((g_i*64)+8192)] = r_prog_day[g_i];
    end
  endgenerate
  // Assign Week
  generate
    for(g_i = 0; g_i < 64; g_i = g_i + 1) begin
      assign w_mem[((g_i*64)+63+12288):((g_i*64)+12288)] = r_prog_week[g_i];
    end
  endgenerate
  // Assign Pattern
  generate
    for(g_i = 0; g_i < 52; g_i = g_i + 1) begin
      assign w_mem[((g_i*8)+7+16384):((g_i*8)+16384)] = r_prog_pattern[g_i];
    end
  endgenerate
  // Reserved
  assign w_mem[16895:16800] = 96'h0;
  assign w_mem[1048575:16896] = 1031680'h0;

  // --------------------------------------------
  // --             TEST PROCEDURE             --
  // --------------------------------------------
  initial begin
    // Set initial values
    r_reset_n     <= 1'b1;
    r_sys_on_n    <= 1'b1;
    r_use_f_n     <= 1'b0;
    r_run_prog_n  <= 1'b1;
    r_force_fan_n <= 1'b1;
    r_heat_cool_n <= 3'b110;
    r_reprogram_n <= 1'b1;
    r_set_time_n  <= 1'b1;
    r_incr_week_n <= 1'b1;
    r_incr_day_n  <= 1'b1;
    r_incr_hr_n   <= 1'b1;
    r_incr_min_n  <= 1'b1;
    r_temp_up_n   <= 1'b1;
    r_temp_down_n <= 1'b1;

    // Populate program instance register
    for(i = 0; i < 63; i = i + 1) begin
      if(i == 1) begin
        // 5AM-7AM, heat to 68F
        r_prog_instance[i] <= 128'h8008_1412_0000_0000_0000_0000_0FF0_0000;
      end
      else if (i == 7) begin
        // 5:30PM-10PM, cool to 74F
        r_prog_instance[i] <= 128'h8004_1B18_00FF_FFC0_0000_0000_0000_0000;
      end
      else if (i == 19) begin
        // All day, auto @ 70, force fan
        r_prog_instance[i] <= 128'h800E_1614_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
      end
      else begin
      r_prog_instance[i] <= 128'h0;
      end
    end
    // Populate program day register
    for(i = 0; i < 64; i = i + 1) begin
      if(i == 2) begin
        // Set Day 2 to instance 1 and 7
        r_prog_day[i] <= 64'h8000_0000_0000_0082;
      end
      else if (i == 37) begin
        // Set Day 37 to instance 19
        r_prog_day[i] <= 64'h8000_0000_0008_0000;
      end
      else if (i == 0) begin
        // Set day 0 to instance 1, 7, and 19, this is to check error overlaping intervals
        r_prog_day[i] <= 64'h8000_0000_0008_0082;
      end
      else begin
        r_prog_day[i] <= 64'h0;
      end
    end
    // Populate program week register
    for(i = 0; i < 64; i = i + 1) begin
      if(i == 5) begin
        // Mon-Thurs weekday, Fri-Sun weekend
        r_prog_week[i] <= 64'h8025_2502_0202_0225;
      end
      else if (i == 45) begin
        // Normal Weekday/weekend schedule
        r_prog_week[i] <= 64'h8025_0202_0202_0225;
      end
      else begin
        r_prog_week[i] <= 64'h0;
      end
    end
    // Populate program pattern register
    for(i = 0; i < 52; i = i + 1) begin
      if(i == 0) begin
        // Point to Mon-Thurs weekday, Fri-Sun weekend
        r_prog_pattern[i] <= 8'h45;
      end
      else if(i == 1) begin
        // Point to Normal weekday/weekend
        r_prog_pattern[i] <= 8'h6D;
      end
      else begin
        r_prog_pattern[i] <= 8'h0;
      end
    end

    // Run Test
    // Let time run for 5 "seconds", then begin setting time
    repeat(p_clk_freq*5) @(posedge r_clk);
    $display("Running Test, approximately 150 seconds are simulated...");
    $display("Simulation may take 20 minutes to complete...");
    $display("Setting time...");
    r_set_time_n  <= 1'b0;
    r_incr_day_n  <= 1'b0;
    r_incr_hr_n   <= 1'b0;
    r_incr_min_n  <= 1'b0;
    // Set time to Thursday, 4:37PM (16:37)
    wait(~w_day_time_day_n == 7'b0010000); // Thursday
    r_incr_day_n <= 1'b1;
    wait(~w_14seg_n[3] == 15'h106);  // 1
    wait(~w_14seg_n[2] == 15'h223D); // 6
    r_incr_hr_n <= 1'b1;
    wait(~w_14seg_n[1] == 15'h20F);  // 3
    wait(~w_14seg_n[0] == 15'h7);    // 7
    r_incr_min_n  <= 1'b1;
    repeat(p_clk_freq*5) @(posedge r_clk);
    r_set_time_n <= 1'b1;
    $display("Time Set.");
    // Wait 5 "seconds", then turn system on and set program mode
    repeat(p_clk_freq*5) @(posedge r_clk);
    $display("Engaging system in program mode...");
    r_sys_on_n    <= 1'b0;
    r_run_prog_n  <= 1'b0;
    // Run until Sunday, 09:45, then engage override mode.
    wait(~w_day_time_day_n == 7'h1);
    wait(~w_14seg_n[3] == 15'h113F);  // 0
    wait(~w_14seg_n[2] == 15'h222F);  // 9
    wait(~w_14seg_n[1] == 15'h2226);  // 4
    wait(~w_14seg_n[0] == 15'h222D);  // 5
    $display("Setting override mode, to 78F; Schedule should resume at Monday, 12:00...");
    r_temp_up_n <= 1'b0;
    wait(~w_14seg_n[15] == 15'h7);    // 7
    wait(~w_14seg_n[14] == 15'h223F); // 8
    r_temp_up_n <= 1'b1;
    // Run until following Sunday, 16:33, then engage manual mode @ cool 68
    wait(~w_day_time_day_n == 7'h4);  // wait for tuesday
    wait(~w_day_time_day_n == 7'h1);  // wait for sunday
    wait(~w_14seg_n[3] == 15'h106);   // 1
    wait(~w_14seg_n[2] == 15'h223D);  // 6
    wait(~w_14seg_n[1] == 15'h20F);   // 3
    wait(~w_14seg_n[0] == 15'h20F);   // 3
    // Manipulate user controls w/ wait times
    r_run_prog_n  <= 1'b1;
    repeat(p_clk_freq*2) @(posedge r_clk);
    r_heat_cool_n <= 3'b101;
    repeat(p_clk_freq*2) @(posedge r_clk);
    r_temp_down_n <= 1'b0;
    wait(~w_14seg_n[15] == 15'h223D); // 6
    wait(~w_14seg_n[14] == 15'h223F); // 8
    r_temp_down_n <= 1'b1;
    // Run until next-next Monday, 12:31
    wait(~w_day_time_day_n == 7'h2); // run until monday
    wait(~w_14seg_n[3] == 15'h106);  // 1
    wait(~w_14seg_n[2] == 15'h221B); // 2
    wait(~w_14seg_n[1] == 15'h20F);  // 3
    wait(~w_14seg_n[0] == 15'h106);  // 1
    $stop;
  end

endmodule
