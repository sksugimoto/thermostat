-- time_keeper.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Handles time keeping, and setting of time via user interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity time_keeper is
generic (
  -- Set to different value for simulation
  g_clk_freq  : integer := 20000;
  g_btn_init  : integer := 20000;
  g_btn_hold  : integer := 5000
);
port (
  -- Clock and Reset
  i_clk         : in  std_logic;  -- 20KHz clock
  i_reset_n     : in  std_logic;

  -- User Interface
  i_set_time_n  : in  std_logic;  -- Active Low
  i_incr_day_n  : in  std_logic;  -- Active Low
  i_incr_hr_n   : in  std_logic;  -- Active Low
  i_incr_min_n  : in  std_logic;  -- Active Low

  -- Time
  o_day         : out std_logic_vector(6 downto 0); -- One-hot reference to day
  o_hour        : out std_logic_vector(4 downto 0);
  o_minute      : out std_logic_vector(5 downto 0)
);
end entity time_keeper;

architecture time_keeper of time_keeper is
  -- Signals
  signal n_day          : integer range 0 to 6  := 0; -- 0: Sunday; 1: Monday; 2: Tuesday ...
  signal n_hour         : integer range 0 to 23 := 0;
  signal n_minute       : integer range 0 to 59 := 0;
  signal n_second       : integer range 0 to 59 := 0;
  signal n_clk_counter  : integer range 0 to (g_clk_freq - 1) := 0;
  signal n_day_cntr     : integer range 0 to (g_btn_init - 1) := 0;
  signal n_hr_cntr      : integer range 0 to (g_btn_init - 1) := 0;
  signal n_min_cntr     : integer range 0 to (g_btn_init - 1) := 0;
  signal s_incr_day_hld : std_logic := '0';
  signal s_incr_hr_hld  : std_logic := '0';
  signal s_incr_min_hld : std_logic := '0';

