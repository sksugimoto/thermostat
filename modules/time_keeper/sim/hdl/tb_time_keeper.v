// tb_time_keeper.v
// Author: Samuel Sugimoto
// Date: 

// Testbench for time keeping module

`timescale 1us/1us

module testbench;
  // Parameters
  parameter p_clk_freq = 5;
  parameter p_btn_init = 5;
  parameter p_btn_hold = 1;

  // Time Keeper signals
  reg       r_clk;
  reg       r_reset_n;
  reg       r_set_time_n;
  reg       r_incr_day_n;
  reg       r_incr_hr_n;
  reg       r_incr_min_n;
  wire[6:0] w_day;
  wire[4:0] w_hour;
  wire[5:0] w_minute;
  wire[5:0] w_second;

  time_keeper # (
    // Set to different value for simulation
    .g_clk_freq(p_clk_freq),  // : integer := 20000;
    .g_btn_init(p_btn_init),  // : integer := 20000;
    .g_btn_hold(p_btn_hold)   // : integer := 5000
  )
  UUT (
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
    .o_second(w_second)
  );

  // --------------------------------------------
  // --            CLOCK GENERATION            --
  // --------------------------------------------
  // System clock generation (20KHz)
  initial r_clk <= 1'b1;
  always #25 r_clk <= ~r_clk;

  // --------------------------------------------
  // --             TEST PROCEDURE             --
  // --------------------------------------------
  initial begin
    // Set initial values
    r_reset_n <= 1'b1;
    r_set_time_n  <= 1'b1;
    r_incr_day_n  <= 1'b1;
    r_incr_hr_n   <= 1'b1;
    r_incr_min_n  <= 1'b1;

    // Let time run for 5 "seconds", then begin setting time
    repeat(p_clk_freq*5) @(posedge r_clk);
    r_set_time_n  <= 1'b0;
    r_incr_day_n  <= 1'b0;
    r_incr_hr_n   <= 1'b0;
    r_incr_min_n  <= 1'b0;
    wait(w_day == 7'b1000000); // Saturday
    r_incr_day_n <= 1'b1;
    wait(w_hour == 5'h10);    // 16 Hours (4PM)
    r_incr_hr_n <= 1'b1;
    wait(w_minute == 6'h25);  // 37 minutes (Saturday, 4:37PM)
    r_incr_min_n  <= 1'b1;
    r_set_time_n  <= 1'b1;
    wait(w_day == 7'b1);
    wait(w_hour == 5'h11);
    wait(w_minute == 6'h1);   // Wait for Sunday, 5:01 PM
    repeat(25*p_clk_freq) @(posedge r_clk);
    $stop;
  end

endmodule
