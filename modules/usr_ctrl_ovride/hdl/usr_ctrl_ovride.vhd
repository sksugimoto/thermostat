-- usr_ctrl_ovride.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Handles User Controls and Manual/Override Modes

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.stc_package.all;

entity usr_ctrl_ovride is
generic (
  -- # of clock cycles elapsed after last user input before o_stc is updated
  -- Set to 5 seconds for deployment (20,000*5 = 100,000 cycles).
  g_ui_idle_time  : integer := 100000;
  -- Set to different value for simulation
  g_clk_freq  : integer := 20000;
  g_btn_init  : integer := 20000;
  g_btn_hold  : integer := 5000
);
port (
  -- Clock and Reset
  i_clk         : in  std_logic;
  i_reset_n     : in  std_logic;
  -- Scheduler STC Input
  i_prog_stc    : in  t_stc;
  i_temp        : in  ufixed(6 downto -2);
  -- User Interface
  i_use_f       : in  std_logic;
  i_sys_pwr_n   : in  std_logic;
  i_run_prog_n  : in  std_logic;
  i_heat_cool_n : in  std_logic_vector(2 downto 0);   -- 2: heat; 1: cool; 0: auto
  i_t_down_n    : in  std_logic;  -- Push Button, Active Low
  i_t_up_n      : in  std_logic;  -- Push Button, Active Low
  -- Controller Interface
  o_stc         : out t_stc := c_stc_idle   -- Should only update after user controls have been idle for X seconds
);
end entity usr_ctrl_ovride;

architecture usr_ctrl_ovride of usr_ctrl_ovride is
  -------------------------------------------
  --                SIGNALS                --
  -------------------------------------------
  signal  s_temp              : ufixed(6 downto -2) := 9x"C8";  -- 70
  signal  s_stc               : t_stc := c_stc_idle;
  signal  s_stc_d1            : t_stc := c_stc_idle;
  signal  s_stc_settled       : std_logic := '0';
  signal  n_stc_settle_cntr   : integer range 0 to (g_ui_idle_time - 1) := 0;
  signal  n_f_offset          : integer range 0 to 49;
  signal  n_c_offset          : integer range 0 to 55;
  signal  s_prog_stc_d1       : t_stc := c_stc_idle;
  signal  s_prog_stc_changed  : std_logic := '0';
  signal  s_btn_hold          : std_logic := '0';
  signal  n_btn_counter       : integer range 0 to (g_btn_init - 1) := 0;

  type t_manual_state is (
    IDLE,
    MANUAL_MODE,
    OVERRIDE_MODE
  );
  signal s_manual_state   : t_manual_state;
  signal s_manual_nstate  : t_manual_state;
