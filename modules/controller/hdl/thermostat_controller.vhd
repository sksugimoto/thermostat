-- thermostat_controler.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Drives HVAC control wires

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.stc_package.all;

entity thermostat_controller is
generic (
  -- Short cycle delay, prevents system from re-engaging too quickly.
  -- Set to 2 seconds for testing (20,000*2 = 40,000 cycles).
  -- Set to 10 minutes for deployment (20,000*60*10 = 12,000,000 cycles).
  -- Short cycle timer will not propagate between system resets or power cycle.
  g_sc_delay_time : integer := 12000000
);
port (
  -- Clock and Reset
  i_clk         : in  std_logic;  -- 20KHz
  i_reset_n     : in  std_logic;  
  -- User Control I/O
  i_sys_pwr_n   : in  std_logic;
  o_cycling     : out std_logic;
  -- Temperature Control Inputs
  i_use_f       : in  std_logic;
  i_temperature : in  ufixed(6 downto -2);  -- Already configured in C/F based on i_use_f.
  -- STC Inputs
  i_prog_stc    : t_stc;  -- Schedule handing during time change should be handled by scheduler module
  i_man_stc     : t_stc;  -- Data here should be after T/C conversion, and disabled after next program change.
  -- i_man_stc:  Heat/AC pulled low when no overide.
  --             Program still runs when only fan override is active.
  --             Force fan is NC as switch signal is or-ed at top level
  -- HVAC Control wires
  o_green_fan   : out std_logic;  -- Fan wire
  o_yellow_ac   : out std_logic;  -- AC compressor wire
  o_white_heat  : out std_logic   -- Heating wire
);
end entity thermostat_controller;

architecture thermostat_controller of thermostat_controller is
  -------------------------------------------
  --               CONSTANTS               --
  -------------------------------------------
  constant c_auto_mode  : std_logic_vector(1 downto 0)  := 2x"3";
  constant c_cool_mode  : std_logic_vector(1 downto 0)  := 2x"2";
  constant c_heat_mode  : std_logic_vector(1 downto 0)  := 2x"1";
  constant c_idle_mode  : std_logic_vector(1 downto 0)  := 2x"0";
  constant c_sc_delay   : integer := g_sc_delay_time;
  constant c_c_lbound   : ufixed(3 downto 0)  := 4x"A";   -- 10C offset
  constant c_f_lbound   : ufixed(5 downto 0)  := 6x"32";  -- 50F offset, 10C = 50F
  constant c_c_step     : ufixed(0 downto -1) := 2x"1";   -- 0.5C Steps
  constant c_c_buffer   : ufixed(0 downto -2) := 3x"1";   -- 0.25C buffer
  constant c_f_buffer   : ufixed(0 downto -2) := 3x"2";   -- 0.5F buffer
  constant c_c_a_rng    : ufixed(1 downto 0)  := 2x"1";   -- Celsius auto mode temperature range, system is idle +/- 1C from target temperature
  constant c_f_a_rng    : ufixed(1 downto 0)  := 2x"2";   -- Fahrenheit auto mode temperature range, system is idle +/1 2F from target temperature


  -------------------------------------------
  --                SIGNALS                --
  -------------------------------------------
  signal s_mode             : std_logic_vector(1 downto 0);
  signal s_target_temp      : ufixed(6 downto -1);
  signal n_delay_counter    : integer range 0 to g_sc_delay_time - 1;
  signal s_auto_range       : ufixed(1 downto 0);   -- Set to c_c_a_rng or c_f_a_rng based on i_use_f;
  signal s_buffer           : ufixed(0 downto -2);  -- Set to c_c_buffer or c_f_buffer based on i_use_f;
  signal s_auto_cool_on     : std_logic;
  signal s_auto_heat_on     : std_logic;
  signal s_auto_cool_off    : std_logic;
  signal s_auto_heat_off    : std_logic;
  signal s_cool_on          : std_logic;
  signal s_heat_on          : std_logic;
  signal s_cool_off         : std_logic;
  signal s_heat_off         : std_logic;
  
  type t_thermostat_state is(
    IDLE,
    HEAT_ON,
    COOL_ON,
    CYCLE_DELAY
  );
  signal s_therm_state  : t_thermostat_state := IDLE;
  signal s_therm_nstate : t_thermostat_state := IDLE;

