-- display_controller.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.stc_package.all;
use work.time_package.all;
use work.global_package.all;
use work.display_14seg_package.all;

-- Controls the 14 segment displays
-- The following 14 segment displays are present
-- 0: time, minutes, 1's digit
-- 1: time, minutes, 10's digit
-- 2: time, hours, 1's digit
-- 3: time, hours, 10's digit

-- 4: amb temperature, unit (C/F)
-- 5: amb temperature, 1's digit when F, else tenth's digit (can only display 0 or 5 in C mode).
-- 6: amb temperature, 10's digit with F, else 1's digit.
-- 7: amb temperature, unused when F, else 10's digit.

-- 8:   messages, otherwise off
-- 9:   messages, otherwise off
-- 10:  messages, otherwise off
-- 11:  messages, otherwise off
-- 12:  messages, otherwise set temperature, unused when F, else unit(C)
-- 13:  messages, otherwise set temperature, unit(F) when F, else tenth's digit (can only display 0 or 5 in C mode).
-- 14:  messages, otherwise set temperature, 1's digit 
-- 15:  messages, otherwise set temperature, 10's digit.

entity display_controller is
port (
  i_reset_n       : in  std_logic;
  -- Date and Time control
  i_set_time_n    : in  std_logic;
  i_day_time      : in  t_day_time;
  -- Thermostat user controls
  i_use_f         : in  std_logic;
  i_sys_on_n      : in  std_logic;
  i_reprogram_n   : in  std_logic;
  i_prog_read     : in  std_logic;
  i_run_prog_n    : in  std_logic;
  -- Thermostat settings
  i_temperature   : in  ufixed(6 downto -2);
  i_prog_stc      : in  t_stc;
  i_man_stc       : in  t_stc;
  -- Display output
  o_14seg_cntrls  : out t_array_slv16(15 downto 0)
);
end entity display_controller;

architecture display_controller of display_controller is
  -------------------------------------------
  --               CONSTANTS               --
  -------------------------------------------
  -- When setting time, display "SET TIME"
  -- ASCII: 0x53|45|54|20|54|49|4D|45
  constant c_msg_set_time   : std_logic_vector(63 downto 0) := 64x"5345_5420_5449_4D45";
  -- When SPI is being reprogrammed, display "SPI OPEN"
  -- ASCII: 0x53|50|49|20|4F|50|45|4E
  constant c_msg_spi_prgm   : std_logic_vector(63 downto 0) := 64x"5350_4920_4F50_454E";
  -- When reading programming schedule from FLASH, display "RD PRGM"
  -- ASCII: 0x52|44|20|50|52|47|4D|20
  constant c_msg_rd_prgm    : std_logic_vector(63 downto 0) := 64x"5244_2050_5247_4D20";
  -- When system is off, display "OFF"
  -- ASCII: 0x4F|46|46|20|20|20|20|20
  constant c_msg_sys_off    : std_logic_vector(63 downto 0) := 64x"4F46_4620_2020_2020";
  -- When running program, but thermostat is not set during interval, display "IDLE"
  -- ASCII: 0x49|44|4C|45|20|20|20|20
  constant c_msg_prog_idle  : std_logic_vector(63 downto 0) := 64x"4944_4C45_2020_2020";

  -------------------------------------------
  --                SIGNALS                --
  -------------------------------------------
  signal s_14seg_cntrls     : t_array_slv16(15 downto 0) := (others => (others => '0'));
  signal s_t_unit           : std_logic_vector(6 downto 0);
  signal s_t_dp             : std_logic_vector(1 downto 0);
  signal s_time_minute_ones : std_logic_vector(6 downto 0):= (others => '0');
  signal s_time_minute_tens : std_logic_vector(6 downto 0):= (others => '0');
  signal s_time_hour_ones   : std_logic_vector(6 downto 0):= (others => '0');
  signal s_time_hour_tens   : std_logic_vector(6 downto 0):= (others => '0');
  signal s_atemp_trunc      : ufixed(6 downto 0);
  signal s_atemp_tenths     : std_logic_vector(6 downto 0);
  signal s_atemp_ones       : std_logic_vector(6 downto 0);
  signal s_atemp_tens       : std_logic_vector(6 downto 0);
  signal s_atemp_sgmts      : t_array_slv8(2 downto 0);
  signal s_atemp_ascii      : std_logic;
  signal s_msg_stemp_sgmts  : t_array_slv8(7 downto 0);
  signal s_stc_active       : t_stc;
  signal s_stc_offset_c     : std_logic_vector(5 downto 0);
  signal n_trgt_temp_f      : integer;
  signal n_trgt_temp_c      : integer;
  signal n_trgt_temp        : integer;
  signal s_msg_stemp_ascii  : std_logic;
  signal s_stemp_tenths     : std_logic_vector(6 downto 0);
  signal s_stemp_ones       : std_logic_vector(6 downto 0);
  signal s_stemp_tens       : std_logic_vector(6 downto 0);
