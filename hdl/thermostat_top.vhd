-- thermostat_top.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.fixed_pkg.all;

entity thermostat_top is 
port (
  i_clk_20KHz   : in  std_logic;
  -- SPI Signals
  o_spi_clk     : out std_logic;  -- 1KHz
  o_spi_cs_n    : out std_logic_vector(1 downto 0);
  o_spi_si      : out std_logic;
  i_spi_so      : in  std_logic
);
end entity thermostat_top;

architecture thermostat_top of thermostat_top is
begin
  -- Controller

  -- Scheduler

  -- Temperature read-in
  spi_to_temp_0 : entity work.spi_to_temp
  port map (
    -- Control signals
    i_use_f     : in  std_logic;
    -- Data In/Out
    i_spi_data  : in  std_logic_vector(15 downto 0);
    o_temp_data : out ufixed(6 downto -2)
  );
  spi_handler_16_0 : entity work.spi_handler_16
  port map (
    -- System clock
    i_clk           => i_clk_20KHz,
    -- Control signals
    i_data_request  => ,
    o_data          => ,
    o_data_valid    => ,
    -- SPI Port
    o_spi_clk       => o_spi_clk,
    o_spi_cs_n      => o_spi_cs_n,
    o_spi_si        => o_spi_si,
    i_spi_so        => i_spi_so
  );

  -- Ambient Temperature Display
  
end architecture;