-- tb_flash_model.vhd
-- Author: Samuel Sugimoto
-- Date:

-- Testbench for emulated Flash Module

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_unsigned.all;

use std.env.stop;
use std.textio.all;

library work;
use work.global_package.all;

entity tb_flash_model is
end entity tb_flash_model;

architecture tb_flash_model of tb_flash_model is
  -- UUT Signals
  signal s_sck    : std_logic;
  signal s_ce_n   : std_logic := '1';
  signal s_wp_n   : std_logic := '1';
  signal s_hold_n : std_logic := '1';
  signal s_si     : std_logic := '0';
  signal s_so     : std_logic;
  signal s_mem    : t_array_slv64(16383 downto 0) := (others => (others => '0'));

  -- Testbench Constraints/Signals
  constant c_read_cmd   : std_logic_vector(7 downto 0) := 8x"03";
  signal s_curr_xfer    : std_logic_vector(7 downto 0) := (others => '0');
  signal s_last_xfer    : std_logic_vector(7 downto 0) := (others => '0');
  file   fptr           : text;
  signal s_line_num     : integer range 0 to 16383 := 0;
  signal s_expt_data    : std_logic_vector(7 downto 0) := (others => '0');
  signal s_success      : std_logic := '1';

begin
  uut : entity work.flash_model
  port map (
    -- Normal SST25VG010A connections
    i_sck     => s_sck,
    i_ce_n    => s_ce_n,
    i_wp_n    => s_wp_n,
    i_hold_n  => s_hold_n,
    i_si      => s_si,
    o_so      => s_so,
    -- Additional I/O for simulation/model purposes
    i_mem     => s_mem
  );


  -- Generate SPI clock
  spi_clk : process
  begin
    s_sck <= '1';
    wait for 50 us;
    s_sck <= '0';
    wait for 50 us;
  end process;
  

  -- Test Process
  stim : process
    -- Variables for file read
    variable v_fstatus    : file_open_status;
    variable v_file_line  : line;
    variable v_line_num : integer range 0 to 16384 := 0;
    variable v_line_hex   : std_logic_vector(63 downto 0);

    -- Procedure to read word (1 Byte) from Flash Module
    procedure flash_read_word
      (
        p_i_addr      : in  std_logic_vector(23 downto 0);
        p_i_num_reads : in  integer
      ) is 
      variable v_curr_addr : integer range 0 to 131071;
    begin
      v_curr_addr := to_integer(unsigned(p_i_addr));
      wait until(rising_edge(s_sck));
      s_ce_n  <= '0';
      -- Send Read Command
      for i in 0 to 7 loop
        s_si  <= c_read_cmd(i);
        wait until(rising_edge(s_sck));
      end loop;
      -- Send Address
      for i in 0 to 23 loop
        s_si  <= p_i_addr(i);
        wait until(rising_edge(s_sck));
      end loop;
      s_si  <= '0';
      -- Read flash data
      for i in 0 to (p_i_num_reads - 1) loop
        -- Get expected data
        s_expt_data <= s_mem(v_curr_addr/8)((((v_curr_addr mod 8)*8)+7) downto ((v_curr_addr mod 8)*8));
        -- Read Word (Byte) Data
        for i in 0 to 7 loop
          wait until(rising_edge(s_sck));
          s_curr_xfer(i)  <= s_so;
        end loop;
        s_last_xfer <= s_so & s_curr_xfer(6 downto 0);
        -- Verify expected data = read data
        if((s_so & s_curr_xfer(6 downto 0)) /= s_expt_data) then
          report "Error: Data @ address " & integer'image(v_curr_addr) & ".  Expected 0x" & to_hstring(unsigned(s_expt_data)) & "; Received 0x" & to_hstring(unsigned(s_so & s_curr_xfer)) & ".";
          s_success <= '0';
        end if;
        v_curr_addr := 0 when v_curr_addr = 131071 else v_curr_addr + 1; 
      end loop;
      s_ce_n  <= '1';
    end procedure;

  begin
    -- Read flash test data from file
    v_line_num := 0;
    file_open(v_fstatus, fptr, "test_flash.dat", read_mode);
    while (not endfile(fptr)) loop
      readline(fptr, v_file_line);
      hread(v_file_line, v_line_hex);
      s_mem(v_line_num) <= v_line_hex;
      v_line_num := v_line_num + 1;
    end loop;
    file_close(fptr);
    
    -- Initialize UUT signals
    s_ce_n    <= '1';
    s_wp_n    <= '1';
    s_wp_n    <= '1';
    s_hold_n  <= '1';
    s_si      <= '0';
    s_success <= '1';
    -- Wait for 10 clock cycles before starting test
    for i in 0 to 9 loop
      wait until(rising_edge(s_sck));
    end loop;
    -- Perform test
    -- flash_read_word(24x"0", 2048);
    flash_read_word(24x"5", 16);
    wait until(rising_edge(s_sck));
    flash_read_word(24x"0", 24);
    wait until(rising_edge(s_sck));
    flash_read_word(24x"0", 48);
    wait until(rising_edge(s_sck));
    flash_read_word(24x"1FFFC", 16);
    wait for 500 us;
    if(s_success) then
      report "Test completed successfully!";
    else
      report "Test Failed, check console.";
    end if;
    stop;
  end process;
end architecture;