begin
  -- s_temp control
  process(i_reset_n, i_use_f, i_temp) is
  begin
    if(i_reset_n = '0') then
      s_temp <= 9x"C8" when i_use_f = '1' else 9x"54";  -- 70F, 21C
    else
      if(i_use_f = '1') then
        if(i_temp > to_ufixed(99, 6, 0)) then
          s_temp <= 9x"18C";
        elsif(i_temp < to_ufixed(50, 5, 0)) then
          s_temp <= 9x"C8";
        else
          s_temp <= i_temp;
        end if;
      else
        if(i_temp > to_ufixed(37.5, 5, -1)) then
          s_temp <= 9x"96";
        elsif(i_temp < to_ufixed(10, 3, 0)) then
          s_temp <= 9x"28";
        else
          s_temp <= i_temp;
        end if;
      end if;
    end if;
  end process;

  -- n_f_offset control
  process(i_reset_n, s_manual_nstate, s_temp, i_run_prog_n, i_prog_stc, i_use_f, i_t_up_n, i_t_down_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_f_offset  <= 0;
    else
      case s_manual_nstate is
        when IDLE =>
          if(i_use_f = '1') then
            n_f_offset <= to_integer(s_temp - to_ufixed(50, 5, 0)) when i_run_prog_n = '1' else i_prog_stc.trgt_f_ofst;
          else
            n_f_offset <= stc_offset_c_to_f(n_c_offset);
          end if;
        when others =>
          if(i_use_f = '1') then -- Fahrenheit mode
            if(falling_edge(i_t_up_n) and i_t_down_n = '1') then  -- Temperature up initial press
              n_f_offset  <= 49 when n_f_offset = 49 else n_f_offset + 1;
            elsif(i_t_up_n = '1' and falling_edge(i_t_down_n)) then -- Temperature down initial press
              n_f_offset <= 0 when n_f_offset = 0 else n_f_offset - 1;
            elsif((i_t_down_n xor i_t_up_n) = '1') then   -- Only one of T-up/T-down being held
              if(rising_edge(i_clk)) then
                if(i_t_up_n = '0' and i_t_down_n = '1') then  -- T-up being held
                  if(s_btn_hold = '1') then                   -- T-up continuous hold
                    if(n_btn_counter = g_btn_hold - 1) then
                      n_f_offset <= 49 when n_f_offset = 49 else n_f_offset + 1;
                    end if;
                  else                                        -- T-up initial hold
                    if(n_btn_counter = g_btn_init - 1) then
                      n_f_offset <= 49 when n_f_offset = 49 else n_f_offset + 1;
                    end if;
                  end if;
                elsif(i_t_up_n = '1' and i_t_down_n = '0') then -- T-down being held
                  if(s_btn_hold = '1') then                     -- T-down continuous hold
                    if(n_btn_counter = g_btn_hold - 1) then
                      n_f_offset <= 0 when n_f_offset = 0 else n_f_offset - 1;
                    end if;
                  else                                          -- T-down initial hold
                    if(n_btn_counter = g_btn_init - 1) then
                      n_f_offset <= 0 when n_f_offset = 0 else n_f_offset - 1;
                    end if;
                  end if;
                end if;
              end if;
            end if;
          else -- Celsius Mode
            n_f_offset <= stc_offset_c_to_f(n_c_offset);
          end if;
      end case;
    end if;
  end process;

  -- n_c_offset control
  process(i_reset_n, s_manual_nstate, s_temp, i_run_prog_n, i_prog_stc, i_use_f, i_t_up_n, i_t_down_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_c_offset  <= 0;
    else
      case s_manual_nstate is
        when IDLE =>
          if(i_use_f = '1') then
            n_c_offset <= stc_offset_f_to_c(n_f_offset);
          else
            n_c_offset <= to_integer((s_temp - to_ufixed(10, 3, 0)) * to_ufixed(2, 1, 0)) when i_run_prog_n = '1' else i_prog_stc.trgt_c_ofst;
          end if;
        when others =>
          if(i_use_f = '0') then -- Celsius mode
            if(falling_edge(i_t_up_n) and i_t_down_n = '1') then  -- Temperature up initial press
              n_c_offset  <= 55 when n_c_offset = 55 else n_c_offset + 1;
            elsif(i_t_up_n = '1' and falling_edge(i_t_down_n)) then -- Temperature down initial press
              n_c_offset <= 0 when n_c_offset = 0 else n_c_offset - 1;
            elsif((i_t_down_n xor i_t_up_n) = '1') then   -- Only one of T-up/T-down being held
              if(rising_edge(i_clk)) then
                if(i_t_up_n = '0' and i_t_down_n = '1') then  -- T-up being held
                  if(s_btn_hold = '1') then                   -- T-up continuous hold
                    if(n_btn_counter = g_btn_hold - 1) then
                      n_c_offset <= 55 when n_c_offset = 55 else n_c_offset + 1;
                    end if;
                  else                                        -- T-up initial hold
                    if(n_btn_counter = g_btn_init - 1) then
                      n_c_offset <= 55 when n_c_offset = 55 else n_c_offset + 1;
                    end if;
                  end if;
                elsif(i_t_up_n = '1' and i_t_down_n = '0') then -- T-down being held
                  if(s_btn_hold = '1') then                     -- T-down continuous hold
                    if(n_btn_counter = g_btn_hold - 1) then
                      n_c_offset <= 0 when n_c_offset = 0 else n_c_offset - 1;
                    end if;
                  else                                          -- T-down initial hold
                    if(n_btn_counter = g_btn_init - 1) then
                      n_c_offset <= 0 when n_c_offset = 0 else n_c_offset - 1;
                    end if;
                  end if;
                end if;
              end if;
            end if;
          else -- Fahrenheit Mode
            n_c_offset <= stc_offset_f_to_c(n_f_offset);
          end if;
      end case;
    end if;
  end process;

  -- n_btn_counter control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_btn_counter <= 0;
    else
      if(rising_edge(i_clk)) then
        if((i_t_down_n xor i_t_up_n) = '1') then -- One button pressed
          if(s_btn_hold = '1') then
            n_btn_counter <= 0 when n_btn_counter = g_btn_hold - 1 else n_btn_counter + 1;
          else
            n_btn_counter <= 0 when n_btn_counter = g_btn_init - 1 else n_btn_counter + 1;
          end if;
        else  -- Both buttons pressed/not pressed, do nothing
          n_btn_counter <= 0;
        end if;
      end if;
    end if;
  end process;

  -- s_btn_hold control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_btn_hold <= '0';
    else
      if(rising_edge(i_clk)) then
        if((i_t_down_n xor i_t_up_n) = '1') then
          if(n_btn_counter = g_btn_init - 1) then
            s_btn_hold  <= '1';
          end if;
        else
          s_btn_hold <= '0';
        end if;
      end if;
    end if;
  end process;

  -- s_stc control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_stc <= c_stc_idle;
    else
      if(rising_edge(i_clk)) then
        case s_manual_nstate is
          when IDLE =>
            s_stc <= c_stc_idle;
          when MANUAL_MODE =>
            s_stc.heat_on <= '1' when ((i_heat_cool_n(2) = '0') or (i_heat_cool_n(0) = '0')) else '0';
            s_stc.cool_on <= '1' when ((i_heat_cool_n(1) = '0') or (i_heat_cool_n(0) = '0')) else '0';
            s_stc.force_fan <= '0'; -- Handled at top level
            s_stc.trgt_c_ofst <= n_c_offset;
            s_stc.trgt_f_ofst <= n_f_offset;
          when OVERRIDE_MODE =>
            s_stc.heat_on <= i_prog_stc.heat_on;
            s_stc.cool_on <= i_prog_stc.cool_on;
            s_stc.force_fan <= '0'; -- Handled at top level
            s_stc.trgt_c_ofst <= n_c_offset;
            s_stc.trgt_f_ofst <= n_f_offset;
        end case;
      end if;
    end if;
  end process;

  -- s_stc_d1 control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_stc_d1 <= c_stc_idle;
    else
      if(rising_edge(i_clk)) then
        s_stc_d1 <= s_stc;
      end if;
    end if;
  end process;

  -- n_stc_settle_cntr control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_stc_settle_cntr <= 0;
    else
      if(rising_edge(i_clk)) then
        if((i_t_down_n = '1') and (i_t_up_n = '1')) then
          if( (s_stc_d1.heat_on = s_stc.heat_on) and 
              (s_stc_d1.cool_on = s_stc.cool_on) and 
              (s_stc_d1.trgt_c_ofst = s_stc.trgt_c_ofst) and 
              (s_stc_d1.trgt_f_ofst = s_stc.trgt_f_ofst) and 
              (s_stc_settled = '0')) then
            n_stc_settle_cntr <= 0 when n_stc_settle_cntr = (g_ui_idle_time - 1) else n_stc_settle_cntr + 1;
          else
            n_stc_settle_cntr <= 0;
          end if;
        else
          n_stc_settle_cntr <= 0;
        end if;
      end if;
    end if;
  end process;

  -- s_stc_settled control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_stc_settled <= '0';
    else
      if(rising_edge(i_clk)) then
        if((i_t_down_n = '1') and (i_t_up_n = '1')) then
          if( (s_stc_d1.heat_on /= s_stc.heat_on) or
              (s_stc_d1.cool_on /= s_stc.cool_on) or
              (s_stc_d1.trgt_c_ofst /= s_stc.trgt_c_ofst) or
              (s_stc_d1.trgt_f_ofst /= s_stc.trgt_f_ofst)) then
            s_stc_settled <= '0';
          else
            if(s_stc_settled = '1') then
              s_stc_settled <= '1';
            else
              s_stc_settled <= '1' when n_stc_settle_cntr = (g_ui_idle_time - 1) else '0';
            end if;
          end if;
        else
          s_stc_settled <= '0';
        end if;
      end if;
    end if;
  end process;
  
  process(i_reset_n, i_sys_pwr_n, s_manual_nstate, s_stc_settled) is
  begin
    if(i_reset_n = '0') then
      o_stc <= c_stc_idle;
    else
      if(s_manual_nstate = IDLE) then
        o_stc <= c_stc_idle;
      else
        o_stc <= s_stc when s_stc_settled = '1' else o_stc;
      end if;
      -- if(i_sys_pwr_n = '0') then
      --   o_stc <= s_stc when s_stc_settled = '1' else o_stc;
      -- else
      --   o_stc <= c_stc_idle;
      -- end if;
    end if;
  end process;

  -- s_prog_stc_changed control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_prog_stc_d1 <= c_stc_idle;
    else
      if(rising_edge(i_clk)) then
        s_prog_stc_d1 <= i_prog_stc;
      end if;
    end if;
  end process;
  s_prog_stc_changed <= '0' when s_prog_stc_d1 = i_prog_stc else '1';

  -- s_manual_nstate control
  process(i_reset_n, i_sys_pwr_n, s_manual_state, i_run_prog_n, i_t_down_n, i_t_up_n, s_prog_stc_changed) is
  begin
    if(i_reset_n = '0') then
    else
      if(i_sys_pwr_n = '0') then
        case s_manual_state is
          when IDLE =>
            if(i_run_prog_n = '0') then -- system in program mode
              if(falling_edge(i_t_down_n) or falling_edge(i_t_up_n)) then
                s_manual_nstate <= OVERRIDE_MODE;
              end if;
            else  -- System in manual mode
              s_manual_nstate <= MANUAL_MODE;
            end if;
          when MANUAL_MODE =>
            s_manual_nstate <= IDLE when i_run_prog_n = '0' else MANUAL_MODE;
          when OVERRIDE_MODE =>
            s_manual_nstate <= IDLE when s_prog_stc_changed = '1' else OVERRIDE_MODE;
        end case;
      else
        s_manual_nstate <= IDLE;
      end if;
    end if;
  end process;

  -- s_manual_state control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_manual_state <= IDLE;
    else
      if(rising_edge(i_clk)) then
        s_manual_state <= s_manual_nstate;
      end if;
    end if;
  end process;

  
end architecture;
