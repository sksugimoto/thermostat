-- thermostat_controler.v
-- Author: Samuel Sugimoto
-- Date:

-- Drives HVAC control wires

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity thermostat_controler is
port (
  i_clk         : in  std_logic;
  i_temperature : in  std_logic_vector(9 downto 0);
  o_white       : out std_logic;  -- Heating wire
  o_green       : out std_logic;  -- Fan wire
  o_yellow      : out std_logic   -- AC compressor wire
);