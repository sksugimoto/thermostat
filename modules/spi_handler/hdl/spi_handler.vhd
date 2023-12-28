-- spi_handler.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Handles SPI communication between FPGA, thermometer IC and FLASH IC.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.global_package.all;

entity spi_handler is
port (
  -- System clock
  i_clk             : in  std_logic;  -- 20KHz clock
  i_reset_n         : in  std_logic;  -- Pull low when SPI disconnceted for FLASH reprogramming.
  -- Programming Request Controls
  i_read_program    : in  std_logic;
  o_program_data    : out t_array_slv64(263 downto 0);
  o_program_ready   : out std_logic;
  -- Temperatrue Request Controls
  i_read_therm      : in  std_logic;
  o_temperature     : out std_logic_vector(9 downto 0);
  o_therm_ready     : out std_logic;
  -- SPI Port
  i_spi_disconnect  : in  std_logic;
  o_spi_clk         : out std_logic;  -- 10KHz clock
  o_spi_cs_n        : out std_logic_vector(1 downto 0);
  o_spi_si          : out std_logic;
  i_spi_so          : in  std_logic
);
end entity spi_handler;

architecture spi_handler of spi_handler is
  -- Constants
  constant c_flash_prog_read_addr : std_logic_vector(23 downto 0) := 24x"0";
  constant c_flash_prog_read_num  : integer := 2112;

  -- Handler State Machine typedef
  type t_handler_state is (
    IDLE,
    WAITING_PROG_DATA,
    WAITING_THERM_DATA,
    PROG_DATA_READY,
    THERM_DATA_READY
  );
  signal s_handler_state  : t_handler_state := IDLE;
  signal s_handler_nstate : t_handler_state := IDLE;

  -- SPI handler signals
  signal s_spi_clk  : std_logic := '1';
  signal s_reset_n  : std_logic := '1';
  signal s_spi_cs_n : std_logic_vector(1 downto 0) := (others => '1');
  signal s_spi_si   : std_logic := 'Z';
  signal s_spi_so   : std_logic;
  -- SPI Flash handler signals
  signal s_flash_data_request : std_logic;
  signal s_flash_data_ready   : std_logic;
  signal s_program_ready      : std_logic := '0';
  signal s_flash_data         : t_array_slv8(4095 downto 0) := (others => (others => '0'));
  signal s_program_data       : t_array_slv8(4095 downto 0) := (others => (others => '0'));
  signal s_flash_spi_cs_n     : std_logic;
  signal s_flash_spi_si       : std_logic;
  signal s_flash_spi_so       : std_logic := 'Z';
  -- SPI Thermometer handler signals
  signal s_therm_data_request : std_logic := '0';
  signal s_therm_data         : std_logic_vector(15 downto 0) := (others => '0');
  signal s_therm_ready        : std_logic := '0';
  signal s_temperature        : std_logic_vector(15 downto 0) := (others => '0');
  signal s_therm_data_valid   : std_logic;
  signal s_therm_spi_cs_n     : std_logic;
  signal s_therm_spi_si       : std_logic;
  signal s_therm_spi_so       : std_logic := 'Z';
