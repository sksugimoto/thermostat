-- spi_handler_flash.vhd
-- Author: Samuel Sugimoto
-- Date: 

-- SPI Handler for SST25VF010A Flash module.
-- May be applicable to other SST25VFXXXA Flash modules of different sizes.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.global_package.all;

entity spi_handler_flash is
generic (
  g_addr_max_width  : integer := 17 -- Default of 2^17 (131,072) addresses for 1Mb (1,048,576 bits) of data.
);
port (
  -- System clock/reset
  i_sys_clk       : in  std_logic;      -- 20KHz clock
  i_reset_n       : in  std_logic;
  -- Control Signals
  i_data_request  : in  std_logic;  -- Only goes high when SPI bus is available
  i_read_addr     : in  std_logic_vector(23 downto 0);
  i_read_num      : in  integer range 0 to 2048;
  o_data_ready    : out std_logic;
  o_command_error : out std_logic;
  o_data          : out t_array_slv8(2047 downto 0);
  -- SPI Port
  i_spi_clk       : in  std_logic;  -- 10KHz clock
  o_spi_cs_n      : out std_logic;
  o_spi_si        : out std_logic;
  i_spi_so        : in  std_logic
);
end entity spi_handler_flash;

architecture spi_handler_flash of spi_handler_flash is
  -- Constants
  constant c_flash_read_cmd : std_logic_vector(7 downto 0) := 8x"03";
  -- Module I/O signals
  signal s_read_addr      : std_logic_vector(23 downto 0);
  signal n_read_num       : integer range 0 to 2048;
  -- Handle State Machine (runs on system clock)
  type t_sys_state is (
    SYS_IDLE,
    SYS_WAIT_SPI_TRANSFER,
    SYS_GET_SPI_DATA,
    SYS_DATA_READY,
    SYS_ADDR_ERR
  );
  signal s_sys_state  : t_sys_state := SYS_IDLE;
  signal s_sys_nstate : t_sys_state := SYS_IDLE;
  
  -- SPI control signals
  signal s_valid_data_req : std_logic := '0';
  signal n_spi_clk_cnt    : integer range 0 to 23;
  signal s_spi_cs_n       : std_logic := '1';
  signal s_spi_si         : std_logic := 'Z';
  signal n_spi_cmd_cnt    : integer range 0 to 7;
  signal n_spi_addr_cnt   : integer range 0 to 23;
  signal s_spi_data       : t_array_slv8(2047 downto 0) := (others => (others => '0'));
  signal n_spi_bit_cnt    : integer range 0 to 7;
  signal n_spi_word_cnt   : integer range 0 to 2047;
  signal s_spi_xfer_done  : std_logic := '0';
  -- SPI State Machine states (runs on SPI clock)
  type t_spi_state is (
    SPI_IDLE,
    SPI_SEND_CMD,
    SPI_SEND_ADDR,
    SPI_RECV_DATA,
    SPI_DATA_VALID
  );
  signal s_spi_state  : t_spi_state := SPI_IDLE;
  signal s_spi_nstate : t_spi_state := SPI_IDLE;
  
