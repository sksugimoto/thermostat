-- spi_to_temp.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Converts SPI handler output to temperature

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.fixed_pkg.all;

entity spi_to_temp is
port (
  -- Control signals
  i_use_f     : in  std_logic;
  -- Data In/Out
  i_spi_data  : in  std_logic_vector(9 downto 0);
  o_temp_data : out ufixed(6 downto -2)
);
end entity spi_to_temp;

architecture spi_to_temp of spi_to_temp is
  -- TI TMP125 SPI bits
  -- SPI_14 -> 9: pos/neg ->  X
  -- SPI_13 -> 8: 64      -> 2^ 6
  -- SPI_12 -> 7: 32      -> 2^ 5
  -- SPI_11 -> 6: 16      -> 2^ 4
  -- SPI_10 -> 5: 8       -> 2^ 3
  -- SPI_9  -> 4: 4       -> 2^ 2
  -- SPI_7  -> 3: 2       -> 2^ 1
  -- SPI_6  -> 2: 1       -> 2^ 0
  -- SPI_5  -> 1: 0.50    -> 2^-1
  -- SPI_4  -> 0: 0.25    -> 2^-2
  -- Constants for celcius to fahrenheit conversion (F=1.8C+32)
  -- 01|2345|6789
  -- 11|1001|1001 -> 1+0.5+0.25+0.03125+0.015625+0.001953125 = 1.798828125 ~= 1.8
  constant c_f_mult   : ufixed(0 downto -9) := 10x"399";
  -- 6|5432|1012
  -- 0|1000|0000 -> 2^5 = 32.0
  constant  c_f_offset  : ufixed(5 downto 0) := 6x"20";
  constant  c_f_nq      : ufixed(0 downto -3) := 4x"1"; -- for rounding to nearest quarter degree (after truncation)
  signal    s_c_temp    : ufixed(6 downto -2);
  -- Farenheit Conversion
  -- s_f_mult
  -- Range: (A'left + B'left + 1) downto (A'right + B'right) -> (6+0+1) downto (-2 + -9) -> 7 downto -11
  signal  s_f_mult  : ufixed(7 downto -11);
  signal  s_f_temp  : ufixed(9 downto -11);
  signal  s_f_trunc : ufixed(6 downto -2);
  
begin
  -- Temperature in C
  s_c_temp  <= to_ufixed(i_spi_data(8 downto 0), 6, -2);
  -- C to F Temperature conversion
  s_f_mult  <= s_c_temp * c_f_mult;
  s_f_temp  <= (s_f_mult + c_f_nq + c_f_offset);
  s_f_trunc <= s_f_temp(6 downto -2);
  -- Output control
  o_temp_data <= s_f_trunc when i_use_f = '1' else s_c_temp;
end architecture;