begin
  --------------------------------------------
  --        COMPONENT INSTANTIATIONS        --
  --------------------------------------------
  -- Flash SPI handler
  spi_flash : entity work.spi_handler_flash
  generic map (
    g_addr_max_width => 17
  )
  port map (
    -- System clock
    i_sys_clk       => i_clk,      -- 20KHz clock
    i_reset_n       => s_reset_n,
    -- Control Signals
    i_data_request  => s_flash_data_request,
    i_read_addr     => c_flash_prog_read_addr,
    i_read_num      => c_flash_prog_read_num,
    o_data_ready    => s_flash_data_ready,
    o_command_error => open,
    o_data          => s_flash_data,
    -- SPI Port
    i_spi_clk       => s_spi_clk,  -- 10KHz clock
    o_spi_cs_n      => s_flash_spi_cs_n,
    o_spi_si        => s_flash_spi_si,
    i_spi_so        => s_flash_spi_so
  );
  -- Thermometer SPI handler
  spi_therm : entity work.spi_handler_thermometer
  port map (
    -- System clock
    i_clk           => i_clk,      -- 20KHz clock
    i_reset_n       => s_reset_n,
    -- Control Signals
    i_data_request  => s_therm_data_request,
    o_data          => s_therm_data,
    o_data_valid    => s_therm_data_valid,
    -- SPI Port
    i_spi_clk       => s_spi_clk,  -- 10KHz clock
    o_spi_cs_n      => s_therm_spi_cs_n,
    o_spi_si        => s_therm_spi_si,
    i_spi_so        => s_therm_spi_so
  );
  
  -------------------------------------------
  --             SPI CLOCK GEN             --
  -------------------------------------------
  -- Generate SPI clock 10KHz
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_spi_clk <= '1';
    else
      if(rising_edge(i_clk)) then
        s_spi_clk <= not(s_spi_clk);
      end if;
    end if;
  end process;
  o_spi_clk <= s_spi_clk when i_spi_disconnect = '0' else 'Z';

  --------------------------------------------
  --       FLASH HANDLER I/O CONTROLS       --
  --------------------------------------------
  -- s_flash_data_request control
  process(i_reset_n, s_handler_nstate) is
  begin
    if(i_reset_n = '0') then
      s_flash_data_request <= '0';
    else
      s_flash_data_request <= '1' when s_handler_nstate = WAITING_PROG_DATA else '0';
    end if;
  end process;

  -- s_program_data control
  process(i_reset_n, s_handler_nstate, s_handler_state, s_flash_data) is
  begin
    if(i_reset_n = '0') then
      s_program_data <= (others => (others => '0'));
    else
      if(s_handler_nstate = PROG_DATA_READY) then
        if(s_handler_state = WAITING_PROG_DATA) then
          s_program_data <= s_flash_data;
        end if;
      else
        s_program_data <= (others => (others => '0'));
      end if;
    end if;
  end process;
  
  -- Convert s_program_data (t_array_slv8) to o_program_data (t_array_slv64).
  gen_program_data : for i in 0 to 2111 generate
    o_program_data(i/8)((((i mod 8)*8)+7) downto ((i mod 8)*8)) <= s_program_data(i);
    
    -- Generate statement is equivalent to:
    -- o_program_data(0)(7 downto 0)      <= s_program_data(0);
    -- o_program_data(0)(15 downto 8)     <= s_program_data(1);
    -- o_program_data(0)(23 downto 16)    <= s_program_data(2);
    -- o_program_data(0)(31 downto 24)    <= s_program_data(3);
    -- o_program_data(0)(39 downto 32)    <= s_program_data(4);
    -- o_program_data(0)(47 downto 40)    <= s_program_data(5);
    -- o_program_data(0)(55 downto 48)    <= s_program_data(6);
    -- o_program_data(0)(63 downto 56)    <= s_program_data(7);
    -- ...
    -- o_program_data(263)(55 downto 48)  <= s_program_data(2110);
    -- o_program_data(263)(63 downto 56)  <= s_program_data(2111);
  end generate;

  -- s_program_ready control
  process(i_reset_n, s_handler_nstate) is
  begin
    if(i_reset_n = '0') then
      s_program_ready <= '0';
    else
      s_program_ready <= '1' when s_handler_nstate = PROG_DATA_READY else '0';
    end if;
  end process;
  o_program_ready <= s_program_ready;

  --------------------------------------------
  --    THERMOMETER HANDLER I/O CONTROLS    --
  --------------------------------------------
  -- s_therm_data_request control
  process(i_reset_n, s_handler_nstate) is
  begin
    if(i_reset_n = '0') then
      s_therm_data_request <= '0';
    else
      s_therm_data_request <= '1' when s_handler_nstate = WAITING_THERM_DATA else '0';
    end if;
  end process;

  -- s_temperature control
  process(i_reset_n, s_handler_nstate, s_handler_nstate, s_therm_data) is
  begin
    if(i_reset_n = '0') then
      s_temperature <= (others => '0');
    else
      if(s_handler_nstate = THERM_DATA_READY) then
        if(s_handler_state = WAITING_THERM_DATA) then
          s_temperature <= s_therm_data;
        end if;
      else
        s_temperature <= (others => '0');
      end if;
    end if;
  end process;
  o_temperature <= s_temperature(14 downto 5);

  -- s_therm_ready control
  process(i_reset_n, s_handler_nstate) is
  begin
    if(i_reset_n = '0') then
      s_therm_ready <= '0';
    else
      s_therm_ready <= '1' when s_handler_nstate = THERM_DATA_READY else '0';
    end if;
  end process;
  o_therm_ready <= s_therm_ready;
  
  -------------------------------------------
  --        HANDLER SIGNAL HANDLING        --
  -------------------------------------------
  -- s_reset_n controls
  s_reset_n <= '0' when ((i_reset_n = '0') or (i_spi_disconnect = '1')) else '1';

  -- o_spi_cs_n controls
  process(i_reset_n, s_flash_spi_cs_n, s_therm_spi_cs_n) is
  begin
    s_spi_cs_n <= s_flash_spi_cs_n & s_therm_spi_cs_n when i_reset_n = '1' else (others => '1');
  end process;
  o_spi_cs_n <= s_spi_cs_n when i_spi_disconnect = '0' else (others => 'Z');

  -- o_spi_si controls
  process(i_reset_n, s_handler_nstate, s_flash_spi_si, s_therm_spi_si) is
  begin
    if(i_reset_n = '0') then
      s_spi_si  <= 'Z';
    else
      if(s_handler_nstate = WAITING_PROG_DATA) then
        s_spi_si <= s_flash_spi_si;
      elsif(s_handler_nstate = WAITING_THERM_DATA) then
        s_spi_si <= s_therm_spi_si;
      else
        s_spi_si <= 'Z';
      end if;
    end if;
  end process;
  o_spi_si <= s_spi_si when i_spi_disconnect = '0' else 'Z';

  -- i_spi_so controls
  s_spi_so <= i_spi_so when i_spi_disconnect = '0' else '0';
  process(i_reset_n, s_handler_nstate, s_spi_so) is
  begin
    if(i_reset_n = '0') then
      s_flash_spi_so  <= '0';
      s_therm_spi_so  <= '0';
    else
      if(s_handler_nstate = WAITING_PROG_DATA) then
        s_flash_spi_so  <= s_spi_so;
        s_therm_spi_so  <= '0';
      elsif(s_handler_nstate = WAITING_THERM_DATA) then
        s_flash_spi_so  <= '0';
        s_therm_spi_so  <= s_spi_so;
      else
        s_flash_spi_so  <= '0';
        s_therm_spi_so  <= '0';
      end if;
    end if;
  end process;
  
  -- Handler Next State control
  process(i_reset_n, i_spi_disconnect, s_handler_state, i_read_program, i_read_therm, s_flash_data_ready, s_therm_data_valid) is
  begin
    if(i_reset_n = '0' or i_spi_disconnect = '1') then
      s_handler_nstate <= IDLE;
    else
      case s_handler_state is
        when IDLE =>
          -- Priortize reading programming data from FLASH
          if(i_read_program = '1') then
            s_handler_nstate <= WAITING_PROG_DATA;
          elsif(i_read_therm = '1') then
            s_handler_nstate <= WAITING_THERM_DATA;
          else
            s_handler_nstate <= IDLE;
          end if;
        when WAITING_PROG_DATA =>
          s_handler_nstate <= PROG_DATA_READY when s_flash_data_ready = '1' else WAITING_PROG_DATA;
        when WAITING_THERM_DATA =>
          s_handler_nstate <= THERM_DATA_READY when s_therm_data_valid = '1' else WAITING_THERM_DATA;
        when PROG_DATA_READY =>
          if(i_read_program = '0') then
            s_handler_nstate <= WAITING_THERM_DATA when i_read_therm = '1' else IDLE;
          end if;
        when THERM_DATA_READY =>
          if(i_read_therm = '0') then
            s_handler_nstate <= WAITING_PROG_DATA when i_read_program = '1' else IDLE;
          end if;
      end case;
    end if;
  end process;
  
  -- Handler State control
  process(i_reset_n, i_spi_disconnect, i_clk) is
  begin
    if(i_reset_n = '0' or i_spi_disconnect = '1') then
      s_handler_state <= IDLE;
    else
      if(rising_edge(i_clk)) then
        s_handler_state <= s_handler_nstate;
      end if;
    end if;
  end process;
end architecture;
