-- wrapper_usr_ctrl_ovride.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Wrapper moudle for usr_ctrl_ovride module

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.stc_package.all;

entity wrapper_usr_ctrl_ovride is
generic (
  -- # of clock cycles elapsed after last user input before o_stc is updated
  -- Set to 5 seconds for deployment (20,000*5 = 100,000 cycles).
  g_ui_idle_time  : integer := 100000;
  -- Set to different value for simulation
  g_clk_freq  : integer := 20000;
  g_btn_init  : integer := 20000;
  g_btn_hold  : integer := 5000
);
port (
  -- Clock and Reset
  i_clk         : in  std_logic;
  i_reset_n     : in  std_logic;
  -- Scheduler STC Input
  i_prog_stc    : in  std_logic_vector(31 downto 0);
  i_temp        : in  ufixed(6 downto -2);
  -- User Interface
  i_use_f       : in  std_logic;
  i_sys_pwr_n   : in  std_logic;
  i_run_prog_n  : in  std_logic;
  i_heat_cool_n : in  std_logic_vector(2 downto 0);   -- 2: heat; 1: cool; 0: auto
  i_t_down_n    : in  std_logic;  -- Push Button, Active Low
  i_t_up_n      : in  std_logic;  -- Push Button, Active Low
  -- Controller Interface
  o_stc         : out std_logic_vector(31 downto 0)   -- Should only update after user controls have been idle for X seconds
);
end entity wrapper_usr_ctrl_ovride;

architecture wrapper_usr_ctrl_ovride of wrapper_usr_ctrl_ovride is
  signal s_man_stc : t_stc;
begin
  usr_control : entity work.usr_ctrl_ovride
  generic map (
    -- # of clock cycles elapsed after last user input before o_stc is updated
    -- Set to 5 seconds for deployment (20,000*5 = 100,000 cycles).
    g_ui_idle_time  => g_ui_idle_time,
    -- Set to different value for simulation
    g_clk_freq  => g_clk_freq,
    g_btn_init  => g_btn_init,
    g_btn_hold  => g_btn_hold
  )
  port map (
    -- Clock and Reset
    i_clk         => i_clk,
    i_reset_n     => i_reset_n,
    -- Scheduler STC Input
    i_prog_stc    => slv_to_stc(i_prog_stc),
    i_temp        => i_temp,
    -- User Interface
    i_use_f       => i_use_f,
    i_sys_pwr_n   => i_sys_pwr_n,
    i_run_prog_n  => i_run_prog_n,
    i_heat_cool_n => i_heat_cool_n,
    i_t_down_n    => i_t_down_n,
    i_t_up_n      => i_t_up_n,
    -- Controller Interface
    o_stc         => s_man_stc
  );
  o_stc <= stc_to_slv(s_man_stc);
end architecture;
