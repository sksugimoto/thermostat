-- spi_data_handler.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.global_package.all;

entity spi_data_handler is
port (
  i_clk             : in  std_logic;
  i_reset_n         : in  std_logic;
  i_sys_pwr_n       : in  std_logic;
  i_reprogram_n     : in  std_logic;
  i_time_second     : in  std_logic_vector(5 downto 0);
  -- Program data signals
  o_program_req     : out std_logic;
  i_program_rdy     : in  std_logic;
  i_sh_prog_data    : in  t_array_slv64(263 downto 0);
  o_last_prog_data  : out t_array_slv64(263 downto 0);
  -- Temperature data signals
  o_temp_req        : out std_logic;
  i_temp_rdy        : in  std_logic;
  i_sh_temp_data    : in  std_logic_vector(9 downto 0);
  o_last_temp_data  : out std_logic_vector(9 downto 0)
);
end entity spi_data_handler;

architecture spi_data_handler of spi_data_handler is
  signal s_waiting_program  : std_logic := '0';
  signal s_program_req      : std_logic := '0';
  signal s_temp_req         : std_logic := '0';
  signal s_second_d1        : std_logic_vector(5 downto 0) := (others => '0');
  signal s_last_prog_data   : t_array_slv64(263 downto 0) := (others => (others => '0'));
  signal s_last_temp_data   : std_logic_vector(9 downto 0) := (others => '0');

  type spi_request_state is (
    IDLE,
    PROGRAM_REQ,
    PROG_DATA_AVAIL,
    TEMPERATURE_REQ,
    TEMP_DATA_AVAIL
  );
  signal s_spi_req_state  : spi_request_state := IDLE;
  signal s_spi_req_nstate : spi_request_state := IDLE;
begin
  -- o_last_prog_data control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_last_prog_data <= (others => (others => '0'));
    else
      if(rising_edge(i_clk)) then
        case s_spi_req_nstate is
          when PROG_DATA_AVAIL =>
            s_last_prog_data <= i_sh_prog_data;
          when others =>
            s_last_prog_data <= s_last_prog_data;
        end case;
      end if;
    end if;
  end process;
  o_last_prog_data <= s_last_prog_data;

  -- o_last_temp_data control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_last_temp_data <= (others => '0');
    else
      if(rising_edge(i_clk)) then
        case s_spi_req_nstate is
          when TEMP_DATA_AVAIL =>
            s_last_temp_data <= i_sh_temp_data;
          when others =>
            s_last_temp_data <= s_last_temp_data;
        end case;
      end if;
    end if;
  end process;
  o_last_temp_data <= s_last_temp_data;

  -- s_program_req control
  process(i_reset_n, s_spi_req_nstate) is
  begin
    if(i_reset_n = '0') then
      s_program_req <= '0';
    else
      case s_spi_req_nstate is
        when PROGRAM_REQ =>
          s_program_req <= '1';
        when others =>
          s_program_req <= '0';
      end case;
    end if;
  end process;
  o_program_req <= s_program_req when i_reprogram_n = '1' else '0';

  -- s_waiting_program control
  process(i_reset_n, i_reprogram_n, i_sys_pwr_n, i_program_rdy) is
  begin
    if(i_reset_n = '0') then
      s_waiting_program <= '0';
    else
      if(rising_edge(i_reprogram_n) or falling_edge(i_sys_pwr_n) or rising_edge(i_reset_n)) then
        s_waiting_program <= '1';
      elsif(i_program_rdy = '1') then
        s_waiting_program <= '0';
      end if;
    end if;
  end process;

  -- s_second_d1 control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_second_d1 <= (others => '0');
    else
      if(rising_edge(i_clk)) then
        s_second_d1 <= i_time_second;
      end if;
    end if;
  end process;

  -- s_temp_req control
  process(i_reset_n, s_spi_req_nstate) is
  begin
    if(i_reset_n = '0') then
      s_temp_req <= '0';
    else
      case s_spi_req_nstate is
        when TEMPERATURE_REQ => 
          s_temp_req <= '1';
        when others =>
          s_temp_req <= '0';
      end case;
    end if;
  end process;
  o_temp_req <= s_temp_req when i_reprogram_n = '1' else '0';

  -- s_spi_req_nstate control
  process(i_reset_n, s_spi_req_state, s_waiting_program, i_time_second, s_second_d1, i_reprogram_n, i_program_rdy, i_temp_rdy) is
  begin
    if(i_reset_n = '0') then
      s_spi_req_nstate <= IDLE;
    else
      case s_spi_req_state is
        when IDLE =>
          if(s_waiting_program = '1') then
            s_spi_req_nstate <= PROGRAM_REQ;
          elsif(((i_time_second = 6x"0") or (i_time_second = 6x"1E")) and (i_time_second /= s_second_d1) and (i_reprogram_n = '1')) then
            -- Checking against the delay register ensure request is only sent on the first clock cycle
            s_spi_req_nstate <= TEMPERATURE_REQ;
          end if;
        when PROGRAM_REQ =>
          s_spi_req_nstate <= PROG_DATA_AVAIL when i_program_rdy = '1' else PROGRAM_REQ;
        when PROG_DATA_AVAIL =>
          s_spi_req_nstate <= IDLE;
        when TEMPERATURE_REQ =>
          s_spi_req_nstate <= TEMP_DATA_AVAIL when i_temp_rdy = '1' else TEMPERATURE_REQ;
        WHEN TEMP_DATA_AVAIL =>
          s_spi_req_nstate <= IDLE;
      end case;
    end if;
  end process;

  -- s_spi_req_state control
  process(i_reset_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      s_spi_req_state <= IDLE;
    else
      if(rising_edge(i_clk)) then
        s_spi_req_state  <= s_spi_req_nstate;
      end if;
    end if;
  end process;
end architecture;
