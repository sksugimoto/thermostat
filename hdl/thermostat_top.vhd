-- thermostat_top.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.fixed_pkg.all;

library work;
use work.global_package.all;

entity thermostat_top is 
port (
  -- Clock and Reset
  i_clk_20KHz   : in  std_logic;  -- Clock crystal
  i_reset_n     : in  std_logic;  -- Physical button
  -- User Controls
  i_use_f       : in  std_logic;  -- Physical Switch (2 position)
  i_run_prog    : in  std_logic;  -- Physical Switch (2 position)
  i_force_fan   : in  std_logic;  -- Physical Switch (2 position)
  i_heat_cool   : in  std_logic_vector(2 downto 0); -- Physical switch (3 position)
  -- 3-Wire Thermostat Control (4-wire with 24V power source)
  o_green_fan   : out std_logic;
  o_white_heat  : out std_logic;
  o_yellow_cool : out std_logic;
  -- 14 Segement display out
  o_14seg_temp_0  : out std_logic_vector(14 downto 0);
  o_14seg_temp_1  : out std_logic_vector(14 downto 0);
  o_14seg_temp_2  : out std_logic_vector(14 downto 0);
  o_14seg_temp_3  : out std_logic_vector(14 downto 0);
  o_14seg_temp_4  : out std_logic_vector(14 downto 0);
  o_14seg_temp_5  : out std_logic_vector(14 downto 0);
  o_14seg_temp_6  : out std_logic_vector(14 downto 0);
  o_14seg_temp_7  : out std_logic_vector(14 downto 0);
  -- SPI Signals
  o_spi_clk     : out std_logic;  -- 10KHz
  o_spi_cs_n    : out std_logic_vector(1 downto 0);
  o_spi_si      : out std_logic;
  i_spi_so      : in  std_logic
);
end entity thermostat_top;

architecture thermostat_top of thermostat_top is
  -- SPI handler signals
  signal s_read_program   : std_logic;
  signal s_program_data   : t_array_slv64(263 downto 0);
  signal s_program_ready  : std_logic;
  signal s_read_therm     : std_logic;
  signal s_temperature_c  : std_logic_vector(9 downto 0);
  signal s_therm_ready    : std_logic;
  signal s_spi_disconnect : std_logic;

  -- Temperature conversion Signals
  signal s_temperature    : ufixed(6 downto -2);

  -- 14 Segment signals
  signal s_14seg_ctrls    : t_array_slv16(7 downto 0);

begin
  -- User Interface Handler

  -- Controller
  controller : entity work.thermostat_controller
  port map (

  );

  -- Scheduler

  -- SPI Handler
  spi_handler : entity work.spi_handler
  port map (
    -- System clock
    i_clk             => i_clk_20KHz,
    i_reset_n         => i_reset_n,
    -- Programming Request Controls
    i_read_program    => s_read_program,
    o_program_data    => s_program_data,
    o_program_ready   => s_program_ready,
    -- Temperatrue Request Controls
    i_read_therm      => s_read_therm,
    o_temperature     => s_temperature_c,
    o_therm_ready     => s_therm_ready,
    -- SPI Port
    i_spi_disconnect  => s_spi_disconnect,
    o_spi_clk         => o_spi_clk,
    o_spi_cs_n        => o_spi_cs_n,
    o_spi_si          => o_spi_si,
    i_spi_so          => i_spi_so
  );

  spi_to_temp : entity work.spi_to_temp
  port map (
    -- Control signals
    i_use_f     => i_use_f,
    -- Data In/Out
    i_spi_data  => s_temperature_c,
    o_temp_data => s_temperature
  );

  -- 14 Segment Displays Controller
  display_controller : entity work.display_controller
  port map (
    i_temperature   => s_temperature,
    i_prog_temp     => ,
    i_prog_read     => s_read_program,
    o_14seg_cntrls  => s_14seg_ctrls
  );
  o_14seg_temp_0  <= s_14seg_ctrls(0)(14 downto 0);
  o_14seg_temp_1  <= s_14seg_ctrls(1)(14 downto 0);
  o_14seg_temp_2  <= s_14seg_ctrls(2)(14 downto 0);
  o_14seg_temp_3  <= s_14seg_ctrls(3)(14 downto 0);
  o_14seg_temp_4  <= s_14seg_ctrls(4)(14 downto 0);
  o_14seg_temp_5  <= s_14seg_ctrls(5)(14 downto 0);
  o_14seg_temp_6  <= s_14seg_ctrls(6)(14 downto 0);
  o_14seg_temp_7  <= s_14seg_ctrls(7)(14 downto 0);

  
end architecture;