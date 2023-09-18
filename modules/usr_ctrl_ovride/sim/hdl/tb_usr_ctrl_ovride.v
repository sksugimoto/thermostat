// tb_usr_ctrl_ovride.v
// Author: Samuel Sugimoto
// Date: 

// Testbench for usr_ctrl_ovride module

`timescale 1us/1us

module testbench;
  // Parameters
  parameter p_clk_freq = 50;
  parameter p_btn_init = 50;
  parameter p_btn_hold = 10;
  parameter p_ui_idle_time = 5 * p_clk_freq;
  parameter[31:0] p_stc_heat  = 32'h41F1C;  // Heat on @ 78F (25.5C)
  parameter[31:0] p_stc_cool  = 32'h21412;  // Cool on @ 68F (20.0C)
  parameter[31:0] p_stc_auto  = 32'h61816;  // Auto on @ 72F (22.0C)
  parameter[31:0] p_stc_off   = 32'h0;      // Heat and Cool off.

  // User Control and Overide signals
  reg         r_clk;
  reg         r_reset_n;
  reg[31:0]   r_prog_stc;
  reg[6:-2]   r_temp;
  reg         r_use_f;
  reg         r_sys_pwr_n;
  reg         r_run_prog_n;
  reg[2:0]    r_heat_cool_n;
  reg         r_t_down_n;
  reg         r_t_up_n;
  wire[31:0]  w_man_stc;
  
  integer j;

  // -------------------------------------------
  // --         MODULE INSTANTIATIONS         --
  // -------------------------------------------
  wrapper_usr_ctrl_ovride # (
    .g_ui_idle_time(p_ui_idle_time),
    .g_clk_freq(p_clk_freq),
    .g_btn_init(p_btn_init),
    .g_btn_hold(p_btn_hold)
  )
  UUT (
    // Clock and Reset
    .i_clk(r_clk),                  // : std_logic;
    .i_reset_n(r_reset_n),          // : std_logic;
    // Scheduler STC Input
    .i_prog_stc(r_prog_stc),        // : std_logic_vector(31 downto 0);
    .i_temp(r_temp),                // : ufixed(6 downto -2);
    // User Interface
    .i_use_f(r_use_f),              // : std_logic;
    .i_sys_pwr_n(r_sys_pwr_n),      // : std_logic;
    .i_run_prog_n(r_run_prog_n),    // : std_logic;
    .i_heat_cool_n(r_heat_cool_n),  // : std_logic_vector(2 downto 0);   -- 2: heat; 1: cool; 0: auto
    .i_t_down_n(r_t_down_n),        // : std_logic;  -- Push Button, Active Low
    .i_t_up_n(r_t_up_n),            // : std_logic;  -- Push Button, Active Low
    // Controller Interface
    .o_stc(w_man_stc)               // : std_logic_vector(31 downto 0)   -- Should only update after user controls have been idle for X seconds
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
    r_reset_n     <= 1'b1;
    r_prog_stc    <= p_stc_off;
    r_temp        <= 9'h118;  // 70F
    r_use_f       <= 1'b1;
    r_sys_pwr_n   <= 1'b1;  // System off
    r_run_prog_n  <= 1'b1;  // Manual Mode
    r_heat_cool_n <= 3'h6;  // Auto mode
    r_t_down_n    <= 1'b1;
    r_t_up_n      <= 1'b1;

    // // Deassert reset
    // repeat(p_clk_freq) @(posedge r_clk);
    // r_reset_n <= 1'b1;

    // Let time run for 10 "seconds", then begin test
    repeat(p_clk_freq*10) @(posedge r_clk);
    // Set system on in manual mode, then set temperature in F
    r_sys_pwr_n   <= 1'b0;
    r_run_prog_n  <= 1'b1;
    repeat(p_clk_freq*10) @(posedge r_clk);
    for(j = 0; j < 4; j = j + 1) begin
      @(posedge r_clk) r_t_up_n <= 1'b0;
      @(posedge r_clk) r_t_up_n <= 1'b1;
    end

    // Let time run for 10 "seconds"
    repeat(p_clk_freq*10) @(posedge r_clk);
    // Test push and hold functionality; both buttons pressed, then one released.
    @(posedge r_clk) r_t_up_n <= 1'b0;
    @(posedge r_clk) r_t_down_n <= 1'b0;
    repeat(p_clk_freq*10) @(posedge r_clk);
    r_t_up_n <= 1'b1;
    repeat(p_clk_freq*2) @(posedge r_clk);
    r_t_down_n <= 1'b1;
    r_heat_cool_n <= 3'h5;  // Set to cool

    // Let time run for 2 "seconds", then set temperature in C
    repeat(p_clk_freq*2) @(posedge r_clk);
    r_use_f <= 1'b0;
    r_temp  <= 9'h54;
    
    // Let time run for 10 "seconds"
    repeat(p_clk_freq*10) @(posedge r_clk);
    for(j = 0; j < 4; j = j + 1) begin
      @(posedge r_clk) r_t_up_n <= 1'b0;
      @(posedge r_clk) r_t_up_n <= 1'b1;
    end

    // Let time run for 10 "seconds"
    repeat(p_clk_freq*10) @(posedge r_clk);

    // Turn system off, then try push buttons
    r_sys_pwr_n   <= 1'b1;
    repeat(p_clk_freq*2) @(posedge r_clk);
    for(j = 0; j < 4; j = j + 1) begin
      @(posedge r_clk) r_t_up_n <= 1'b0;
      @(posedge r_clk) r_t_up_n <= 1'b1;
    end
    // Let time run for 10 "seconds", then turn system on
    repeat(p_clk_freq*10) @(posedge r_clk);
    r_sys_pwr_n <= 1'b0;
    // Let time run for 10 "seconds", then switch to program mode
    repeat(p_clk_freq*10) @(posedge r_clk);
    r_run_prog_n  <= 1'b0;
    r_prog_stc    <= p_stc_heat;
    // Let time run for 10 "seconds", then switch to push buttons for override mode
    repeat(p_clk_freq*10) @(posedge r_clk);
    r_t_up_n <= 1'b0;
    repeat(p_clk_freq*2) @(posedge r_clk);
    r_t_up_n <= 1'b1;

    // Let time run for 10 "seconds", then switch program stc
    repeat(p_clk_freq*10) @(posedge r_clk);
    r_prog_stc <= p_stc_auto;

    // Let time run for 10 "seconds"
    repeat(p_clk_freq*10) @(posedge r_clk);

    // Turn system on, then set to 
    $stop;
  end
endmodule
