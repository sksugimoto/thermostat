-- wrapper_spi_data_handler.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.global_package.all;

entity wrapper_spi_data_handler is
port (
  i_clk             : in  std_logic;
  i_reset_n         : in  std_logic;
  i_sys_pwr_n       : in  std_logic;
  i_reprogram_n     : in  std_logic;
  i_time_second     : in  std_logic_vector(5 downto 0);
  -- Program data signals
  o_program_req     : out std_logic;
  i_program_rdy     : in  std_logic;
  i_sh_prog_data    : in  std_logic_vector(16895 downto 0);
  o_last_prog_data  : out std_logic_vector(16895 downto 0);
  -- Temperature data signals
  o_temp_req        : out std_logic;
  i_temp_rdy        : in  std_logic;
  i_sh_temp_data    : in  std_logic_vector(9 downto 0);
  o_last_temp_data  : out std_logic_vector(9 downto 0)
);
end entity wrapper_spi_data_handler;

architecture wrapper_spi_data_handler of wrapper_spi_data_handler is
  signal s_sh_prog_data   : t_array_slv64(263 downto 0);
  signal s_last_prog_data : t_array_slv64(263 downto 0);
begin
  spi_data_handler_0 : entity work.spi_data_handler
  port map (
    i_clk             => i_clk,             -- : in  std_logic;
    i_reset_n         => i_reset_n,         -- : in  std_logic;
    i_sys_pwr_n       => i_sys_pwr_n,       -- : in  std_logic;
    i_reprogram_n     => i_reprogram_n,     -- : in  std_logic;
    i_time_second     => i_time_second,     -- : in  std_logic_vector(5 downto 0);
    -- Program data signals
    o_program_req     => o_program_req,     -- : out std_logic;
    i_program_rdy     => i_program_rdy,     -- : in  std_logic;
    i_sh_prog_data    => s_sh_prog_data,    -- : in  t_array_slv64(263 downto 0);
    o_last_prog_data  => s_last_prog_data,  -- : out t_array_slv64(263 downto 0);
    -- Temperature data signals
    o_temp_req        => o_temp_req,        -- : out std_logic;
    i_temp_rdy        => i_temp_rdy,        -- : in  std_logic;
    i_sh_temp_data    => i_sh_temp_data,    -- : in  std_logic_vector(9 downto 0);
    o_last_temp_data  => o_last_temp_data   -- : out std_logic_vector(9 downto 0)
  );

  -- Convert s_last_prog_data (t_array_slv64) to o_last_prog_data (slv)
  gen_o_last_prog_data : for i in 0 to 263 generate
    o_last_prog_data((i*64+63) downto (i*64)) <= s_last_prog_data(i);
  end generate;

  -- Convert i_sh_prog_data (slv) to s_sh_prog_data (t_array_slv64)
  gen_s_sh_prog_data : for i in 0 to 263 generate
    s_sh_prog_data(i) <= i_sh_prog_data((i*64+63) downto (i*64));
  end generate;

end architecture;
