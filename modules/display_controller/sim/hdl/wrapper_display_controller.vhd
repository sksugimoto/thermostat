-- wrapper_display_controller.vhd
-- Author: Samuel Sugimoto
-- Date: 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.fixed_pkg.all;

library work;
use work.stc_package.all;
use work.time_package.all;
use work.global_package.all;

entity wrapper_display_controller is
port (
  i_reset_n       : in  std_logic;
  -- Date and Time control
  i_set_time_n    : in  std_logic;
  i_day           : in  std_logic_vector(6 downto 0);
  i_hour          : in  std_logic_vector(4 downto 0);
  i_minute        : in  std_logic_vector(5 downto 0);
  i_second        : in  std_logic_vector(5 downto 0);
  i_fsecond       : in  std_logic_vector(14 downto 0);
  -- Thermostat user controls
  i_use_f         : in  std_logic;
  i_sys_on_n      : in  std_logic;
  i_reprogram_n   : in  std_logic;
  i_prog_read     : in  std_logic;
  i_run_prog_n    : in  std_logic;
  -- Thermostat settings
  i_temperature   : in  ufixed(6 downto -2);
  i_prog_stc      : in  std_logic_vector(31 downto 0);
  i_man_stc       : in  std_logic_vector(31 downto 0);
  -- Display output
  o_14seg_cntrls  : out t_array_slv16(15 downto 0)
);
end entity wrapper_display_controller;

architecture wrapper_display_controller of wrapper_display_controller is
  signal s_day_time : t_day_time;
  signal s_14seg_cntrls : std_logic_vector(255 downto 0);
begin
  disp_ctrl : entity work.display_controller
  port map (
    i_reset_n       => i_reset_n,
    -- Date and Time control
    i_set_time_n    => i_set_time_n,
    i_day_time      => s_day_time,
    -- Thermostat user controls
    i_use_f         => i_use_f,
    i_sys_on_n      => i_sys_on_n,
    i_reprogram_n   => i_reprogram_n,
    i_prog_read     => i_prog_read,
    i_run_prog_n    => i_run_prog_n,
    -- Thermostat settings
    i_temperature   => i_temperature,
    i_prog_stc      => slv_to_stc(i_prog_stc),
    i_man_stc       => slv_to_stc(i_man_stc),
    -- Display output
    o_14seg_cntrls  => s_14seg_cntrls
  );

  -- slv to day/time record
  s_day_time.day      <= i_day;
  s_day_time.hour     <= to_integer(unsigned(i_hour));
  s_day_time.minute   <= to_integer(unsigned(i_minute));
  s_day_time.second   <= to_integer(unsigned(i_second));
  s_day_time.fsecond  <= to_integer(unsigned(i_fsecond));
  -- slv to 2d-slv
  g_14seg : for i in 0 to 15 generate
    o_14seg_cntrls(((i*16)+15) downto (i*16)) <= s_14seg_cntrls(i);
  end generate;
end architecture;
