// tb_display_controller.v
// Author: Samuel Sugimoto
// Date:

`timescale 1us/1us

module testbench;
  // Parameters
  parameter p_clk_freq = 4;
  parameter p_clk_freq = 4;
  parameter p_btn_hold = 1;
  // Display controller signals
  reg         r_reset_n;
  reg         r_set_time_n;
  wire[6:0]   w_day;
  wire[4:0]   w_hour;
  wire[5:0]   w_minute;
  wire[5:0]   w_second;
  wire[14:0]  w_fsecond;
  reg         r_use_f;
  reg         r_sys_on_n;
  reg         r_reprogram_n;
  reg         r_prog_read;
  reg         r_run_prog_n;
  reg [6:-2]  r_temperature;
  reg [31:0]  r_prog_stc;
  reg [31:0]  r_man_stc;
  wire[255:0] w_14seg_cntrls;
  // Time keeper signals
  reg         r_clk;
  reg         r_set_time_n;
  reg         r_incr_day_n;
  reg         r_incr_hr_n;
  reg         r_incr_min_n;

  // -------------------------------------------
  // --         MODULE INSTANTIATIONS         --
  // -------------------------------------------
  // UUT
  wrapper_display_controller UUT (
    .i_reset_n(r_reset_n),          // : in  std_logic;
    // Date and Time control
    .i_set_time_n(r_set_time_n),    // : in  std_logic;
    .i_day(w_day),                  // : in  std_logic_vector(6 downto 0);
    .i_hour(w_hour),                // : in  std_logic_vector(4 downto 0);
    .i_minute(w_minute),            // : in  std_logic_vector(5 downto 0);
    .i_second(w_second),            // : in  std_logic_vector(5 downto 0);
    .i_fsecond(w_fsecond),          // : in  std_logic_vector(14 downto 0);
    // Thermostat user controls
    .i_use_f(r_use_f),              // : in  std_logic;
    .i_sys_on_n(r_sys_on_n),        // : in  std_logic;
    .i_reprogram_n(r_reprogram_n),  // : in  std_logic;
    .i_prog_read(r_prog_read),      // : in  std_logic;
    .i_run_prog_n(r_run_prog_n),    // : in  std_logic;
    // Thermostat settings
    .i_temperature(r_temperature),  // : in  ufixed(6 downto -2);
    .i_prog_stc(r_prog_stc),        // : in  std_logic_vector(31 downto 0);
    .i_man_stc(r_man_stc),          // : in  std_logic_vector(31 downto 0);
    // Display output
    .o_14seg_cntrls(w_14seg_cntrls) // : out t_array_slv16(15 downto 0)
  );

  // Time Module
  wrapper_time_keeper # (
    // Set to different value for simulation
    .g_clk_freq(p_clk_freq),  // : integer := 20000;
    .g_btn_init(p_btn_init),  // : integer := 20000;
    .g_btn_hold(p_btn_hold)   // : integer := 5000
  )
  time_keeper_0 (
    // Clock and Reset
    .i_clk(r_clk),          // : in  std_logic;  -- 20KHz clock
    .i_reset_n(r_reset_n),  // : in  std_logic;

    // User Interface
    .i_set_time_n(r_set_time_n),  // : in  std_logic;  -- Active Low
    .i_incr_day_n(r_incr_day_n),  // : in  std_logic;  -- Active Low
    .i_incr_hr_n(r_incr_hr_n),    // : in  std_logic;  -- Active Low
    .i_incr_min_n(r_incr_min_n),  // : in  std_logic;  -- Active Low

    // Time
    .o_day(w_day),        // : out std_logic_vector(6 downto 0); -- One-hot reference to day
    .o_hour(w_hour),      // : out std_logic_vector(4 downto 0);
    .o_minute(w_minute),  // : out std_logic_vector(5 downto 0);
    .o_second(w_second),
    .o_fsecond(w_fsecond)
  );

  // --------------------------------------------
  // --            CLOCK GENERATION            --
  // --------------------------------------------
  // System clock generation (20KHz)
  initial r_clk <= 1'b1;
  always #4 r_clk <= ~r_clk;

  // --------------------------------------------
  // --             TEST PROCEDURE             --
  // --------------------------------------------
  initial begin
    // Set initial values
    r_reset_n     <= 1'b1;
    r_set_time_n  <= 1'b1;
    r_incr_day_n  <= 1'b1;
    r_incr_hr_n   <= 1'b1;
    r_incr_min_n  <= 1'b1;
    r_use_f       <= 1'b1;
    r_sys_on_n    <= 1'b1; // System off
    r_reprogram_n <= 1'b1;
    r_prog_read   <= 1'b1;
    r_run_prog_n  <= 1'b1;
    r_temperature <= 9'h0;
    r_prog_stc    <= 32'h0;
    r_man_stc     <= 32'h0;
  end
endmodule
