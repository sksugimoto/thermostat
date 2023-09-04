-- wrapper_spi_handler_flash.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Verilog to VHDL Wrapper for spi_handler_flash module
-- Only needed for simulation, does not need to be synthesizable

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.global_package.all;

entity wrapper_spi_handler_flash is
port (
  -- Generics
  i_g_addr_max_width  : in  std_logic_vector(7 downto 0) := 8d"17";
  -- System clock/reset
  i_sys_clk           : in  std_logic;      -- 20KHz clock
  i_reset_n           : in  std_logic;
  -- Control Signals
  i_data_request      : in  std_logic;  -- Only goes high when SPI bus is available
  i_read_addr         : in  std_logic_vector(23 downto 0);
  i_read_num          : in  std_logic_vector(11 downto 0);
  o_data_ready        : out std_logic;
  o_command_error     : out std_logic;
  o_data              : out std_logic_vector(32767 downto 0); -- out t_array_slv8(4095 downto 0);
  -- SPI Port
  i_spi_clk           : in  std_logic;  -- 10KHz clock
  o_spi_cs_n          : out std_logic;
  o_spi_si            : out std_logic;
  i_spi_so            : in  std_logic
);
end entity wrapper_spi_handler_flash;
  
architecture wrapper_spi_handler_flash of wrapper_spi_handler_flash is
  signal s_data : t_array_slv8(4095 downto 0);
begin
  spi_handler_flash : entity work.spi_handler_flash
  generic map (
    g_addr_max_width => to_integer(unsigned(i_g_addr_max_width))
  )
  port map (
    -- System clock/reset
    i_sys_clk       => i_sys_clk,
    i_reset_n       => i_reset_n,
    -- Control Signals
    i_data_request  => i_data_request,
    i_read_addr     => i_read_addr,
    i_read_num      => to_integer(unsigned(i_read_num)),
    o_data_ready    => o_data_ready,
    o_command_error => o_command_error,
    o_data          => s_data,
    -- SPI Port
    i_spi_clk       => i_spi_clk,
    o_spi_cs_n      => o_spi_cs_n,
    o_spi_si        => o_spi_si,
    i_spi_so        => i_spi_so
  );

  -- Convert s_data t_array_slv8 to o_data slv.
  gen_o_data : for i in 0 to 4095 generate
    o_data((i*8+7) downto (i*8)) <= s_data(i);
  end generate;
end architecture;