begin
  ---------------------------------------------------
  --              SPI SIGNAL HANDLING              --
  ---------------------------------------------------
  -- n_spi_cmd_cnt, increments while read command is transmitted
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then
      n_spi_cmd_cnt  <= 0;
    else
      if(rising_edge(i_spi_clk)) then
        n_spi_cmd_cnt <= n_spi_cmd_cnt + 1 when s_spi_nstate = SPI_SEND_CMD and n_spi_cmd_cnt /= 7 else 0;
      end if;
    end if;
  end process;

  -- n_spi_addr_cnt, increments while address is transmitted
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then
      n_spi_addr_cnt <= 0;
    else
      if(rising_edge(i_spi_clk)) then
        n_spi_addr_cnt <= n_spi_addr_cnt + 1 when s_spi_nstate = SPI_SEND_ADDR and n_spi_addr_cnt /= 23 else 0;
      end if;
    end if;
  end process;

  -- o_spi_cs_n control
  process(i_reset_n, s_spi_nstate) is
  begin
    if(i_reset_n = '0') then
      s_spi_cs_n <= '1';
    else
      if((s_spi_nstate = SPI_SEND_CMD) or (s_spi_nstate = SPI_SEND_ADDR) or (s_spi_nstate = SPI_RECV_DATA)) then
        s_spi_cs_n <= '0';
      else
        s_spi_cs_n <= '1';
      end if;
    end if;
  end process;
  o_spi_cs_n  <= s_spi_cs_n;

  -- s_spi_si control
  process(i_reset_n, s_spi_nstate, n_spi_cmd_cnt, s_read_addr, n_spi_addr_cnt) is
  begin
    if(i_reset_n = '0') then
      s_spi_si  <= 'Z';
    else
      case s_spi_nstate is
        when SPI_SEND_CMD =>
          s_spi_si <= c_flash_read_cmd(n_spi_cmd_cnt);
        when SPI_SEND_ADDR =>
          s_spi_si <= s_read_addr(n_spi_addr_cnt);
        when SPI_RECV_DATA =>
          s_spi_si <= '0';
        when others => -- SPI_IDLE and SPI_CMD_ERROR
          s_spi_si  <= 'Z';
      end case;
    end if;
  end process;
  o_spi_si  <= s_spi_si;

  -- n_spi_bit_cnt control
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then 
      n_spi_bit_cnt <= 0;
    else
      if(rising_edge(i_spi_clk)) then
        if(s_spi_nstate = SPI_RECV_DATA) then
          n_spi_bit_cnt <= 0 when n_spi_bit_cnt = 7 else n_spi_bit_cnt + 1;
        else
          n_spi_bit_cnt <= 0;
        end if;
      end if;
    end if;
  end process;

  -- n_spi_word_cnt Control
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then
      n_spi_word_cnt <= 0;
    else
      if(rising_edge(i_spi_clk)) then
        if((s_spi_nstate = SPI_RECV_DATA) and (n_spi_bit_cnt = 7)) then
          n_spi_word_cnt <= 0 when n_spi_word_cnt = (n_read_num - 1) else n_spi_word_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- s_spi_data control
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then
      s_spi_data <= (others => (others => '0'));
    else
      if(rising_edge(i_spi_clk)) then
        case s_spi_nstate is
          when SPI_IDLE =>
            s_spi_data <= (others => (others => '0'));
          when SPI_RECV_DATA =>
            s_spi_data(n_spi_word_cnt)(n_spi_bit_cnt) <= i_spi_so;
          when others =>
            s_spi_data <= s_spi_data;
        end case;
      end if;
    end if;
  end process;

  -- s_spi_xfer_done control
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then
      s_spi_xfer_done <= '0';
    else
      if(rising_edge(i_spi_clk)) then
        if(s_valid_data_req = '0') then
          s_spi_xfer_done <= '0';
        elsif((n_spi_word_cnt = (n_read_num - 1)) and (n_spi_bit_cnt = 7)) then
          s_spi_xfer_done <= '1';
        end if;
      end if;
    end if;
  end process;
  -- process(i_reset_n, s_spi_nstate) is
  -- begin
  --   if(i_reset_n = '0') then
  --     s_spi_xfer_done <= '0';
  --   else
  --     s_spi_xfer_done <= '1' when s_spi_nstate = SPI_DATA_VALID else '0';
  --   end if;
  -- end process;

  -- n_spi_clk_cnt control
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then
      n_spi_clk_cnt <= 0;
    else
      if(rising_edge(i_spi_clk)) then
        case s_spi_nstate is
          when SPI_SEND_CMD => 
            n_spi_clk_cnt <= 0 when ((s_spi_state = SPI_IDLE) or (n_spi_clk_cnt = 7)) else n_spi_clk_cnt + 1;
          when SPI_SEND_ADDR =>
            n_spi_clk_cnt <= 0 when ((s_spi_state = SPI_SEND_CMD) or (n_spi_clk_cnt = 23)) else n_spi_clk_cnt + 1;
          when SPI_RECV_DATA =>
            n_spi_clk_cnt <= 0 when ((s_spi_state = SPI_SEND_ADDR) or (n_spi_clk_cnt = 7)) else n_spi_clk_cnt + 1;
          when others =>
            n_spi_clk_cnt <= 0;
        end case;
      end if;
    end if;
  end process;

  -- SPI Next State Control
  process(i_reset_n, s_spi_state, s_valid_data_req, n_spi_clk_cnt, s_spi_xfer_done) is
  begin
    if(i_reset_n = '0') then
      s_spi_nstate  <= SPI_IDLE;
    else
      case s_spi_state is
        when SPI_IDLE => 
          s_spi_nstate  <= SPI_SEND_CMD when s_valid_data_req = '1' else SPI_IDLE;
        when SPI_SEND_CMD =>
          s_spi_nstate  <= SPI_SEND_ADDR when n_spi_clk_cnt = 7 else SPI_SEND_CMD;
        when SPI_SEND_ADDR =>
          s_spi_nstate  <= SPI_RECV_DATA when n_spi_clk_cnt = 23 else SPI_SEND_ADDR;
        when SPI_RECV_DATA =>
          s_spi_nstate  <= SPI_DATA_VALID when s_spi_xfer_done = '1' else SPI_RECV_DATA;
        when SPI_DATA_VALID =>
          s_spi_nstate  <= SPI_IDLE when s_valid_data_req = '0' else SPI_DATA_VALID;
      end case;
    end if;
  end process;
  
  -- SPI State Control
  process(i_reset_n, i_spi_clk) is
  begin
    if(i_reset_n = '0') then
      s_spi_state <= SPI_IDLE;
    else
      if(rising_edge(i_spi_clk)) then
        s_spi_state <= s_spi_nstate;
      end if;
    end if;
  end process;

  -------------------------------------------
  --        HANDLER SIGNAL HANDLING        --
  -------------------------------------------
  -- Handles all module level I/O
  -- s_read_addr, n_read_num, s_valid_data_req Control
  process(i_reset_n, i_sys_clk) is
  begin
    if(i_reset_n = '0') then
      s_read_addr       <= (others => '0');
      n_read_num        <= 0;
      s_valid_data_req  <= '0';
    else
      -- Set s_read_addr on first rising edge of sys clock after i_data_request asserted.
      if(rising_edge(i_sys_clk)) then
        if(s_sys_nstate = SYS_WAIT_SPI_TRANSFER and s_sys_state = SYS_IDLE) then
          s_read_addr       <= i_read_addr;
          n_read_num        <= i_read_num;
          s_valid_data_req  <= '1';
        elsif(s_sys_nstate = SYS_GET_SPI_DATA) then
          s_valid_data_req  <= '0';
        elsif(s_sys_state = SYS_IDLE) then
          s_read_addr       <= (others => '0');
          n_read_num        <= 0;
        end if;
      end if;
    end if;
  end process;

  -- o_data_ready control
  process(i_reset_n, s_sys_nstate) is
  begin
    if(i_reset_n = '0') then
      o_data_ready <= '0';
    else
      if(s_sys_nstate = SYS_DATA_READY) then
        o_data_ready <= '1';
      else
        o_data_ready <= '0';
      end if;
    end if;
  end process;

  -- o_data control
  process(i_reset_n, s_sys_nstate, s_spi_data) is
  begin
    if(i_reset_n = '0') then
      o_data <= (others => (others => '0'));
    else
      o_data <= s_spi_data when s_sys_nstate = SYS_DATA_READY else (others => (others => '0'));
    end if;
  end process;

  -- o_command_error control
  process(i_reset_n, s_sys_nstate) is
  begin
    if(i_reset_n = '0') then
      o_command_error <= '0';
    else
      o_command_error <= '1' when s_sys_nstate = SYS_ADDR_ERR else '0';
    end if;
  end process;

  -- System Next State Control
  process(i_reset_n, s_sys_state, i_data_request, i_read_addr, s_spi_xfer_done) is
  begin
    if(i_reset_n = '0') then
      s_sys_nstate  <= SYS_IDLE;
    else
      case s_sys_state is
        when SYS_IDLE =>
          s_sys_nstate <= SYS_IDLE;
          -- Determine next state, proceed to data read if address is valid.
          if(i_data_request = '1') then
            -- Check starting address doesn't exceed addressable memory.
            s_sys_nstate <= SYS_WAIT_SPI_TRANSFER when or(i_read_addr(23 downto g_addr_max_width)) = '0' else SYS_ADDR_ERR;
          end if;
        when SYS_WAIT_SPI_TRANSFER =>
          s_sys_nstate <= SYS_GET_SPI_DATA when s_spi_xfer_done = '1' else SYS_WAIT_SPI_TRANSFER;
        when SYS_GET_SPI_DATA =>
          s_sys_nstate <= SYS_DATA_READY when s_spi_xfer_done = '0' else SYS_GET_SPI_DATA;
        when SYS_DATA_READY =>
          -- s_sys_nstate <= SYS_IDLE when ((i_data_request = '0') and (s_spi_xfer_done = '0')) else SYS_DATA_READY;
          s_sys_nstate <= SYS_IDLE when i_data_request = '0' else SYS_DATA_READY;
        when SYS_ADDR_ERR =>
          s_sys_nstate <= SYS_IDLE when i_data_request = '0' else SYS_ADDR_ERR;
      end case;
    end if;
  end process;

  -- System State Control
  process(i_reset_n, i_sys_clk) is
  begin
    if(i_reset_n = '0') then
      s_sys_state <= SYS_IDLE;
    else
      if(rising_edge(i_sys_clk)) then
        s_sys_state <= s_sys_nstate;
      end if;
    end if;
  end process;

end architecture;