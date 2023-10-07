-- thermostat_top.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.fixed_pkg.all;

library work;
use work.global_package.all;
use work.stc_package.all;
use work.time_package.all;

entity thermostat_top is 
generic (
  g_controller_sc_delay_time  : integer := 12000000;  -- Short Cycle Delay, 10 Minutes
  g_time_clk_freq             : integer := 20000;     -- 20KHz
  g_time_btn_init             : integer := 20000;     -- 1 second
  g_time_btn_hold             : integer := 5000;      -- 0.25 seconds
  g_user_ui_idle_time         : integer := 100000     -- 5 seconds
);
port (
  -- Clock and Reset
  i_clk_20KHz   : in  std_logic;  -- Clock crystal
  i_reset_n     : in  std_logic;  -- Physical button
  -- User Controls
  i_sys_on_n    : in  std_logic;                    -- Physical Switch (2 position), active low
  i_use_f_n     : in  std_logic;                    -- Physical Switch (2 position), active low
  i_run_prog_n  : in  std_logic;                    -- Physical Switch (2 position), active low
  i_force_fan_n : in  std_logic;                    -- Physical Switch (2 position), active low
  i_heat_cool_n : in  std_logic_vector(2 downto 0); -- Physical switch (3 position, heat, cool, auto), one-hot active low
  i_reprogram_n : in  std_logic;                    -- Switch, "disconnects" FPGA from SPI to allow for external control, active low
  i_set_time_n  : in  std_logic;                    -- Physical Switch (2 position), active low
  i_incr_day_n  : in  std_logic;                    -- Push button, active low
  i_incr_hr_n   : in  std_logic;                    -- Push button, active low
  i_incr_min_n  : in  std_logic;                    -- Push button, active low
  i_temp_up_n   : in  std_logic;                    -- Push button, active low
  i_temp_down_n : in  std_logic;                    -- Push button, active low
  
  -- 14 Segement display out
  o_14seg_temp_0  : out std_logic_vector(14 downto 0);
  o_14seg_temp_1  : out std_logic_vector(14 downto 0);
  o_14seg_temp_2  : out std_logic_vector(14 downto 0);
  o_14seg_temp_3  : out std_logic_vector(14 downto 0);
  o_14seg_temp_4  : out std_logic_vector(14 downto 0);
  o_14seg_temp_5  : out std_logic_vector(14 downto 0);
  o_14seg_temp_6  : out std_logic_vector(14 downto 0);
  o_14seg_temp_7  : out std_logic_vector(14 downto 0);

  -- LEDs
  o_prgm_ovride_n : out std_logic;  -- Pull low when temporary program override is engaged
  -- SPI Signals
  o_spi_clk     : out std_logic;  -- 10KHz
  o_spi_cs_n    : out std_logic_vector(1 downto 0);
  o_spi_si      : out std_logic;
  i_spi_so      : in  std_logic;

  -- 3-Wire Thermostat Control (4-wire with 24V power source)
  o_green_fan   : out std_logic;  -- Active high
  o_yellow_ac   : out std_logic;  -- Active high
  o_white_heat  : out std_logic   -- Active high
);
end entity thermostat_top;

architecture thermostat_top of thermostat_top is
  -------------------------------------------
  --                SIGNALS                --
  -------------------------------------------
  -- Controller signals
  signal s_force_fan      : std_logic;
  signal s_prog_stc       : t_stc;
  signal s_man_stc        : t_stc;

  -- Time Keper Signals
  signal s_day_time       : t_day_time;

  -- SPI handler signals
  signal s_read_program   : std_logic;
  signal s_program_data   : t_array_slv64(263 downto 0);
  signal s_sh_prgm_data   : t_array_slv64(263 downto 0);
  signal s_program_ready  : std_logic;
  signal s_read_therm     : std_logic;
  signal s_sh_temperature : std_logic_vector(9 downto 0);
  signal s_temp_slv       : std_logic_vector(9 downto 0);
  signal s_therm_ready    : std_logic;
  signal s_spi_clk        : std_logic;
  signal s_spi_cs_n       : std_logic_vector(1 downto 0);
  signal s_spi_si         : std_logic;

  -- Temperature conversion Signals
  signal s_temperature    : ufixed(6 downto -2);

  -- 14 Segment signals
  signal s_14seg_ctrls    : t_array_slv16(15 downto 0);

