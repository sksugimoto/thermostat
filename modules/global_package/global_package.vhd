-- global_package.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Package for types used throughout the thermometer design.

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;

package global_package is
  type t_array_slv8   is array(natural range <>) of std_logic_vector(7 downto 0);
  type t_array_slv16  is array(natural range <>) of std_logic_vector(15 downto 0);
  type t_array_slv64  is array(natural range <>) of std_logic_vector(63 downto 0);
end package;