begin
  s_t_unit  <= 7x"F" when i_use_f = '1' else 7x"C";
  s_t_dp(0) <= '0' when i_use_f = '1' else '1';
  s_t_dp(1) <= '0' when ((i_reprogram_n = '0') or (i_set_time_n = '0') or (i_prog_read = '1') or (i_sys_on_n = '1') or (i_use_f = '1') or
                         ((i_run_prog_n = '0') and ((s_stc_active.heat_on = '0') and (s_stc_active.cool_on = '0')))) else
               '1';
  -------------------------------------------
  --             TIME DISPLAYS             --
  -------------------------------------------
  -- 0: time, minutes, 1's digit
  -- 1: time, minutes, 10's digit
  -- 2: time, hours, 1's digit
  -- 3: time, hours, 10's digit
  -- Minutes
  s_time_minute_ones <= get_ones(i_day_time.minute);
  s_time_minute_tens <= get_tens(i_day_time.minute);
  seg_14_0 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_time_minute_ones,
    i_ascii   => '0',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(0)(14 downto 0)
  );
  seg_14_1 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_time_minute_tens,
    i_ascii   => '0',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(1)(14 downto 0)
  );
  -- Hours
  s_time_hour_ones <= get_ones(i_day_time.hour);
  s_time_hour_tens <= get_tens(i_day_time.hour);
  seg_14_2 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_time_hour_ones,
    i_ascii   => '0',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(2)(14 downto 0)
  );
  seg_14_3 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_time_hour_tens,
    i_ascii   => '0',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(3)(14 downto 0)
  );

  --------------------------------------------
  --      AMBIENT TEMPERATURE DISPLAYS      --
  --------------------------------------------
  -- 4: amb temperature, unit (C/F)
  -- 5: amb temperature, 1's digit when F, else tenth's digit (can only display 0 or 5 in C mode).
  -- 6: amb temperature, 10's digit with F, else 1's digit.
  -- 7: amb temperature, unused when F, else 10's digit.
  s_atemp_trunc <= resize(arg         => i_temperature, 
                          left_index  => s_atemp_trunc'high,
                          right_index => s_atemp_trunc'low,
                          round_style => ieee.fixed_float_types.fixed_truncate);
  s_atemp_tenths    <=  7x"5" when i_temperature(-1) = '1' else
                        7x"0" when i_temperature(-1) = '0' else
                        7x"E";
  s_atemp_ones      <= get_ones(to_integer(unsigned(s_atemp_trunc)));
  s_atemp_tens      <= get_tens(to_integer(unsigned(s_atemp_trunc)));
  s_atemp_sgmts(0)  <= ('0' & s_atemp_ones)   when i_use_f = '1' else ('0' & s_atemp_tenths);
  s_atemp_sgmts(1)  <= ('0' & s_atemp_tens)   when i_use_f = '1' else ('0' & s_atemp_ones);
  s_atemp_sgmts(2)  <= ('0' & c_ascii_space)  when i_use_f = '1' else ('0' & s_atemp_tens);
  s_atemp_ascii     <= '1' when i_use_f = '1' else '0';
  -- F Ones, C Tenths
  seg_14_4 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_t_unit,
    i_ascii   => '0',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(4)(14 downto 0)
  );
  -- F Ones, C Tenths
  seg_14_5 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_atemp_sgmts(0)(6 downto 0),
    i_ascii   => '0',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(5)(14 downto 0)
  );
  -- F Tens, C 1's (w/ DP)
  seg_14_6 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_atemp_sgmts(1)(6 downto 0),
    i_ascii   => '0',
    i_dp_en   => s_t_dp(0),
    o_14_seg  => s_14seg_cntrls(6)(14 downto 0)
  );
  -- F blank, C 10's
  seg_14_7 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_atemp_sgmts(2)(6 downto 0),
    i_ascii   => s_atemp_ascii,
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(7)(14 downto 0)
  );

  --------------------------------------------
  --  MESSAGE AND SET TEMPERATURE DISPLAYS  --
  --------------------------------------------
  -- 8:   messages, otherwise off
  -- 9:   messages, otherwise off
  -- 10:  messages, otherwise off
  -- 11:  messages, otherwise off
  -- 12:  messages, otherwise set temperature, unused when F, else unit(C)
  -- 13:  messages, otherwise set temperature, unit(F) when F, else tenth's digit (can only display 0 or 5 in C mode).
  -- 14:  messages, otherwise set temperature, 1's digit 
  -- 15:  messages, otherwise set temperature, 10's digit.
  -- First 4 segments only handle messages
  g_msg_stemp_sgmts : for i in 0 to 3 generate
    s_msg_stemp_sgmts(i) <= c_msg_spi_prgm(((i*8)+7) downto (i*8))  when i_reprogram_n = '0'  else
                            c_msg_set_time(((i*8)+7) downto (i*8))  when i_set_time_n = '0'   else
                            c_msg_rd_prgm(((i*8)+7) downto (i*8))   when i_prog_read = '1'    else
                            c_msg_sys_off(((i*8)+7) downto (i*8))   when i_sys_on_n = '1'     else
                            c_msg_prog_idle(((i*8)+7) downto (i*8)) when ((i_run_prog_n = '0') and ((i_prog_stc.heat_on = '0') and (i_prog_stc.cool_on = '0'))) else
                            ('0' & c_ascii_space);
  end generate;

  -- Last 4 segments
  s_stc_active    <= i_prog_stc when ((i_man_stc.heat_on = '0') and (i_man_stc.cool_on = '0')) else i_man_stc;
  s_stc_offset_c  <= std_logic_vector(to_unsigned(s_stc_active.trgt_c_ofst, 6));
  n_trgt_temp_f   <= 50 + s_stc_active.trgt_f_ofst;
  -- Truncated whole degree C, 0.5C intervals handled separately
  n_trgt_temp_c   <= 10 + to_integer(shift_right(to_unsigned(s_stc_active.trgt_c_ofst, 6), 1));
  n_trgt_temp     <= n_trgt_temp_f when i_use_f = '1' else n_trgt_temp_c;
  s_stemp_tenths  <= 7x"5" when s_stc_offset_c(0) = '1' else 7x"0";
  s_stemp_ones    <= get_ones(n_trgt_temp);
  s_stemp_tens    <= get_tens(n_trgt_temp);

  s_msg_stemp_sgmts(4) <= c_msg_spi_prgm(39 downto 32)  when i_reprogram_n = '0'  else
                          c_msg_set_time(39 downto 32)  when i_set_time_n = '0'   else
                          c_msg_rd_prgm(39 downto 32)   when i_prog_read = '1'    else
                          c_msg_sys_off(39 downto 32)   when i_sys_on_n = '1'     else
                          c_msg_prog_idle(39 downto 32) when ((i_run_prog_n = '0') and ((s_stc_active.heat_on = '0') and (s_stc_active.cool_on = '0'))) else
                          ('0' & c_ascii_space)         when i_use_f = '1'        else
                          8x"43";

  s_msg_stemp_sgmts(5) <= c_msg_spi_prgm(47 downto 40)  when i_reprogram_n = '0'  else
                          c_msg_set_time(47 downto 40)  when i_set_time_n = '0'   else
                          c_msg_rd_prgm(47 downto 40)   when i_prog_read = '1'    else
                          c_msg_sys_off(47 downto 40)   when i_sys_on_n = '1'     else
                          c_msg_prog_idle(47 downto 40) when ((i_run_prog_n = '0') and ((s_stc_active.heat_on = '0') and (s_stc_active.cool_on = '0'))) else
                          ('0' & s_t_unit)              when i_use_f = '1'        else
                          ('0' & s_stemp_tenths);

  s_msg_stemp_sgmts(6) <= c_msg_spi_prgm(55 downto 48)  when i_reprogram_n = '0'  else
                          c_msg_set_time(55 downto 48)  when i_set_time_n = '0'   else
                          c_msg_rd_prgm(55 downto 48)   when i_prog_read = '1'    else
                          c_msg_sys_off(55 downto 48)   when i_sys_on_n = '1'     else
                          c_msg_prog_idle(55 downto 48) when ((i_run_prog_n = '0') and ((s_stc_active.heat_on = '0') and (s_stc_active.cool_on = '0'))) else
                          ('0' & s_stemp_ones);

  s_msg_stemp_sgmts(7) <= c_msg_spi_prgm(63 downto 56)  when i_reprogram_n = '0'  else
                          c_msg_set_time(63 downto 56)  when i_set_time_n = '0'   else
                          c_msg_rd_prgm(63 downto 56)   when i_prog_read = '1'    else
                          c_msg_sys_off(63 downto 56)   when i_sys_on_n = '1'     else
                          c_msg_prog_idle(63 downto 56) when ((i_run_prog_n = '0') and ((s_stc_active.heat_on = '0') and (s_stc_active.cool_on = '0'))) else
                          ('0' & s_stemp_tens);
  

  s_msg_stemp_ascii <= '1' when ((i_reprogram_n = '0') or (i_set_time_n = '0') or (i_prog_read = '1') or (i_sys_on_n = '1')) else '0';
                        
  seg_14_8 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(0)(6 downto 0),
    i_ascii   => '1',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(8)(14 downto 0)
  );
  seg_14_9 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(1)(6 downto 0),
    i_ascii   => '1',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(9)(14 downto 0)
  );
  seg_14_10 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(2)(6 downto 0),
    i_ascii   => '1',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(10)(14 downto 0)
  );
  seg_14_11 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(3)(6 downto 0),
    i_ascii   => '1',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(11)(14 downto 0)
  );
  seg_14_12 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(4)(6 downto 0),
    i_ascii   => '1',
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(12)(14 downto 0)
  );
  seg_14_13 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(5)(6 downto 0),
    i_ascii   => s_msg_stemp_ascii,
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(13)(14 downto 0)
  );
  seg_14_14 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(6)(6 downto 0),
    i_ascii   => s_msg_stemp_ascii,
    i_dp_en   => s_t_dp(1),
    o_14_seg  => s_14seg_cntrls(14)(14 downto 0)
  );
  seg_14_15 : entity work.hex_ascii_to_14seg
  port map (
    i_data    => s_msg_stemp_sgmts(7)(6 downto 0),
    i_ascii   => s_msg_stemp_ascii,
    i_dp_en   => '0',
    o_14_seg  => s_14seg_cntrls(15)(14 downto 0)
  );

  -- Enable all segments when reset is asserted.
  g_14seg_outputs : for i in 0 to 15 generate
    o_14seg_cntrls(i) <= s_14seg_cntrls(i) when i_reset_n = '1' else ('0' & convert_14seg(c_14seg_dflt));
  end generate;

end architecture;
