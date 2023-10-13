-- thermostat_top.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.global_package.all;
use work.stc_package.all;
use work.time_package.all;

entity thermostat_top is 
generic (
  g_time_clk_freq             : integer := 20000;                 -- 20KHz
  g_time_btn_init             : integer := g_time_clk_freq;       -- 1 second
  g_time_btn_hold             : integer := 5000;                  -- 0.25 seconds
  g_user_ui_idle_time         : integer := g_time_clk_freq*5;     -- 5 seconds
  g_controller_sc_delay_time  : integer := g_time_clk_freq*60*10  -- Short Cycle Delay, 10 Minutes
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
  i_reprogram_n : in  std_logic;                    -- Switch, "disconnects" FPGA from SPI to allow for external SPI control, active low
  i_set_time_n  : in  std_logic;                    -- Physical Switch (2 position), active low
  i_incr_week_n : in  std_logic;                    -- Push button, active low
  i_incr_day_n  : in  std_logic;                    -- Push button, active low
  i_incr_hr_n   : in  std_logic;                    -- Push button, active low
  i_incr_min_n  : in  std_logic;                    -- Push button, active low
  i_temp_up_n   : in  std_logic;                    -- Push button, active low
  i_temp_down_n : in  std_logic;                    -- Push button, active low

  -- SPI Signals
  o_spi_clk     : out std_logic;  -- 10KHz
  o_spi_cs_n    : out std_logic_vector(1 downto 0);
  o_spi_si      : out std_logic;
  i_spi_so      : in  std_logic;
  
  -- 14 Segement display out
  o_14seg_n_0  : out std_logic_vector(14 downto 0);
  o_14seg_n_1  : out std_logic_vector(14 downto 0);
  o_14seg_n_2  : out std_logic_vector(14 downto 0);
  o_14seg_n_3  : out std_logic_vector(14 downto 0);
  o_14seg_n_4  : out std_logic_vector(14 downto 0);
  o_14seg_n_5  : out std_logic_vector(14 downto 0);
  o_14seg_n_6  : out std_logic_vector(14 downto 0);
  o_14seg_n_7  : out std_logic_vector(14 downto 0);
  o_14seg_n_8  : out std_logic_vector(14 downto 0);
  o_14seg_n_9  : out std_logic_vector(14 downto 0);
  o_14seg_n_10 : out std_logic_vector(14 downto 0);
  o_14seg_n_11 : out std_logic_vector(14 downto 0);
  o_14seg_n_12 : out std_logic_vector(14 downto 0);
  o_14seg_n_13 : out std_logic_vector(14 downto 0);
  o_14seg_n_14 : out std_logic_vector(14 downto 0);
  o_14seg_n_15 : out std_logic_vector(14 downto 0);

  -- LEDs
  o_day_time_day_n  : out std_logic_vector(6 downto 0);  -- LED indicators to indicate day (Sun-Sat), active low
  o_prgm_error_n    : out std_logic;  -- Pulled low when schedule's referenecs point to no-valid entries.
  o_prgm_ovride_n   : out std_logic;  -- Pulled low when temporary program override is engaged
  o_heat_on_n       : out std_logic;  -- LED indicators for thermostat mode, active low
  o_cool_on_n       : out std_logic;  -- LED indicators for thermostat mode, active low
  o_force_fan_n     : out std_logic;  -- LED indicators for thermostat mode, active low
  o_sys_cycling_n   : out std_logic;  -- LED indicators for thermostat cycling, active low

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
  signal s_sys_reset_n    : std_logic := '0';
  signal s_spi_reset_n    : std_logic := '1';
  signal n_rst_cntr       : integer   := 0;
  -- Controller signals
  signal s_force_fan      : std_logic;
  signal s_prog_stc       : t_stc;
  signal s_man_stc        : t_stc;
  signal s_prgm_error     : std_logic;
  signal s_sys_cycling    : std_logic;

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
  signal s_spi_so         : std_logic;

  -- Temperature conversion Signals
  signal s_temperature    : ufixed(6 downto -2);

  -- 14 Segment signals
  signal s_14seg_ctrls    : t_array_slv16(15 downto 0);

begin
  -- n_rst_cntr control
  process(i_reset_n, i_clk_20KHz) is
  begin
    if(i_reset_n = '0') then
      n_rst_cntr <= 0;
    else
      if(rising_edge(i_clk_20KHz)) then
        n_rst_cntr <= n_rst_cntr + 1 when (n_rst_cntr < ((g_time_clk_freq*5)-1)) else n_rst_cntr;
      end if;
    end if;
  end process;
  -- s_sys_reset_n control
  process(i_reset_n, n_rst_cntr) is
  begin
    if(i_reset_n = '0') then
      s_sys_reset_n <= '0';
    else
      s_sys_reset_n <= '1' when (n_rst_cntr = ((g_time_clk_freq*5) - 1)) else '0';
    end if;
  end process;
  -- s_spi_reset_n control
  s_spi_reset_n <= '1' when i_reset_n = '1' else '0';

  -- Controller
  controller_0 : entity work.thermostat_controller
  generic map(
    g_sc_delay_time   => g_controller_sc_delay_time,
    g_man_stc_itime   => g_time_clk_freq*5
  )
  port map (
    -- Clock and Reset
    i_clk         => i_clk_20KHz,
    i_reset_n     => i_reset_n,
    -- User Control Inputs
    i_sys_pwr_n   => i_sys_on_n,
    o_cycling     => s_sys_cycling,
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
  -- Fan should be on when force fan enabled
  o_green_fan     <= '1' when ((i_sys_on_n = '0') and (i_force_fan_n = '0')) else s_force_fan;
  o_force_fan_n   <= '0' when ((i_sys_on_n = '0') and (i_force_fan_n = '0')) else not(s_force_fan);
  o_sys_cycling_n <= not s_sys_cycling;
  o_heat_on_n     <= not o_white_heat;
  o_cool_on_n     <= not o_yellow_ac;

  -- Scheduler
  scheduler_0 : entity work.scheduler_control
  generic map (
    g_clk_freq => g_time_clk_freq
  )
  port map (
    -- Clock and Reset
    i_clk           => i_clk_20KHz,   -- : in  std_logic;
    i_reset_n       => s_sys_reset_n,     -- : in  std_logic;
    -- Scheduler Controller
    i_sys_pwr_n     => i_sys_on_n,      -- : in  std_logic;
    i_run_prog_n    => i_run_prog_n,    -- : in  std_logic;
    i_reprogram_n   => i_reprogram_n,   -- : in  std_logic;
    i_set_time_n    => i_set_time_n,    -- : in  std_logic;
    i_incr_week_n   => i_incr_week_n,   -- : in  std_logic;
    i_slv_prog      => s_program_data,  -- : in  t_array_slv64(263 downto 0);
    i_day_time      => s_day_time,      -- : in  t_day_time;

    -- STC to Controller
    o_program_error => s_prgm_error,  -- : out std_logic;
    o_program_stc   => s_prog_stc     -- : out t_stc
  );
  o_prgm_error_n <= not s_prgm_error;

  -- SPI Data Handler
  spi_data_handler_0 : entity work.spi_data_handler
  port map (
    i_clk             => i_clk_20KHz,     -- : in  std_logic;
    i_reset_n         => s_spi_reset_n,       -- : in  std_logic;
    i_sys_pwr_n       => i_sys_on_n,      -- : in  std_logic;
    i_reprogram_n     => i_reprogram_n,   -- : in  std_logic;
    i_time_second     => std_logic_vector(to_unsigned(s_day_time.second, 6)),   -- : in  std_logic_vector(5 downto 0);
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
  spi_handler_0 : entity work.spi_handler
  port map (
    -- System clock
    i_clk             => i_clk_20KHz,
    i_reset_n         => s_spi_reset_n,
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
    i_spi_so          => s_spi_so
  );

  o_spi_clk   <= s_spi_clk when i_reprogram_n = '1' else 'Z';
  o_spi_cs_n  <= s_spi_cs_n when i_reprogram_n = '1' else (others => 'Z');
  o_spi_si    <= s_spi_si when i_reprogram_n = '1' else 'Z';
  s_spi_so    <= i_spi_so when i_reprogram_n = '1' else '0';

  -- SPI Temperature data to ufixed type with unit conversion
  spi_to_temp_0 : entity work.spi_to_temp
  port map (
    -- Control signals
    i_use_f     => not i_use_f_n,
    -- Data In/Out
    i_spi_data  => s_temp_slv,
    o_temp_data => s_temperature
  );

  -- Manual Mode and Override Mode Control
  user_control_0 : entity work.usr_ctrl_ovride
  generic map (
    -- # of clock cycles elapsed after last user input before o_stc is updated
    -- Set to 5 seconds for deployment (20,000*5 = 100,000 cycles).
    g_ui_idle_time  => g_user_ui_idle_time,
    -- Set to different value for simulation
    g_clk_freq  => g_time_clk_freq,
    g_btn_init  => g_time_btn_init,
    g_btn_hold  => g_time_btn_hold
  )
  port map (
    -- Clock and Reset
    i_clk         => i_clk_20KHz,
    i_reset_n     => s_sys_reset_n,
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
  o_prgm_ovride_n <= '1' when ((i_sys_on_n = '0') and (i_run_prog_n = '0') and ((s_man_stc.heat_on = '0') and (s_man_stc.cool_on = '0'))) else '0';

  -- Time Keeper
  time_keeper_0 : entity work.time_keeper
  generic map (
    -- Set to different value for simulation
    g_clk_freq  => g_time_clk_freq,
    g_btn_init  => g_time_btn_init,
    g_btn_hold  => g_time_btn_hold
  )
  port map (
    -- Clock and Reset
    i_clk         => i_clk_20KHz,
    i_reset_n     => s_sys_reset_n,
    -- User Interface
    i_set_time_n  => i_set_time_n,
    i_incr_day_n  => i_incr_day_n,
    i_incr_hr_n   => i_incr_hr_n,
    i_incr_min_n  => i_incr_min_n,
    -- Time
    o_day_time    => s_day_time
  );
  o_day_time_day_n  <= not(s_day_time.day);

  -- 14 Segment Displays Controller
  display_controller_0 : entity work.display_controller
  port map (
    i_reset_n       => s_sys_reset_n,
    -- Date and Time control
    i_set_time_n    => i_set_time_n,
    i_day_time      => s_day_time,
    -- Thermostat user controls
    i_use_f         => not i_use_f_n,
    i_sys_on_n      => i_sys_on_n,    
    i_reprogram_n   => i_reprogram_n,
    i_prog_read     => s_read_program,
    i_run_prog_n    => i_run_prog_n,
    -- Thermostat settings
    i_temperature   => s_temperature,
    i_prog_stc      => s_prog_stc,
    i_man_stc       => s_man_stc,
    -- Display output
    o_14seg_cntrls  => s_14seg_ctrls
  );
  o_14seg_n_0   <= not (s_14seg_ctrls(0)(14 downto 0));
  o_14seg_n_1   <= not (s_14seg_ctrls(1)(14 downto 0));
  o_14seg_n_2   <= not (s_14seg_ctrls(2)(14 downto 0));
  o_14seg_n_3   <= not (s_14seg_ctrls(3)(14 downto 0));
  o_14seg_n_4   <= not (s_14seg_ctrls(4)(14 downto 0));
  o_14seg_n_5   <= not (s_14seg_ctrls(5)(14 downto 0));
  o_14seg_n_6   <= not (s_14seg_ctrls(6)(14 downto 0));
  o_14seg_n_7   <= not (s_14seg_ctrls(7)(14 downto 0));
  o_14seg_n_8   <= not (s_14seg_ctrls(8)(14 downto 0));
  o_14seg_n_9   <= not (s_14seg_ctrls(9)(14 downto 0));
  o_14seg_n_10  <= not (s_14seg_ctrls(10)(14 downto 0));
  o_14seg_n_11  <= not (s_14seg_ctrls(11)(14 downto 0));
  o_14seg_n_12  <= not (s_14seg_ctrls(12)(14 downto 0));
  o_14seg_n_13  <= not (s_14seg_ctrls(13)(14 downto 0));
  o_14seg_n_14  <= not (s_14seg_ctrls(14)(14 downto 0));
  o_14seg_n_15  <= not (s_14seg_ctrls(15)(14 downto 0));

end architecture;