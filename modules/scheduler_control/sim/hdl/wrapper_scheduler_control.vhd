-- wrapper_scheduler_controler.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.stc_package.all;
use work.time_package.all;
use work.global_package.all;
use work.schedule_package.all;

entity wrapper_scheduler_control is
generic (
  g_clk_freq : integer := 20000
);
port (
  -- Clock and Reset
  i_clk           : in  std_logic;
  i_reset_n       : in  std_logic;
  -- Scheduler Controller
  i_sys_pwr_n     : in  std_logic;
  i_run_prog_n    : in  std_logic;
  i_reprogram_n   : in  std_logic;
  i_set_time_n    : in  std_logic;
  i_incr_week_n   : in  std_logic;
  i_slv_prog      : in  std_logic_vector(16895 downto 0);
  i_day           : in  std_logic_vector(6 downto 0);
  i_hour          : in  std_logic_vector(4 downto 0);
  i_minute        : in  std_logic_vector(5 downto 0);
  i_second        : in  std_logic_vector(5 downto 0);
  i_fsecond       : in  std_logic_vector(14 downto 0);
  -- STC to Controller
  o_program_error : out std_logic;
  o_program_stc   : out std_logic_vector(31 downto 0)
);
end entity wrapper_scheduler_control;

architecture wrapper_scheduler_control of wrapper_scheduler_control is
  signal s_program_data : t_array_slv64(263 downto 0) := (others => (others => '0'));
  signal s_day_time     : t_day_time := c_day_time_zero;
  signal s_prog_stc     : t_stc := c_stc_idle;
begin
  sch_ctrl_0 : entity work.scheduler_control
  generic map (
    g_clk_freq  => g_clk_freq
  )
  port map (
    -- Clock and Reset
    i_clk           => i_clk,
    i_reset_n       => i_reset_n,
    -- Scheduler Controller
    i_sys_pwr_n     => i_sys_pwr_n,
    i_run_prog_n    => i_run_prog_n,
    i_reprogram_n   => i_reprogram_n,
    i_set_time_n    => i_set_time_n,
    i_incr_week_n   => i_incr_week_n,
    i_slv_prog      => s_program_data,
    i_day_time      => s_day_time,

    -- STC to Controller
    o_program_error => o_program_error,
    o_program_stc   => s_prog_stc
  );

  -- Convert programming data from slv to t_array_slv64
  gen_o_program_data : for i in 0 to 263 generate
    s_program_data(i) <= i_slv_prog((i*64+63) downto (i*64)) ;
  end generate;

  -- Convert slvs to day_time record
  s_day_time <= constr_daytime( i_slv_day   => i_day,
                                i_n_hour    => to_integer(unsigned(i_hour)),
                                i_n_minute  => to_integer(unsigned(i_minute)),
                                i_n_second  => to_integer(unsigned(i_second)),
                                i_n_fsecond => to_integer(unsigned(i_fsecond)));

  -- Convert stc to slv
  o_program_stc <= stc_to_slv(s_prog_stc);
end architecture;