begin
  --------------------------------------------
  --        STC-TO-TARGET TEMPERATURE       --
  --------------------------------------------
  -- s_target_temp control ((6 downto 0) is 7 wide, (6 downto -1) is 8 wide)
  process(i_reset_n, i_temperature, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_target_temp <= resize(i_temperature, s_target_temp'high, s_target_temp'low);
    else
      if(rising_edge(i_clk)) then
        if(i_man_stc.heat_on = '0' and i_man_stc.cool_on = '0' and i_prog_stc.heat_on = '0' and i_prog_stc.cool_on = '0') then -- System idle
          s_target_temp <= resize(i_temperature, s_target_temp'high, s_target_temp'low);
        else  -- System active
          if(i_man_stc.heat_on = '1' or i_man_stc.cool_on = '1') then  -- run manual or override
            if(i_use_f = '1') then
              -- When in Fahrenheit mode, target temperature has a range of 50F-99F
              if(i_man_stc.trgt_f_ofst > 49) then
                s_target_temp <= 7x"63" & '0';
              else
                -- to_ufixed(unsigned(i_man_stc.trgt_f_ofst, 6), 5, 0) is ufixed(5 downto 0)
                -- c_f_lbound is ufixed(3 downto 0), therefore sum is max(5, 3) + 1 downto min(0, 0) => ufixed(6 downto 0)
                s_target_temp <= resize((c_f_lbound + to_ufixed(i_man_stc.trgt_f_ofst, 5, 0)), s_target_temp'high, s_target_temp'low);
              end if;
            else
              -- When in Celsius mode, target temperature has a range of 10C-37.5C
              -- stc Celsius offset is in 0.5C increments
              if(i_man_stc.trgt_c_ofst > 55) then
                s_target_temp <=7x"25" & '1';
              else
                -- to_ufixed(unsigned(i_man_stc.trgt_c_ofst, 6), 5, 0) is ufixed(5 downto 0)
                -- c_c_step is ufixed(0 downto -1), therefore, product is 5+0+1 downto 0 + -1 => 6 downto -1
                -- c_c_lbound is ufixed(3 downto 0), therefore sum is max(3, 6) + 1 downto min(-1, 0) => ufixed(7 downto -1)
                s_target_temp <= resize((c_c_lbound + c_c_step * to_ufixed(i_man_stc.trgt_c_ofst, 5, 0)), s_target_temp'high, s_target_temp'low);
              end if;
            end if;
          else  -- Run program
            if(i_use_f = '1') then
              if(i_prog_stc.trgt_f_ofst > 49) then
                s_target_temp <= 7x"63" & '0';
              else
                s_target_temp <= resize((c_f_lbound + to_ufixed(i_prog_stc.trgt_f_ofst, 5, 0)), s_target_temp'high, s_target_temp'low);
              end if;
            else
              if(i_prog_stc.trgt_c_ofst > 55) then
                s_target_temp <= 7x"25" & '1';
              else
                s_target_temp <= resize((c_c_lbound + c_c_step * to_ufixed(i_prog_stc.trgt_c_ofst, 5, 0)), s_target_temp'high, s_target_temp'low);
              end if;
            end if;
          end if;
        end if;
      end if; -- rising edge clock
    end if; -- reset_n
  end process;

  -- s_mode control
  -- This process determines what mode the system is in; auto, heat or cool
  -- Determination is based on i_x_stc settings
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_mode  <= c_idle_mode;
    else
      if(rising_edge(i_clk)) then
        if((i_man_stc.cool_on = '1') or (i_man_stc.heat_on = '1')) then
          if((i_man_stc.cool_on = '1') and (i_man_stc.heat_on) = '1') then
            s_mode <= c_auto_mode;
          elsif(i_man_stc.cool_on = '1') then
            s_mode <= c_cool_mode;
          else
            s_mode <= c_heat_mode;
          end if;
        elsif((i_prog_stc.cool_on = '1') or (i_prog_stc.heat_on) = '1') then
          if((i_prog_stc.cool_on = '1') and (i_prog_stc.heat_on = '1')) then
            s_mode <= c_auto_mode;
          elsif(i_prog_stc.cool_on = '1') then
            s_mode <= c_cool_mode;
          else
            s_mode <= c_heat_mode;
          end if;
        else
          s_mode <= c_idle_mode;
        end if;
      end if;
    end if;
  end process;

  -- n_delay_counter control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_delay_counter <= 0;
    else
      if(rising_edge(i_clk)) then
        case s_therm_nstate is
          when CYCLE_DELAY =>
            n_delay_counter <= n_delay_counter + 1;
          when others =>
            n_delay_counter <= 0;
        end case;
      end if;
    end if;
  end process;

  -------------------------------------------
  --        CONTROLLER STATE MACHINE       --
  -------------------------------------------
  -- Buffer/Range settings based on i_use_f
  s_auto_range  <= c_f_a_rng when i_use_f = '1' else c_c_a_rng;
  s_buffer      <= c_f_buffer when i_use_f = '1' else c_c_buffer;

  -- Temperature comparision tests
  s_auto_cool_on  <= '1' when (i_temperature >= resize(s_target_temp + s_auto_range + s_buffer, 6, -2)) else '0';
  s_auto_heat_on  <= '1' when (i_temperature <= resize(s_target_temp - s_auto_range - s_buffer, 6, -2)) else '0';
  s_auto_cool_off <= '1' when (i_temperature <= resize(s_target_temp + s_auto_range - s_buffer, 6, -2)) else '0';
  s_auto_heat_off <= '1' when (i_temperature >= resize(s_target_temp - s_auto_range + s_buffer, 6, -2)) else '0';
  s_cool_on   <= '1' when (i_temperature >= resize(s_target_temp + s_buffer, 6, -2)) else '0';
  s_heat_on   <= '1' when (i_temperature <= resize(s_target_temp - s_buffer, 6, -2)) else '0';
  s_cool_off  <= '1' when (i_temperature <= resize(s_target_temp - s_buffer, 6, -2)) else '0';
  s_heat_off  <= '1' when (i_temperature >= resize(s_target_temp + s_buffer, 6, -2)) else '0';

  -- s_therm_nstate control
  therm_nstate_ctrl : process(i_reset_n, s_therm_state, i_sys_pwr_n, s_mode, s_auto_cool_on, s_auto_heat_on, s_auto_cool_off,
                              s_auto_heat_off, s_cool_on, s_heat_on, s_cool_off, s_heat_off, n_delay_counter) is
  begin
    if(i_reset_n = '0') then
      s_therm_nstate <= IDLE;
    else
      case s_therm_state is
        when IDLE =>
          if(i_sys_pwr_n = '0') then  -- System on
            if(s_mode = c_auto_mode) then  -- Auto mode with wide thermal buffer where system is idle
              if(s_auto_cool_on = '1') then
                s_therm_nstate <= COOL_ON;
              elsif (s_auto_heat_on = '1') then
                s_therm_nstate <= HEAT_ON;
              else
                s_therm_nstate <= IDLE;
              end if;
            elsif(s_mode = c_cool_mode) then  -- Normal Heating and cooling
              s_therm_nstate <= COOL_ON when s_cool_on = '1' else IDLE;
            elsif(s_mode = c_heat_mode) then
              s_therm_nstate <= HEAT_ON when s_heat_on = '1' else IDLE;
            else
              s_therm_nstate <= IDLE;
            end if;
          else -- System off
            s_therm_nstate <= IDLE;
          end if;
        when HEAT_ON =>
          if(i_sys_pwr_n = '1') then
            s_therm_nstate <= CYCLE_DELAY;
          else
            if(s_mode = c_auto_mode) then
              s_therm_nstate <= CYCLE_DELAY when s_auto_heat_off = '1' else HEAT_ON;
            else
              s_therm_nstate <= CYCLE_DELAY when s_heat_off = '1' else HEAT_ON;
            end if;
          end if;
        when COOL_ON =>
          if(i_sys_pwr_n = '1') then
            s_therm_nstate <= CYCLE_DELAY;
          else
            if(s_mode = c_auto_mode) then
              s_therm_nstate <= CYCLE_DELAY when s_auto_cool_off = '1' else COOL_ON;
            else
              s_therm_nstate <= CYCLE_DELAY when s_cool_off = '1' else COOL_ON;
            end if;
          end if;
        when CYCLE_DELAY =>
          s_therm_nstate <= IDLE when n_delay_counter = (c_sc_delay - 1) else CYCLE_DELAY;
      end case;
    end if;
  end process;

  -- s_therm_state control
  therm_state_ctrl : process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_therm_state <= IDLE;
    else
      if(rising_edge(i_clk)) then
        s_therm_state <= s_therm_nstate;
      end if;
    end if;
  end process;

  -------------------------------------------
  --             OUTPUT CONTROL            --
  -------------------------------------------
  -- o_cycling control
  process(all) is
  begin
    if(s_therm_state = CYCLE_DELAY) then
      if(s_mode = c_auto_mode) then
        o_cycling <= '1' when ((s_auto_cool_on = '1') or (s_auto_heat_on = '1')) else '0';
      elsif(s_mode = c_cool_mode) then
        o_cycling <= '1' when s_cool_on = '1' else '0';
      elsif(s_mode = c_heat_mode) then
        o_cycling <= '1' when s_heat_on = '1' else '0';
      else
        o_cycling <= '0';
      end if;
    else
      o_cycling <= '0';
    end if;
  end process;
  
  -- HVAC wire controls
  o_green_fan   <= '1' when (i_prog_stc.force_fan = '1' or s_therm_state = COOL_ON or s_therm_state = HEAT_ON) else '0';
  o_yellow_ac   <= '1' when s_therm_state = COOL_ON else '0';
  o_white_heat  <= '1' when s_therm_state = HEAT_ON else '0';
end architecture;
