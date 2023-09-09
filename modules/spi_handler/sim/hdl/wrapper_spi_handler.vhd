-- wrapper_spi_handler.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Verilog to VHDL wrapper for spi_handler module
-- Only needed for simulation, does not need to be synthesizable

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.global_package.all;

entity wrapper_spi_handler is
port (
  -- System clock
  i_clk             : in  std_logic;  -- 20KHz clock
  i_reset_n         : in  std_logic;  -- Pull low when SPI disconnceted for FLASH reprogramming.
  -- Programming Request Controls
  i_read_program    : in  std_logic;
  o_program_data    : out std_logic_vector(16895 downto 0);
  o_program_ready   : out std_logic;
  -- Temperatrue Request Controls
  i_read_therm      : in  std_logic;
  o_temperature     : out std_logic_vector(9 downto 0);
  o_therm_ready     : out std_logic;
  -- SPI Port
  i_spi_disconnect  : in  std_logic;
  o_spi_clk         : out std_logic;  -- 10KHz clock
  o_spi_cs_n        : out std_logic_vector(1 downto 0);
  o_spi_si          : out std_logic;
  i_spi_so          : in  std_logic
);
end entity wrapper_spi_handler;

architecture wrapper_spi_handler of wrapper_spi_handler is
  signal s_program_data : t_array_slv64(263 downto 0);
begin
  spi_handler_0 : entity work.spi_handler
  port map(
    -- System clock
    i_clk             => i_clk,
    i_reset_n         => i_reset_n,
    -- Programming Request Controls
    i_read_program    => i_read_program,
    o_program_data    => s_program_data,
    o_program_ready   => o_program_ready,
    -- Temperatrue Request Controls
    i_read_therm      => i_read_therm,
    o_temperature     => o_temperature,
    o_therm_ready     => o_therm_ready,
    -- SPI Port
    i_spi_disconnect  => i_spi_disconnect,
    o_spi_clk         => o_spi_clk,
    o_spi_cs_n        => o_spi_cs_n,
    o_spi_si          => o_spi_si,
    i_spi_so          => i_spi_so
  );

  -- Convert s_program_data (t_array_slv64) to o_program_data (slv)
  gen_o_program_data : for i in 0 to 263 generate
    o_program_data((i*64+63) downto (i*64)) <= s_program_data(i);
  end generate;
end architecture;