begin
  -------------------------------------------
  --            SECONDS CONTROL            --
  -------------------------------------------
  -- n_clk_counter control
  process(i_reset_n, i_set_time_n, i_clk) is
  begin
    if(i_reset_n = '0' or i_set_time_n = '0') then
      n_clk_counter <= 0;
    else
      if(rising_edge(i_clk)) then
        n_clk_counter <= 0 when n_clk_counter = (g_clk_freq - 1) else n_clk_counter + 1;
      end if;
    end if;
  end process;

  -- n_second control
  process(i_reset_n, i_set_time_n, i_clk) is
  begin
    if(i_reset_n = '0' or i_set_time_n = '0') then
      n_second <= 0;
    else
      if(rising_edge(i_clk)) then
        if(n_clk_counter = g_clk_freq - 1) then
          n_second <= 0 when n_second = 59 else n_second + 1;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------
  --            MINUTES CONTROL            --
  -------------------------------------------
  -- n_minute control
  process(i_reset_n, i_set_time_n, i_incr_min_n, i_clk) is 
  begin
    if(i_reset_n = '0') then
      n_minute <= 0;
    elsif(i_set_time_n = '0') then
      if(falling_edge(i_incr_min_n)) then
        n_minute <= 0 when n_minute = 59 else n_minute + 1;
      elsif(i_incr_min_n = '0') then
        if(rising_edge(i_clk)) then
          if(s_incr_min_hld = '1') then
            if(n_min_cntr = g_btn_hold - 1) then
              n_minute <= 0 when n_minute = 59 else n_minute + 1;
            end if;
          else
            if(n_min_cntr = g_btn_init - 1) then
              n_minute <= 0 when n_minute = 59 else n_minute + 1;
            end if;
          end if;
        end if;
      end if;
    else
      if(rising_edge(i_clk)) then
        if((n_second) = 59 and (n_clk_counter = (g_clk_freq - 1))) then
          n_minute <= 0 when n_minute = 59 else n_minute + 1;
        end if;
      end if;
    end if;
  end process;

  -- n_min_cntr control
  process(i_reset_n, i_set_time_n, i_incr_min_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_min_cntr <= 0;
    else
      if(rising_edge(i_clk)) then
        if(i_set_time_n = '0' and i_incr_min_n = '0') then    
          if(s_incr_min_hld = '1') then
            n_min_cntr <= 0 when n_min_cntr = g_btn_hold - 1 else n_min_cntr + 1;
          else
            n_min_cntr <= 0 when n_min_cntr = g_btn_init - 1 else n_min_cntr + 1;
          end if;
        else
          n_min_cntr <= 0;
        end if;
      end if;
    end if;
  end process;

  -- s_incr_min_hld control
  process(i_reset_n, i_set_time_n, i_incr_min_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_incr_min_hld <= '0';
    else
      if(rising_edge(i_clk)) then
        if(i_set_time_n = '0' and i_incr_min_n = '0') then
          if(n_min_cntr = g_btn_init - 1) then
            s_incr_min_hld <= '1';
          end if;
        else
          s_incr_min_hld <= '0';
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------
  --             HOURS CONTROL             --
  -------------------------------------------
    -- n_hour control
  process(i_reset_n, i_set_time_n, i_incr_hr_n, i_clk) is 
  begin
    if(i_reset_n = '0') then
      n_hour <= 0;
    elsif(i_set_time_n = '0') then
      if(falling_edge(i_incr_hr_n)) then
        n_hour <= 0 when n_hour = 23 else n_hour + 1;
      elsif(i_incr_hr_n = '0') then
        if(rising_edge(i_clk)) then
          if(s_incr_hr_hld = '1') then
            if(n_hr_cntr = g_btn_hold - 1) then
              n_hour <= 0 when n_hour = 23 else n_hour + 1;
            end if;
          else
            if(n_hr_cntr = g_btn_init - 1) then
              n_hour <= 0 when n_hour = 23 else n_hour + 1;
            end if;
          end if;
        end if;
      end if;
    else
      if(rising_edge(i_clk)) then
        if((n_minute = 59) and (n_second = 59) and (n_clk_counter = (g_clk_freq - 1))) then
          n_hour <= 0 when n_hour = 23 else n_hour + 1;
        end if;
      end if;
    end if;
  end process;

  -- n_hr_cntr control
  process(i_reset_n, i_set_time_n, i_incr_hr_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_hr_cntr <= 0;
    else
      if(rising_edge(i_clk)) then
        if(i_set_time_n = '0' and i_incr_hr_n = '0') then    
          if(s_incr_hr_hld = '1') then
            n_hr_cntr <= 0 when n_hr_cntr = g_btn_hold - 1 else n_hr_cntr + 1;
          else
            n_hr_cntr <= 0 when n_hr_cntr = g_btn_init - 1 else n_hr_cntr + 1;
          end if;
        else
          n_hr_cntr <= 0;
        end if;
      end if;
    end if;
  end process;

  -- s_incr_hr_hld control
  process(i_reset_n, i_set_time_n, i_incr_hr_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_incr_hr_hld <= '0';
    else
      if(rising_edge(i_clk)) then
        if(i_set_time_n = '0' and i_incr_hr_n = '0') then
          if(n_hr_cntr = g_btn_init - 1) then
            s_incr_hr_hld <= '1';
          end if;
        else
          s_incr_hr_hld <= '0';
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------
  --             DAYS CONTROL             --
  ------------------------------------------
    -- n_day control
  process(i_reset_n, i_set_time_n, i_incr_day_n, i_clk) is 
  begin
    if(i_reset_n = '0') then
      n_day <= 0;
    elsif(i_set_time_n = '0') then
      if(falling_edge(i_incr_day_n)) then
        n_day <= 0 when n_day = 6 else n_day + 1;
      elsif(i_incr_day_n = '0') then
        if(rising_edge(i_clk)) then
          if(s_incr_day_hld = '1') then
            if(n_day_cntr = g_btn_hold - 1) then
              n_day <= 0 when n_day = 6 else n_day + 1;
            end if;
          else
            if(n_day_cntr = g_btn_init - 1) then
              n_day <= 0 when n_day = 6 else n_day + 1;
            end if;
          end if;
        end if;
      end if;
    else
      if(rising_edge(i_clk)) then
        if((n_hour = 23) and (n_minute = 59) and (n_second = 59) and (n_clk_counter = (g_clk_freq - 1))) then
          n_day <= 0 when n_day = 6 else n_day + 1;
        end if;
      end if;
    end if;
  end process;

  -- n_day_cntr control
  process(i_reset_n, i_set_time_n, i_incr_day_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_day_cntr <= 0;
    else
      if(rising_edge(i_clk)) then
        if(i_set_time_n = '0' and i_incr_day_n = '0') then    
          if(s_incr_day_hld = '1') then
            n_day_cntr <= 0 when n_day_cntr = g_btn_hold - 1 else n_day_cntr + 1;
          else
            n_day_cntr <= 0 when n_day_cntr = g_btn_init - 1 else n_day_cntr + 1;
          end if;
        else
          n_day_cntr <= 0;
        end if;
      end if;
    end if;
  end process;

  -- s_incr_day_hld control
  process(i_reset_n, i_set_time_n, i_incr_day_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_incr_day_hld <= '0';
    else
      if(rising_edge(i_clk)) then
        if(i_set_time_n = '0' and i_incr_day_n = '0') then
          if(n_day_cntr = g_btn_init - 1) then
            s_incr_day_hld <= '1';
          end if;
        else
          s_incr_day_hld <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Output control
  -- o_day control
  gen_day : for i in 0 to 6 generate
    o_day(i) <= '1' when i = n_day else '0';
  end generate;
  
  -- o_hour control
  o_hour <= std_logic_vector(to_unsigned(n_hour, o_hour'length));

  -- o_minute control
  o_minute <= std_logic_vector(to_unsigned(n_minute, o_minute'length));

end architecture;
