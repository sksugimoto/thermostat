-- wrapper_thermostat_controller.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Wrapper module for Thermostat controller module
-- Only needed for simulation, does not need to be synthesizable

library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

library work;
use work.stc_package.all;

entity wrapper_thermostat_controller is
generic (
  -- As wrapper is only used for testbench, set delay time to testbench settings
  g_sc_delay_time : integer := 40000
);
port (
  -- Clock and Reset
  i_clk         : in  std_logic;  -- 20KHz
  i_reset_n     : in  std_logic;  
  -- User Control Inputs
  i_sys_pwr_n   : in  std_logic;
  o_cycling     : out std_logic;
  -- Temperature Control Inputs
  i_use_f       : in  std_logic;
  i_temperature : in  ufixed(6 downto -2);  -- Already configured in C/F based on i_use_f.
  -- STC Inputs
  i_prog_stc    : in  std_logic_vector(31 downto 0);
  i_man_stc     : in  std_logic_vector(31 downto 0);
  -- i_man_stc:  Heat/AC pulled low when no overide.
  --             Program still runs when only fan override is active.
  --             Force fan is NC as switch signal is or-ed at top level
  -- HVAC Control wires
  o_green_fan   : out std_logic;  -- Fan wire
  o_yellow_ac   : out std_logic;  -- AC compressor wire
  o_white_heat  : out std_logic   -- Heating wire
);
end entity wrapper_thermostat_controller;

architecture wrapper_thermostat_controller of wrapper_thermostat_controller is
begin
  controller : entity work.thermostat_controller
  generic map (
    g_sc_delay_time => g_sc_delay_time
  )
  port map (
    -- Clock and Reset
    i_clk         => i_clk,
    i_reset_n     => i_reset_n,
    -- User Control Inputs
    i_sys_pwr_n   => i_sys_pwr_n,
    o_cycling     => o_cycling,
    -- Temperature Control Inputs
    i_use_f       => i_use_f,
    i_temperature => i_temperature,
    -- STC Inputs
    i_prog_stc    => slv_to_stc(i_prog_stc),
    i_man_stc     => slv_to_stc(i_man_stc),
    -- HVAC Control wires
    o_green_fan   => o_green_fan,
    o_yellow_ac   => o_yellow_ac,
    o_white_heat  => o_white_heat
  );
end architecture;
