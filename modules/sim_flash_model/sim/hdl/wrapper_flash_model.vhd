-- wrapper_flash_model.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Verilog to VHDL Wrapper for flash_model simulation model
-- Only needed for simulation, does not need to be synthesizable

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.global_package.all;

entity wrapper_flash_model is
port (
  -- Normal SST25VG010A connections
  i_sck     : in  std_logic;    -- SPI Clock (20MHz max)
  i_ce_n    : in  std_logic;    -- Chip Enable
  i_wp_n    : in  std_logic;    -- Write Protect
  i_hold_n  : in  std_logic;    -- Hold
  i_si      : in  std_logic;    -- SPI In
  o_so      : out std_logic;    -- SPI Out
  -- Additional I/O for simulation/model purposes
  i_mem     : in  std_logic_vector(1048575 downto 0)
);
end entity wrapper_flash_model;

architecture wrapper_flash_model of wrapper_flash_model is
  signal s_mem  : t_array_slv64(16383 downto 0);
begin
  flash_model : entity work.flash_model
  port map (
    -- Normal SST25VG010A connections
    i_sck     => i_sck,
    i_ce_n    => i_ce_n,
    i_wp_n    => i_wp_n,
    i_hold_n  => i_hold_n,
    i_si      => i_si,
    o_so      => o_so,
    -- Additional I/O for simulation/model purposes
    i_mem     => s_mem
  );

  -- Convert i_mem slv to t_array_slv64
  gen_s_mem : for i in 0 to 16383 generate
    s_mem(i) <= i_mem((i*64+63) downto (i*64));
  end generate;
end architecture;
