-- time_package.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package time_package is
  type t_day_time is record
    day     : std_logic_vector(6 downto 0);  -- 1-hot reference to day, 0: sunday, 1: monday, 6: saturday
    hour    : integer;
    minute  : integer;
    second  : integer;
    fsecond : integer;
  end record t_day_time;

  function constr_daytime (
    i_slv_day   : in std_logic_vector(6 downto 0) := 7x"1";
    i_n_hour    : in integer := 0;
    i_n_minute  : in integer := 0;
    i_n_second  : in integer := 0;
    i_n_fsecond : in integer := 0
  ) return t_day_time;

  constant c_day_time_zero : t_day_time := (
    day     => 7x"1",
    hour    => 0,
    minute  => 0,
    second  => 0,
    fsecond => 0
  );
end package;

package body time_package is
  function constr_daytime (
    i_slv_day   : in std_logic_vector(6 downto 0) := 7x"1";
    i_n_hour    : in integer := 0;
    i_n_minute  : in integer := 0;
    i_n_second  : in integer := 0;
    i_n_fsecond : in integer := 0
  ) return t_day_time is
    variable v_daytime : t_day_time;
  begin
    v_daytime.day     := i_slv_day;
    v_daytime.hour    := i_n_hour;
    v_daytime.minute  := i_n_minute;
    v_daytime.second  := i_n_second;
    v_daytime.fsecond := i_n_fsecond;
    return v_daytime;
  end;
end package body time_package;
