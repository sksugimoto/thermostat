-- spi_handler.vhd
-- Author: Samuel Sugimoto
-- Date: 

-- SPI handler module for 16-bit SPI transfer
-- Part of synthesizable design

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spi_handler_thermometer is
port (
  -- System clock
  i_clk               : in  std_logic;  -- 20KHz clock
  -- Control signals
  i_data_request      : in  std_logic;
  o_data              : out std_logic_vector(15 downto 0);
  o_data_valid        : out std_logic;
  -- SPI Port
  i_spi_clk           : in  std_logic;  -- 10KHz clock
  o_spi_cs_n          : out std_logic;
  o_spi_si            : out std_logic;
  i_spi_so            : in  std_logic
);
end entity spi_handler_thermometer;

architecture spi_handler_thermometer of spi_handler_thermometer is
  -- SPI signals
  signal s_spi_data_requested : std_logic := '0';
  signal s_spi_cs_n           : std_logic := '1';
  signal n_counter            : integer range 0 to 15;
  -- SPI state machine states (runs on SPI clock)
  type t_spi_state is (
    IDLE,
    SPI_TRANSFER
  );
  signal s_spi_state  : t_spi_state := IDLE;
  signal s_spi_nstate : t_spi_state := IDLE;
  -- SPI Handler State Machine (runs on system clock)
  type t_sys_state is (
    IDLE,
    SPI_TRANSFER_WAIT,
    DATA_RETRIVED
  );
  signal s_sys_state    : t_sys_state := IDLE;
  signal s_sys_nstate   : t_sys_state := IDLE;
  signal s_data_request : std_logic   := '0';

begin
  ---------------------------------------------------
  --              SPI SIGNAL HANDLING              --
  ---------------------------------------------------
  -- Drive SPI SI low
  o_spi_si  <= '0';

  -- s_data_request control
  process(i_spi_clk) is
  begin
    if(rising_edge(i_spi_clk)) then
      s_spi_data_requested  <= i_data_request;
    end if;
  end process;

  -- SPI CS_n control
  process(s_spi_nstate, n_counter) is
  begin
    s_spi_cs_n  <= '1';
    if(s_spi_nstate = SPI_TRANSFER or (s_spi_nstate = IDLE and s_spi_state = SPI_TRANSFER)) then
      s_spi_cs_n  <= '0';
    end if;
  end process;
  o_spi_cs_n  <= s_spi_cs_n;
  
  -- Read data from SPI SO
  process(i_spi_clk) is
  begin
    if (rising_edge(i_spi_clk)) then
      if (s_spi_state = SPI_TRANSFER or (s_spi_state = IDLE and s_spi_nstate = SPI_TRANSFER)) then
        o_data(15-n_counter)  <= i_spi_so;
      end if;
    end if;
  end process;

  -- n_counter control
  process(i_spi_clk) is
  begin
    if(rising_edge(i_spi_clk)) then
      if(s_spi_state = IDLE and s_spi_nstate = SPI_TRANSFER) then
        n_counter <= n_counter + 1;
      elsif(s_spi_state = SPI_TRANSFER) then
        n_counter <= n_counter + 1 when s_spi_nstate = SPI_TRANSFER else 0;
      else
        n_counter <= 0;
      end if;
    end if;
  end process;

  -- SPI Next state control
  -- TODO: Handle unexpected behavior.
  process(s_spi_data_requested, n_counter) is
  begin
    case s_spi_state is
      when IDLE =>
        s_spi_nstate <= SPI_TRANSFER when rising_edge(s_spi_data_requested) else IDLE;
      when SPI_TRANSFER =>
        s_spi_nstate  <= IDLE when n_counter = 15 else SPI_TRANSFER;
    end case;
  end process;

  -- SPI State control
  process(i_spi_clk) is
  begin
    if(rising_edge(i_spi_clk)) then
      s_spi_state <= s_spi_nstate;
    end if;
  end process;

  -------------------------------------------
  --        HANDLER SIGNAL HANDLING        --
  -------------------------------------------
  -- o_data_valid control
  process(s_sys_nstate) is
  begin
    o_data_valid  <= '1' when s_sys_nstate = DATA_RETRIVED else '0';
  end process;
  -- System Next State Control
  process(i_data_request, s_spi_state) is
  begin
    case s_sys_state is
      when IDLE =>
        s_sys_nstate  <= SPI_TRANSFER_WAIT when rising_edge(i_data_request) else IDLE;
      when SPI_TRANSFER_WAIT =>
        s_sys_nstate  <= DATA_RETRIVED when s_spi_state = IDLE else SPI_TRANSFER_WAIT;
      when DATA_RETRIVED =>
        s_sys_nstate  <= IDLE when falling_edge(i_data_request) else DATA_RETRIVED;
    end case;
  end process;
  -- System State Control
  process(i_clk) is
  begin
    if(rising_edge(i_clk)) then
      s_sys_state <= s_sys_nstate;
    end if;
  end process;

end architecture;
