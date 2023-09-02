-- flash_model.vhd
-- Author: Samuel Sugimoto
-- Date: 

-- Model for a flash memory module used to hold thermostat programming data.
-- Modeled after SST 1Mb (2^20 = 1048576 bits) FLASH module SST25VF010A
-- As an example, datasheet indicates 4Mb (2^22 = 4,196,304 bits) can be
-- accessed with an address range of 0x00000 through 0x7FFFF (2^19 = 524,288 addresses).
-- This device is therefore byte addressed
-- Model only implements data read functionality.
-- Hold and Write Protect functionality are not implemented.

-- This model is only used for testbenches, and not part of the synthesizable design.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.flash_model_pkg.all;

entity flash_model is
port (
  -- Normal SST25VG010A connections
  i_sck     : in    std_logic;    -- SPI Clock (20MHz max)
  i_ce_n    : in    std_logic;    -- Chip Enable
  i_wp_n    : in    std_logic;    -- Write Protect
  i_hold_n  : in    std_logic;    -- Hold
  i_si      : in    std_logic;    -- SPI In
  o_so      : inout std_logic;     -- SPI Out
  -- Additional I/O for simulation/model purposes
  i_mem     : in  t_array_slv64(16383 downto 0)
);
end entity flash_model;

architecture flash_model of flash_model is
  -- SPI Memory States
  type t_spi_mem_state is (
    IDLE,
    GET_CMD,
    GET_ADDR,
    DATA_OUT,
    UNKNOWN_CMD
  );
  signal s_spi_mem_state  : t_spi_mem_state := IDLE;
  signal s_spi_mem_nstate : t_spi_mem_state := IDLE;

  -- Command signals
  signal n_cmd_clk_counter  : integer range 0 to 24;
  signal s_cmd          : std_logic_vector(7 downto 0);
  signal n_cmd_counter  : integer range 0 to 7;
  signal s_addr         : std_logic_vector(23 downto 0);
  signal n_addr_counter : integer range 0 to 23;  -- All SST25 devices use 24 bits of address, regardless of size.
  signal n_read_counter : integer range 0 to 7;

  -- FLASH Array (Byte addressed, can be inferred from datasheet)
  signal s_flash_array  : t_array_slv8(131071 downto 0) := (others => (others => '0')); -- 2^17 = 131072 addresses

