-- global_package.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Package for types utilzied in thermostat control.

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

package stc_package is
  -- Standard Thermostat Configuration (STC) Record Definition
  -- Universal configuration record for controlling the thermostat
  -- Setting both heat and cool to high indicates "Auto" mode.
  -- Force Fan:     Configures air fan to run constantly regardless of heat or cool status
  --                Active high
  -- Heat On:       Configures furnace operation; Active high
  -- Cool On:       Configures compressor operation; Active high
  -- trgt_x_ofst: Thermostat's target temperature, in Celsius or Fahrenheit
  type t_stc is record
    heat_on     : std_logic;
    cool_on     : std_logic;
    force_fan   : std_logic;
    trgt_c_ofst : integer;
    trgt_f_ofst : integer;
  end record t_stc;

  function stc_to_slv (
    i_stc_t : in  t_stc
  ) return std_logic_vector;

  function slv_to_stc (
    i_slv_stc : in  std_logic_vector(31 downto 0)
  ) return t_stc;

  function stc_offset_c_to_f (
    i_c_offset : in integer
  ) return integer;

  function stc_offset_f_to_c (
    i_f_offset : in integer
  ) return integer;

  constant c_stc_idle : t_stc := (
    heat_on     => '0',
    cool_on     => '0',
    force_fan   => '0',
    trgt_c_ofst => 0,
    trgt_f_ofst => 0
  );
end package stc_package;

package body stc_package is
  -- Converts stc to a 32-bit wide slv.
  function stc_to_slv (
    i_stc_t : in t_stc
  ) return std_logic_vector is
    variable v_converted_stc  : std_logic_vector(31 downto 0);
  begin
    v_converted_stc :=  13x"0"            &   -- Reserved
                        i_stc_t.heat_on   &
                        i_stc_t.cool_on   &
                        i_stc_t.force_fan &
                        2x"0"             &   -- Reserved
                        std_logic_vector(to_unsigned(i_stc_t.trgt_c_ofst, 6)) &
                        2x"0"             &   -- Reserved
                        std_logic_vector(to_unsigned(i_stc_t.trgt_f_ofst, 6));
    return v_converted_stc;
  end;

  -- Converts 32-bit wide slv to stc
  function slv_to_stc (
    i_slv_stc : in std_logic_vector(31 downto 0)
  ) return t_stc is
    variable v_stc : t_stc;
  begin
    v_stc.heat_on := i_slv_stc(18);
    v_stc.cool_on := i_slv_stc(17);
    v_stc.force_fan := i_slv_stc(16);
    v_stc.trgt_c_ofst := to_integer(unsigned(i_slv_stc(13 downto 8)));
    v_stc.trgt_f_ofst := to_integer(unsigned(i_slv_stc(5 downto 0)));
    return v_stc;
  end ;

  -- Converts Celsius offset to Fahrenheit offset (F = 1.8*C + 32)
  function stc_offset_c_to_f (
    i_c_offset : in integer
  ) return integer is
    constant c_f_mult   : ufixed(0 downto -9) := 10x"399";
    -- constant c_f_offset : ufixed(5 downto 0)  := 6x"20";
    -- variable v_c_temp   : ufixed(5 downto -1);
    variable v_f_offset : integer;
  begin
  
    -- v_c_temp    := resize((to_ufixed(i_c_offset, 5, 0) * to_ufixed(0.5, 0, -1)) + to_ufixed(10, 3, 0), v_c_temp'high, v_c_temp'low);
    -- v_f_offset  := 99 - to_integer(resize(v_c_temp * c_f_mult + c_f_offset, 5, -1));
    v_f_offset  := to_integer((to_ufixed(i_c_offset, 5, 0) * to_ufixed(0.5, 0, -1)) * c_f_mult);
    return v_f_offset;
  end;

  function stc_offset_f_to_c (
    i_f_offset : in integer
  ) return integer is
    -- 1/1.8 = 0.555555556
    -- 100|0111 = 0.5+0.3125+0.015625+0.0078128 = 0.5546875
    constant c_c_mult : ufixed(-1 downto -7) := 7x"47";
    variable v_c_offset : integer;
  begin
    v_c_offset := to_integer((to_ufixed(i_f_offset, 5, 0) * c_c_mult) * to_ufixed(2, 1, 0));
    return v_c_offset;
  end;

end package body stc_package;