begin
  -- HVAC Control wire assignments
  -- Fan should be on when force fan enabled
  o_green_fan <= '1' when ((i_sys_on_n = '0') and (i_force_fan_n = '0')) else s_force_fan;
  

  -- Controller
  controller : entity work.thermostat_controller
  generic map(
    g_sc_delay_time   => g_controller_sc_delay_time
  )
  port map (
    -- Clock and Reset
    i_clk         => i_clk_20KHz,
    i_reset_n     => i_reset_n,
    -- User Control Inputs
    i_sys_pwr_n   => i_sys_on_n,
    o_cycling     => o_cycling,
    -- Temperature Control Inputs
    i_use_f       => not i_use_f_n,
    i_temperature => s_temperature,
    -- STC Inputs
    i_prog_stc    => s_prog_stc,
    i_man_stc     => s_man_stc,
    -- HVAC Control wires
    o_green_fan   => s_force_fan,
    o_yellow_ac   => o_yellow_ac,
    o_white_heat  => o_white_heat
  );

  -- Scheduler

  -- SPI Data Handler
  spi_data_handler : entity work.spi_data_handler
  port map (
    i_clk             => i_clk_20KHz,     -- : in  std_logic;
    i_reset_n         => i_reset_n,       -- : in  std_logic;
    i_sys_pwr_n       => i_sys_on_n,      -- : in  std_logic;
    i_reprogram_n     => i_reprogram_n,   -- : in  std_logic;
    i_time_second     => s_day_time.second,   -- : in  std_logic_vector(5 downto 0);
    -- Program data signals
    o_program_req     => s_read_program,  -- : out std_logic;
    i_program_rdy     => s_program_ready, -- : in  std_logic;
    i_sh_prog_data    => s_sh_prgm_data,  -- : in  t_array_slv64(263 downto 0);
    o_last_prog_data  => s_program_data,  -- : out t_array_slv64(263 downto 0);
    -- Temperature data signals
    o_temp_req        => s_read_therm,      -- : out std_logic;
    i_temp_rdy        => s_therm_ready,     -- : in  std_logic;
    i_sh_temp_data    => s_sh_temperature,  -- : in  std_logic_vector(9 downto 0);
    o_last_temp_data  => s_temp_slv         -- : out std_logic_vector(9 downto 0)
  );

  -- SPI Handler
  spi_handler : entity work.spi_handler
  port map (
    -- System clock
    i_clk             => i_clk_20KHz,
    i_reset_n         => i_reset_n,
    -- Programming Request Controls
    i_read_program    => s_read_program,
    o_program_data    => s_sh_prgm_data,
    o_program_ready   => s_program_ready,
    -- Temperatrue Request Controls
    i_read_therm      => s_read_therm,
    o_temperature     => s_sh_temperature, -- : out std_logic_vector(9 downto 0);
    o_therm_ready     => s_therm_ready,
    -- SPI Port
    i_spi_disconnect  => not i_reprogram_n,
    o_spi_clk         => s_spi_clk,
    o_spi_cs_n        => s_spi_cs_n,
    o_spi_si          => s_spi_si,
    i_spi_so          => i_spi_so when i_reprogram_n = '1' else '0';
  );

  o_spi_clk   <= s_spi_clk when i_reprogram_n = '1' else 'Z';
  o_spi_cs_n  <= s_spi_cs_n when i_reprogram_n = '1' else (others => 'Z');
  o_spi_si    <= s_spi_si when i_reprogram_n = '1' else 'Z';

  -- SPI Temperature data to ufixed type with unit conversion
  spi_to_temp : entity work.spi_to_temp
  port map (
    -- Control signals
    i_use_f     => not i_use_f_n,
    -- Data In/Out
    i_spi_data  => s_temp_slv,
    o_temp_data => s_temperature
  );

  -- Manual Mode and Override Mode Control
  user_control : entity work.usr_ctrl_ovride
  generic map (
    -- # of clock cycles elapsed after last user input before o_stc is updated
    -- Set to 5 seconds for deployment (20,000*5 = 100,000 cycles).
    g_ui_idle_time  => g_user_ui_idle_time,
    -- Set to different value for simulation
    g_clk_freq  => g_time_clk_freq,
    g_btn_init  => g_time_btn_init,
    g_btn_hold  => g_time_btn_hold
  );
  port map (
    -- Clock and Reset
    i_clk         => i_clk_20KHz,
    i_reset_n     => i_reset_n,
    -- Scheduler STC Input
    i_prog_stc    => s_prog_stc,
    i_temp        => s_temperature,
    -- User Interface
    i_use_f       => not i_use_f_n,
    i_sys_pwr_n   => i_sys_on_n,
    i_run_prog_n  => i_run_prog_n,
    i_heat_cool_n => i_heat_cool_n,
    i_t_down_n    => i_temp_down_n,
    i_t_up_n      => i_temp_up_n,
    -- Controller Interface
    o_stc         => s_man_stc
  );

  -- Time Keeper
  time_keeper : entity work.time_keeper
  generic map (
    -- Set to different value for simulation
    g_clk_freq  => g_time_clk_freq,
    g_btn_init  => g_time_btn_init,
    g_btn_hold  => g_time_btn_hold
  );
  port (
    -- Clock and Reset
    i_clk         => i_clk_20KHz,
    i_reset_n     => i_reset_n,
    -- User Interface
    i_set_time_n  => i_set_time_n,
    i_incr_day_n  => i_incr_day_n,
    i_incr_hr_n   => i_incr_hr_n,
    i_incr_min_n  => i_incr_min_n,
    -- Time
    o_day_time    => s_day_time
  );

  -- 14 Segment Displays Controller
  display_controller : entity work.display_controller
  port map (
    i_day_time      => s_day_time,
    i_temperature   => s_temperature,
    i_sys_on_n      => i_sys_on_n,  -- Sets programmed temperature display to "OFF" when high
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