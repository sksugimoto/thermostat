-- wrapper_time_keeper.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.time_package.all;

entity wrapper_time_keeper is
generic (
  -- Set to different value for simulation
  g_clk_freq  : integer := 20000;
  g_btn_init  : integer := 20000;
  g_btn_hold  : integer := 5000
);
port (
  -- Clock and Reset
  i_clk         : in  std_logic;  -- 20KHz clock
  i_reset_n     : in  std_logic;

  -- User Interface
  i_set_time_n  : in  std_logic;  -- Active Low
  i_incr_day_n  : in  std_logic;  -- Active Low
  i_incr_hr_n   : in  std_logic;  -- Active Low
  i_incr_min_n  : in  std_logic;  -- Active Low

  -- Time
  o_day         : out std_logic_vector(6 downto 0); -- One-hot reference to day
  o_hour        : out std_logic_vector(4 downto 0);
  o_minute      : out std_logic_vector(5 downto 0);
  o_second      : out std_logic_vector(5 downto 0)
);
end entity wrapper_time_keeper;

architecture wrapper_time_keeper of wrapper_time_keeper is
  signal s_day_time : t_day_time := c_day_time_zero;
begin
  time_keeper_0 : entity work.time_keeper
  generic map (
    -- Set to different value for simulation
    g_clk_freq  => g_clk_freq,
    g_btn_init  => g_btn_init,
    g_btn_hold  => g_btn_hold
  )
  port map (
    -- Clock and Reset
    i_clk         => i_clk,     -- 20KHz clock
    i_reset_n     => i_reset_n,

    -- User Interface
    i_set_time_n  => i_set_time_n,  -- Active Low
    i_incr_day_n  => i_incr_day_n,  -- Active Low
    i_incr_hr_n   => i_incr_hr_n,   -- Active Low
    i_incr_min_n  => i_incr_min_n,  -- Active Low

    -- Time
    o_day_time    => s_day_time
  );

  o_day     <= s_day_time.day;
  o_hour    <= std_logic_vector(to_unsigned(s_day_time.hour, o_hour'length));
  o_minute  <= std_logic_vector(to_unsigned(s_day_time.minute, o_minute'length));
  o_second  <= std_logic_vector(to_unsigned(s_day_time.second, o_second'length));
end architecture;
