// tb_scheduler_control.v
// Author: Samuel Sugimoto
// Date:

// Testbench for the scheduler_control module

`timescale 1us/1us

module testbench;
  // Parameters
  parameter p_clk_freq = 4;
  parameter p_btn_init = 4;
  parameter p_btn_hold = 1;

  // Scheduler Control signals
  reg           r_clk;
  reg           r_reset_n;
  reg           r_sys_pwr_n;
  reg           r_run_prog_n;
  reg           r_reprogram_n;
  reg           r_set_time_n;
  reg           r_incr_week_n;
  wire[16895:0] w_prog_data;
  reg [127:0]   r_prog_instance [62:0];
  reg [63:0]    r_prog_day  [63:0];
  reg [63:0]    r_prog_week [63:0];
  reg [7:0]     r_prog_pattern[51:0];
  wire[6:0]     w_day;
  wire[4:0]     w_hour;
  wire[5:0]     w_minute;
  wire[5:0]     w_second;
  wire[14:0]    w_fsecond;
  wire          w_program_error;
  wire[31:0]    w_program_stc;
  integer       i;
  genvar        g_i;

  // Time keeper signals
  reg r_incr_day_n;
  reg r_incr_hr_n;
  reg r_incr_min_n;

  // UUT
  wrapper_scheduler_control # (
    .g_clk_freq(p_clk_freq)
  )
  UUT (
    // Clock and Reset
    .i_clk(r_clk),                  // : in  std_logic;
    .i_reset_n(r_reset_n),          // : in  std_logic;
    // Scheduler Controller
    .i_sys_pwr_n(r_sys_pwr_n),      // : in  std_logic;
    .i_run_prog_n(r_run_prog_n),    // : in  std_logic;
    .i_reprogram_n(r_reprogram_n),  // : in  std_logic;
    .i_set_time_n(r_set_time_n),    // : in  std_logic;
    .i_incr_week_n(r_incr_week_n),  // : in  std_logic;
    .i_slv_prog(w_prog_data),       // : in  std_logic_vector(16895 downto 0);
    .i_day(w_day),                  // : in  std_logic_vector(6 downto 0);
    .i_hour(w_hour),                // : in  std_logic_vector(4 downto 0);
    .i_minute(w_minute),            // : in  std_logic_vector(5 downto 0);
    .i_second(w_second),            // : in  std_logic_vector(5 downto 0);
    .i_fsecond(w_fsecond),          // : in  std_logic_vector(14 downto 0);
    // STC to Controller
    .o_program_error(w_program_error),  // : out std_logic;
    .o_program_stc(w_program_stc)       // : out std_logic_vector(31 downto 0)
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
  // --          SCHEDULE ASSIGNMENTS          --
  // --------------------------------------------
  // Assign instances
  generate
    for(g_i = 0; g_i < 63; g_i = g_i + 1) begin
      assign w_prog_data[((g_i*128)+127):(g_i*128)] = r_prog_instance[g_i];
    end
  endgenerate
  // Reserved
  assign w_prog_data[8191:8064] = 128'h0;
  // Assign Days
  generate
    for(g_i = 0; g_i < 64; g_i = g_i + 1) begin
      assign w_prog_data[((g_i*64)+63+8192):((g_i*64)+8192)] = r_prog_day[g_i];
    end
  endgenerate
  // Assign Week
  generate
    for(g_i = 0; g_i < 64; g_i = g_i + 1) begin
      assign w_prog_data[((g_i*64)+63+12288):((g_i*64)+12288)] = r_prog_week[g_i];
    end
  endgenerate
  // Assign Pattern
  generate
    for(g_i = 0; g_i < 52; g_i = g_i + 1) begin
      assign w_prog_data[((g_i*8)+7+16384):((g_i*8)+16384)] = r_prog_pattern[g_i];
    end
  endgenerate
  // Reserved
  assign w_prog_data[16895:16800] = 96'h0;

  // --------------------------------------------
  // --             TEST PROCEDURE             --
  // --------------------------------------------
  initial begin
    // Set initial values
    r_reset_n     <= 1'b1;
    r_sys_pwr_n   <= 1'b1;
    r_run_prog_n  <= 1'b1;
    r_reprogram_n <= 1'b1;
    r_set_time_n  <= 1'b1;
    r_incr_week_n <= 1'b1;
    r_incr_day_n  <= 1'b1;
    r_incr_hr_n   <= 1'b1;
    r_incr_min_n  <= 1'b1;
    // Populate program instance register
    for(i = 0; i < 63; i = i + 1) begin
      if(i == 1) begin
        // 5AM-8AM, heat to 68F
        r_prog_instance[i] <= 128'h8008_1412_0000_0000_0000_0000_FFF0_0000;
      end
      else if (i == 7) begin
        // 5:30PM-11PM, cool to 74F
        r_prog_instance[i] <= 128'h8004_1B18_0FFF_FFC0_0000_0000_0000_0000;
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
    r_set_time_n  <= 1'b0;
    r_incr_day_n  <= 1'b0;
    r_incr_hr_n   <= 1'b0;
    r_incr_min_n  <= 1'b0;
    wait(w_day == 7'b0010000); // Thursday
    r_incr_day_n <= 1'b1;
    wait(w_hour == 5'h10);    // 16 Hours (4PM)
    r_incr_hr_n <= 1'b1;
    wait(w_minute == 6'h25);  // 37 minutes (Saturday, 4:37PM)
    r_incr_min_n  <= 1'b1;
    repeat(p_clk_freq*5) @(posedge r_clk);
    r_set_time_n <= 1'b1;
    // Wait 5 "seconds", then turn system on and set program mode
    repeat(p_clk_freq*5) @(posedge r_clk);
    r_sys_pwr_n   <= 1'b0;
    r_run_prog_n  <= 1'b0;
    // Run until Monday, 18:15
    wait(w_day == 7'h2);
    wait(w_hour == 5'h12);
    wait(w_minute == 6'hF);
    // Run until Monday, 12:31
    wait(w_day == 7'h4);
    wait(w_day == 7'h2);
    wait(w_hour == 5'd12);
    wait(w_minute == 6'd31);
    $stop;
  end
endmodule
