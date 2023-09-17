-- global_package.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Package for types utilzied in thermostat control.

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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

end package stc_package;

package body stc_package is
  constant c_stc_idle : t_stc := (
    heat_on     => '0',
    cool_on     => '0',
    force_fan   => '0',
    trgt_c_ofst => 0,
    trgt_f_ofst => 0
  );
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
end package body stc_package;
