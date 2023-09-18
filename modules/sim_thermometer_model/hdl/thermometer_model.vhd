-- thermometer_model.v
-- Author: Samuel Sugimoto
-- Date:

-- Emulates a TI TMP125 SPI thermometer in continuous conversion mode
-- Functionality testing limted to positive degrees celsius
-- Only needed for simulation, does not need to be synthesizable

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity thermometer_model is
generic (
  g_spi_clk_freq : integer := 10000
);
port (
    -- Normal TI TMP125 connections
    i_spi_clk   : in  std_logic;  -- 10MHz Max SPI clock, set to 10KHz
    i_spi_cs_n  : in  std_logic;
    i_spi_si    : in  std_logic;
    o_spi_so    : out std_logic;
    -- Additional I/O for simulation/model purposes
    i_heat      : in  std_logic;
    i_cool      : in  std_logic;
    i_amb_hc    : in  std_logic
);
end entity thermometer_model;

architecture thermometer_model of thermometer_model is
  -- SPI Slave State Machine States
  type t_spi_state is (
    IDLE,
    SPI_TRANSFER
  );
  signal  s_spi_state   : t_spi_state;
  signal  s_spi_nstate  : t_spi_state;
  -- Temperature Change Increments
  constant c_dAMB   : std_logic_vector(9 downto 0)  := 10x"1";
  constant c_dHVAC  : std_logic_vector(9 downto 0)  := 10x"2";
  -- Temperature conversion
  signal  s_air_temperature     : std_logic_vector(9 downto 0)  := 10x"54"; -- Default value of 21C (70F)
  signal  s_air_temp_clk_cntr   : integer range 0 to ((g_spi_clk_freq / 2) - 1) := 0;
  -- Latest Temperature conversion
  signal  s_temperature     : std_logic_vector(9 downto 0)  := 10x"0";
  signal  s_temp_clk_cntr   : integer range 0 to ((g_spi_clk_freq / 5) - 1) := 0;
  signal  s_spi_temperature : std_logic_vector(9 downto 0)  := 10x"0";
  signal  s_spi_so          : std_logic;
  signal  n_counter         : integer range 0 to 15;  -- tracks number of bits transfered
  
begin
  -- Emulate change in air temperature
  -- For testing purposes, temperature changes every 500ms
  process(i_spi_clk) is
  begin
    if(rising_edge(i_spi_clk)) then
      if(s_air_temp_clk_cntr = ((g_spi_clk_freq / 2) - 1)) then
        if (i_amb_hc = '0') then
          if (i_heat = '0' and i_cool = '1') then
            s_air_temperature <= s_air_temperature - c_dHVAC - c_dAMB;
          elsif(i_heat = '1' and i_cool = '0') then
            s_air_temperature <= s_air_temperature + c_dHVAC - c_dAMB;
          else
            s_air_temperature <= s_air_temperature - c_dAMB;
          end if;
        else 
          if (i_heat = '0' and i_cool = '1') then
            s_air_temperature <= s_air_temperature - c_dHVAC + c_dAMB;
          elsif(i_heat = '1' and i_cool = '0') then
            s_air_temperature <= s_air_temperature + c_dHVAC + c_dAMB;
          else 
            s_air_temperature <= s_air_temperature + c_dAMB;
          end if;
        end if;
      end if;
    end if;
  end process;
  -- s_air_temp_clk_cntr control
  process(i_spi_clk) is
  begin
    if(rising_edge(i_spi_clk)) then
      s_air_temp_clk_cntr <= 0 when (s_air_temp_clk_cntr = ((g_spi_clk_freq / 2) - 1)) else s_air_temp_clk_cntr + 1;
    end if;
  end process;

  -- SPI temperature update, occurs every 120 ms on actual chip
  -- For testing purposes, assume update occurs every 200ms
  process(i_spi_clk) is
  begin
    if(rising_edge(i_spi_clk)) then
      if(s_temp_clk_cntr = ((g_spi_clk_freq / 5) - 1)) then
        s_temperature <= s_air_temperature;
      end if;
    end if;
  end process;
  -- s_temp_clk_cntr control
  process(i_spi_clk) is
  begin
    if(rising_edge(i_spi_clk)) then
      s_temp_clk_cntr <= 0 when (s_temp_clk_cntr = ((g_spi_clk_freq / 5) - 1)) else s_temp_clk_cntr + 1;
    end if;
  end process;

  -- n_counter increment
  process(i_spi_cs_n, i_spi_clk) is
  begin
    if(i_spi_cs_n = '1') then
      n_counter <= 0;
    else
      if (rising_edge(i_spi_clk)) then
        if (s_spi_nstate = IDLE) then
          n_counter <= 0;
        elsif (s_spi_nstate = SPI_TRANSFER) then
          n_counter <= n_counter + 1;
        end if;
      end if;
    end if;
  end process;

  -- Capture SPI tempeature when chipselect goes low
  process(i_spi_cs_n) is
  begin
    s_spi_temperature <= s_temperature;
  end process;

  -- o_spi_so Control
  process (s_spi_nstate, n_counter) is
  begin
    if (s_spi_nstate = SPI_TRANSFER) then
      if (n_counter = 0) then
        o_spi_so  <= '0';
      elsif (n_counter > 10) then
        o_spi_so  <= s_spi_temperature(0);
      else
        o_spi_so  <= s_spi_temperature(9 - (n_counter - 1));
      end if;
    elsif (s_spi_nstate = IDLE and n_counter = 15) then
      o_spi_so  <= s_spi_temperature(0);
    else -- s_spi_nstate = IDLE
      o_spi_so  <= 'Z';
    end if;
  end process;

  -- Next State control
  process (i_spi_cs_n, n_counter) is
  begin
    if(i_spi_cs_n = '1') then
      s_spi_nstate <= IDLE;
    else
      case s_spi_state is
        when IDLE =>
          s_spi_nstate  <= IDLE;
          if(falling_edge(i_spi_cs_n)) then
            s_spi_nstate  <= SPI_TRANSFER;
          end if;
        when SPI_TRANSFER =>
          s_spi_nstate  <= SPI_TRANSFER;
          if (n_counter = 15 or i_spi_cs_n = '1') then
            s_spi_nstate  <= IDLE;
          end if;
      end case;
    end if;
  end process;

  -- State control
  process(i_spi_cs_n, i_spi_clk) is
  begin
    if(i_spi_cs_n = '1') then
      s_spi_state <= IDLE;
    else
      if (rising_edge(i_spi_clk)) then
        s_spi_state <= s_spi_nstate;
      end if;
    end if;
  end process;
end architecture;