begin
  -- "Program" s_flash_array
  gen_flash_array : for i in 0 to 131071 generate
    s_flash_array(i)  <= i_mem(i/8)((((i mod 8)*8)+7) downto ((i mod 8)*8));

    -- Generate statement is equivalent to:
    -- s_flash_array(0)       <= i_mem(0)(7 downto 0);
    -- s_flash_array(1)       <= i_mem(0)(15 downto 8);
    -- s_flash_array(2)       <= i_mem(0)(23 downto 16);
    -- s_flash_array(3)       <= i_mem(0)(31 downto 24);
    -- s_flash_array(4)       <= i_mem(0)(39 downto 32);
    -- s_flash_array(5)       <= i_mem(0)(47 downto 40);
    -- s_flash_array(6)       <= i_mem(0)(55 downto 48);
    -- s_flash_array(7)       <= i_mem(0)(63 downto 56);
    -- s_flash_array(8)       <= i_mem(1)(7 downto 0);
    -- s_flash_array(9)       <= i_mem(1)(15 downto 8);
    -- ...
    -- s_flash_array(2047)    <= i_mem(255)(63 downto 56);  -- End of reserved memory for thermostat programming
    -- ...
    -- s_flash_array(131070)  <= i_mem(16383)(55 downto 48);
    -- s_flash_array(131071)  <= i_mem(16383)(63 downto 56);
  end generate;

  -- o_so control
  process(s_spi_mem_nstate, s_addr, n_read_counter) is
  begin
    o_so <= 'Z';
    if (s_spi_mem_nstate = DATA_OUT) then
      o_so  <= s_flash_array(to_integer(unsigned(s_addr)))(n_read_counter);
    end if;
  end process;

  -- n_cmd_counter control
  process(i_sck) is
  begin
    if(rising_edge(i_sck)) then
      n_cmd_counter <= n_cmd_counter + 1 when s_spi_mem_nstate = GET_CMD and n_cmd_counter /= 7 else 0;
    end if;
  end process;

  -- s_cmd control
  process(i_sck) is
  begin
    if(rising_edge(i_sck)) then
      -- Read in command during GET_CMD state
      if(s_spi_mem_nstate = GET_CMD) then
        s_cmd(n_cmd_counter)  <= i_si;
      elsif(i_ce_n = '1') then
        s_cmd <= (others => '0');
      end if;
    end if;
  end process;

  -- n_addr_counter control
  process(i_sck) is
  begin
    if(rising_edge(i_sck)) then
      n_addr_counter <= n_addr_counter + 1 when s_spi_mem_nstate = GET_ADDR and n_addr_counter /= 23 else 0;
    end if;
  end process;

  -- s_addr control
  process(i_sck) is
  begin
    if(rising_edge(i_sck)) then
      if(s_spi_mem_nstate = GET_ADDR) then -- Read initial address from SPI In
        s_addr(n_addr_counter) <= i_si;
      elsif(s_spi_mem_nstate = DATA_OUT) then -- Increment address when reading data
        if n_read_counter = 7 then  -- Address should increment once every 8 SPI transactions
          -- Address pointer wraps
          s_addr <= 24x"0" when s_addr = 24x"1FFFF" else s_addr + 24x"1";
        end if;
      else
        s_addr <= 24x"0";
      end if;
    end if;
  end process;

  -- n_read_counter control
  process(i_sck) is
  begin
    if(rising_edge(i_sck)) then
      if(s_spi_mem_nstate = DATA_OUT) then
        n_read_counter <= 0 when n_read_counter = 7 else n_read_counter + 1;
      else
        n_read_counter <= 0;
      end if;
    end if;
  end process;

  -- n_cmd_clk_counter control
  process(i_sck) is
  begin
    if(rising_edge(i_sck)) then
      case s_spi_mem_nstate is
        when GET_CMD =>
          n_cmd_clk_counter <= 0 when s_spi_mem_state = IDLE else n_cmd_clk_counter + 1;
        when GET_ADDR =>
          n_cmd_clk_counter <= 0 when s_spi_mem_state = GET_CMD else n_cmd_clk_counter + 1;
        when others =>
          n_cmd_clk_counter <= 0;
      end case;
    end if;
  end process;

  -- s_spi_mem_nstate control
  -- process(i_ce_n, n_cmd_counter, n_addr_counter) is -- , s_cmd, s_addr) is
  process(i_ce_n, n_cmd_clk_counter) is
  begin
    case s_spi_mem_state is
      when IDLE =>  -- Idle state, wait for chip select falling edge
        s_spi_mem_nstate <= GET_CMD when falling_edge(i_ce_n) else IDLE;
      when GET_CMD => -- Read SPI command from SPI In.
        s_spi_mem_nstate <= IDLE when i_ce_n = '1' else GET_CMD;
        if n_cmd_clk_counter = 7 then -- Wait for 8 SPI clock cycles to read in command
          case s_cmd is
            when 8x"03" =>  -- Command is: SPI Read
              s_spi_mem_nstate  <= GET_ADDR;
            when others =>  -- Command is: Unknown
              s_spi_mem_nstate  <= UNKNOWN_CMD;
          end case;
        end if;
      when GET_ADDR =>  -- Read "read address" from SPI In line.
        s_spi_mem_nstate <= IDLE when i_ce_n = '1' else GET_ADDR;
        if n_cmd_clk_counter = 23 then -- Read SPI In line for 24 clock cycles
          -- If read address exceeds address space, go to Unknown Command state.
          s_spi_mem_nstate <= DATA_OUT when s_addr(23 downto 17) = 7x"0" else UNKNOWN_CMD;
        end if;
      when DATA_OUT =>
        s_spi_mem_nstate <= IDLE when rising_edge(i_ce_n) else DATA_OUT;
      when UNKNOWN_CMD => -- Unknown command, wait for chip select 
        s_spi_mem_nstate <= IDLE when rising_edge(i_ce_n) else UNKNOWN_CMD;
    end case;
  end process;

  -- s_spi_mem_state control
  process(i_sck) is
  begin
    if(rising_edge(i_sck)) then
      s_spi_mem_state <= s_spi_mem_nstate;
    end if;
  end process;
end architecture;
