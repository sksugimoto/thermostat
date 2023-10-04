-- scheduler_control.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.stc_package.all;
use work.time_package.all;
use work.global_package.all;
use work.schedule_package.all;

entity scheduler_control is
generic (
  g_clk_freq  : integer := 20000
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
  i_slv_prog      : in  t_array_slv64(263 downto 0);
  i_day_time      : in  t_day_time;
  
  -- STC to Controller
  o_program_error : out std_logic;
  o_program_stc   : out t_stc
);
end entity scheduler_control;

architecture scheduler_control of scheduler_control is
  -------------------------------------------
  --                SIGNALS                --
  -------------------------------------------
  signal s_schedule   : t_schedule  := c_schedule_empty;
  signal s_prog_err   : std_logic   := '0';
  -- 
  -- signal s_sch_days_valid : std_logic_vector(63 downto 0);
  signal s_day_sch_array  : t_array_day_sch(63 downto 0) := (others => c_day_schedule_empty);
  signal s_active_stc     : t_stc := c_stc_idle;
  signal n_week_counter   : integer range 0 to 51 := 0;
  signal n_week_ptr       : integer range 0 to 51 := 0;
  signal n_day            : integer range 0 to 6  := 0;
  signal n_day_ptr        : integer range 0 to 63 := 0;
  signal n_curr_interval  : integer range 0 to 95 := 0;

begin
  -- Convert schedule from slv64 to schedule record.
  s_schedule <= slva_to_schedule(i_slv_prog);
  
  -- Convert t_schedule_day into t_day_schedule
  -- if day points to instance and instance is active during interval, store data in day_schedule interval.
  -- Instance 0 has highest priority, while 62 has lowest priority and is overwritten in even of doubles.
  
  process(i_reset_n, s_schedule) is
  begin
    if(i_reset_n = '0') then
      for i in 0 to 63 loop
        s_day_sch_array(i) <= c_day_schedule_empty;
      end loop;
    else
      -- -- If day 0 points to instance 0, and instance 0 is valid, and instance 0 is active for interval 0,
      -- -- then set day-interval 0's settings to instance 0's settings
      -- if((s_schedule.days(0).instance_ptrs(0) = '1') and (s_schedule.instances(0).valid = '1') and (s_schedule.instances(0).intervals(0) = '1')) then
      --   s_day_sch_array(0).intervals(0).heat_on        <= s_schedule.instances(0).heat_on;
      --   s_day_sch_array(0).intervals(0).cool_on        <= s_schedule.instances(0).cool_on;
      --   s_day_sch_array(0).intervals(0).force_fan      <= s_schedule.instances(0).force_fan;
      --   s_day_sch_array(0).intervals(0).recovery       <= s_schedule.instances(0).recovery;
      --   s_day_sch_array(0).intervals(0).temp_target_c  <= stc_offset_c_to_tempc(s_schedule.instance(0).trgt_c_ofst);
      --   s_day_sch_array(0).intervals(0).temp_target_f  <= stf_offset_f_to_tempf(s_schedule.instance(0).trgt_f_ofst);
      -- -- If day 0 points to instance 0, and instance 0 is valid, and instance 0 is active for interval 0,
      -- -- then set day-interval 0's settings to instance 0's settings
      -- if(interval_active(i_schedule, i_day => 0, i_interval => 0, i_instance => 0)) then
      --   s_day_sch_array(0).intervals(0)  <= schedule_instance_to_interval(s_schedule.instances(0));
      -- -- If day 0 points to instance 1, and instance 1 is valid, and instance 1 is active for interval 0,
      -- -- then set day-interval 0's settings to instance 1's settings
      -- -- elsif((s_schedule.days(0).instance_ptrs(1) = '1') and (s_schedule.instances(1).valid = '1') and (s_schedule.instances(1).intervals(0) = '1')) then
      -- elsif(interval_active(i_schedule, i_day => 0, i_interval => 0, i_instance => 1)) then
      --   s_day_sch_array(0).intervals(0) <= schedule_instance_to_interval(s_schedule.instances(1));
      --   -- s_day_sch_array(0).intervals(0).heat_on        <= s_schedule.instances(1).heat_on;
      --   -- s_day_sch_array(0).intervals(0).cool_on        <= s_schedule.instances(1).cool_on;
      --   -- s_day_sch_array(0).intervals(0).force_fan      <= s_schedule.instances(1).force_fan;
      --   -- s_day_sch_array(0).intervals(0).recovery       <= s_schedule.instances(1).recovery;
      --   -- s_day_sch_array(0).intervals(0).temp_target_c  <= stc_offset_c_to_tempc(s_schedule.instance(1).trgt_c_ofst);
      --   -- s_day_sch_array(0).intervals(0).temp_target_f  <= stf_offset_f_to_tempf(s_schedule.instance(1).trgt_f_ofst);
      -- elsif(interval_active(i_schedule, i_day => 0, i_interval => 0, i_instance => 2)) then
      --   s_day_sch_array(0).intervals(0) <= schedule_instance_to_interval(s_schedule.instances(2));
      --   -- s_day_sch_array(0).intervals(0).heat_on        <= s_schedule.instances(2).heat_on;
      --   -- s_day_sch_array(0).intervals(0).cool_on        <= s_schedule.instances(2).cool_on;
      --   -- s_day_sch_array(0).intervals(0).force_fan      <= s_schedule.instances(2).force_fan;
      --   -- s_day_sch_array(0).intervals(0).recovery       <= s_schedule.instances(2).recovery;
      --   -- s_day_sch_array(0).intervals(0).temp_target_c  <= stc_offset_c_to_tempc(s_schedule.instance(2).trgt_c_ofst);
      --   -- s_day_sch_array(0).intervals(0).temp_target_f  <= stf_offset_f_to_tempf(s_schedule.instance(2).trgt_f_ofst);
      -- elsif(interval_active(i_schedule, i_day => 0, i_interval => 0, i_instance => 3)) then
      --   s_day_sch_array(0).intervals(0) <= schedule_instance_to_interval(s_schedule.instances(3));
      --   -- s_day_sch_array(0).heat_on(0)        <= s_schedule.instances(3).heat_on;
      --   -- s_day_sch_array(0).cool_on(0)        <= s_schedule.instances(3).cool_on;
      --   -- s_day_sch_array(0).force_fan(0)      <= s_schedule.instances(3).force_fan;
      --   -- s_day_sch_array(0).recovery(0)       <= s_schedule.instances(3).recovery;
      --   -- s_day_sch_array(0).temp_target_c(0)  <= resize(to_ufixed(s_schedule.instances(3).trgt_c_ofst, 5, 0) * to_ufixed(0.5, 0, -1) + to_ufixed(10, 3, 0), 6, -1);
      --   -- s_day_sch_array(0).temp_target_f(0)  <= to_ufixed(s_schedule.instances(3).trgt_f_ofst + 50, 6, -1);
      -- 
      -- else
      --   s_day_sch_array(0) <= c_day_schedule_empty;
      -- end if;

      -- Convert schedule w/days with instance references to daily schedules.
      for i in 0 to 63 loop
        if(s_schedule.days(i).valid = '1') then
          for j in 0 to 95 loop
            s_day_sch_array(i).valid(j) <=  s_schedule.instances(0).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 0) else
                                            s_schedule.instances(1).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 1) else
                                            s_schedule.instances(2).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 2) else
                                            s_schedule.instances(3).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 3) else
                                            s_schedule.instances(4).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 4) else
                                            s_schedule.instances(5).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 5) else
                                            s_schedule.instances(6).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 6) else
                                            s_schedule.instances(7).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 7) else
                                            s_schedule.instances(8).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 8) else
                                            s_schedule.instances(9).valid  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 9) else
                                            s_schedule.instances(10).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 10) else
                                            s_schedule.instances(11).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 11) else
                                            s_schedule.instances(12).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 12) else
                                            s_schedule.instances(13).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 13) else
                                            s_schedule.instances(14).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 14) else
                                            s_schedule.instances(15).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 15) else
                                            s_schedule.instances(16).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 16) else
                                            s_schedule.instances(17).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 17) else
                                            s_schedule.instances(18).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 18) else
                                            s_schedule.instances(19).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 19) else
                                            s_schedule.instances(20).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 20) else
                                            s_schedule.instances(21).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 21) else
                                            s_schedule.instances(22).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 22) else
                                            s_schedule.instances(23).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 23) else
                                            s_schedule.instances(24).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 24) else
                                            s_schedule.instances(25).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 25) else
                                            s_schedule.instances(26).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 26) else
                                            s_schedule.instances(27).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 27) else
                                            s_schedule.instances(28).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 28) else
                                            s_schedule.instances(29).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 29) else
                                            s_schedule.instances(30).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 30) else
                                            s_schedule.instances(31).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 31) else
                                            s_schedule.instances(32).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 32) else
                                            s_schedule.instances(33).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 33) else
                                            s_schedule.instances(34).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 34) else
                                            s_schedule.instances(35).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 35) else
                                            s_schedule.instances(36).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 36) else
                                            s_schedule.instances(37).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 37) else
                                            s_schedule.instances(38).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 38) else
                                            s_schedule.instances(39).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 39) else
                                            s_schedule.instances(40).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 40) else
                                            s_schedule.instances(41).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 41) else
                                            s_schedule.instances(42).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 42) else
                                            s_schedule.instances(43).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 43) else
                                            s_schedule.instances(44).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 44) else
                                            s_schedule.instances(45).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 45) else
                                            s_schedule.instances(46).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 46) else
                                            s_schedule.instances(47).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 47) else
                                            s_schedule.instances(48).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 48) else
                                            s_schedule.instances(49).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 49) else
                                            s_schedule.instances(50).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 50) else
                                            s_schedule.instances(51).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 51) else
                                            s_schedule.instances(52).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 52) else
                                            s_schedule.instances(53).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 53) else
                                            s_schedule.instances(54).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 54) else
                                            s_schedule.instances(55).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 55) else
                                            s_schedule.instances(56).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 56) else
                                            s_schedule.instances(57).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 57) else
                                            s_schedule.instances(58).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 58) else
                                            s_schedule.instances(59).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 59) else
                                            s_schedule.instances(60).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 60) else
                                            s_schedule.instances(61).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 61) else
                                            s_schedule.instances(62).valid when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 62) else
                                            '0';
            s_day_sch_array(i).intervals(j) <=  schedule_instance_to_interval(s_schedule.instances(0))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 0) else
                                                schedule_instance_to_interval(s_schedule.instances(1))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 1) else
                                                schedule_instance_to_interval(s_schedule.instances(2))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 2) else
                                                schedule_instance_to_interval(s_schedule.instances(3))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 3) else
                                                schedule_instance_to_interval(s_schedule.instances(4))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 4) else
                                                schedule_instance_to_interval(s_schedule.instances(5))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 5) else
                                                schedule_instance_to_interval(s_schedule.instances(6))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 6) else
                                                schedule_instance_to_interval(s_schedule.instances(7))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 7) else
                                                schedule_instance_to_interval(s_schedule.instances(8))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 8) else
                                                schedule_instance_to_interval(s_schedule.instances(9))  when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 9) else
                                                schedule_instance_to_interval(s_schedule.instances(10)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 10) else
                                                schedule_instance_to_interval(s_schedule.instances(11)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 11) else
                                                schedule_instance_to_interval(s_schedule.instances(12)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 12) else
                                                schedule_instance_to_interval(s_schedule.instances(13)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 13) else
                                                schedule_instance_to_interval(s_schedule.instances(14)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 14) else
                                                schedule_instance_to_interval(s_schedule.instances(15)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 15) else
                                                schedule_instance_to_interval(s_schedule.instances(16)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 16) else
                                                schedule_instance_to_interval(s_schedule.instances(17)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 17) else
                                                schedule_instance_to_interval(s_schedule.instances(18)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 18) else
                                                schedule_instance_to_interval(s_schedule.instances(19)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 19) else
                                                schedule_instance_to_interval(s_schedule.instances(20)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 20) else
                                                schedule_instance_to_interval(s_schedule.instances(21)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 21) else
                                                schedule_instance_to_interval(s_schedule.instances(22)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 22) else
                                                schedule_instance_to_interval(s_schedule.instances(23)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 23) else
                                                schedule_instance_to_interval(s_schedule.instances(24)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 24) else
                                                schedule_instance_to_interval(s_schedule.instances(25)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 25) else
                                                schedule_instance_to_interval(s_schedule.instances(26)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 26) else
                                                schedule_instance_to_interval(s_schedule.instances(27)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 27) else
                                                schedule_instance_to_interval(s_schedule.instances(28)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 28) else
                                                schedule_instance_to_interval(s_schedule.instances(29)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 29) else
                                                schedule_instance_to_interval(s_schedule.instances(30)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 30) else
                                                schedule_instance_to_interval(s_schedule.instances(31)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 31) else
                                                schedule_instance_to_interval(s_schedule.instances(32)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 32) else
                                                schedule_instance_to_interval(s_schedule.instances(33)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 33) else
                                                schedule_instance_to_interval(s_schedule.instances(34)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 34) else
                                                schedule_instance_to_interval(s_schedule.instances(35)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 35) else
                                                schedule_instance_to_interval(s_schedule.instances(36)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 36) else
                                                schedule_instance_to_interval(s_schedule.instances(37)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 37) else
                                                schedule_instance_to_interval(s_schedule.instances(38)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 38) else
                                                schedule_instance_to_interval(s_schedule.instances(39)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 39) else
                                                schedule_instance_to_interval(s_schedule.instances(40)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 40) else
                                                schedule_instance_to_interval(s_schedule.instances(41)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 41) else
                                                schedule_instance_to_interval(s_schedule.instances(42)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 42) else
                                                schedule_instance_to_interval(s_schedule.instances(43)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 43) else
                                                schedule_instance_to_interval(s_schedule.instances(44)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 44) else
                                                schedule_instance_to_interval(s_schedule.instances(45)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 45) else
                                                schedule_instance_to_interval(s_schedule.instances(46)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 46) else
                                                schedule_instance_to_interval(s_schedule.instances(47)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 47) else
                                                schedule_instance_to_interval(s_schedule.instances(48)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 48) else
                                                schedule_instance_to_interval(s_schedule.instances(49)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 49) else
                                                schedule_instance_to_interval(s_schedule.instances(50)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 50) else
                                                schedule_instance_to_interval(s_schedule.instances(51)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 51) else
                                                schedule_instance_to_interval(s_schedule.instances(52)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 52) else
                                                schedule_instance_to_interval(s_schedule.instances(53)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 53) else
                                                schedule_instance_to_interval(s_schedule.instances(54)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 54) else
                                                schedule_instance_to_interval(s_schedule.instances(55)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 55) else
                                                schedule_instance_to_interval(s_schedule.instances(56)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 56) else
                                                schedule_instance_to_interval(s_schedule.instances(57)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 57) else
                                                schedule_instance_to_interval(s_schedule.instances(58)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 58) else
                                                schedule_instance_to_interval(s_schedule.instances(59)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 59) else
                                                schedule_instance_to_interval(s_schedule.instances(60)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 60) else
                                                schedule_instance_to_interval(s_schedule.instances(61)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 61) else
                                                schedule_instance_to_interval(s_schedule.instances(62)) when interval_active(s_schedule, i_day => i, i_interval => j, i_instance => 62) else
                                                c_day_interval_empty;
          end loop;
        else -- Day in not valid, set day to empty
          s_day_sch_array(i) <= c_day_schedule_empty;
        end if;
      end loop;
    end if;
  end process;

  -- n_week_counter control
  process(i_reset_n, i_incr_week_n, i_clk) is
  begin
    if(i_reset_n = '0') then
      n_week_counter <= 0;
    elsif(falling_edge(i_incr_week_n)) then
      if(n_week_counter = 51) then
        n_week_counter <= 0;
      else
        n_week_counter <= n_week_counter + 1 when (s_schedule.pattern(n_week_counter + 1).valid = '1') else 0;
      end if;
    else
      if(rising_edge(i_clk)) then
        if((i_day_time.day = 7x"40") and (i_day_time.hour = 23) and (i_day_time.minute = 59) and (i_day_time.second = 59) and (i_day_time.fsecond = (g_clk_freq - 1))) then
          if(n_week_counter = 51) then
            n_week_counter <= 0;
          else
            n_week_counter <= n_week_counter + 1 when (s_schedule.pattern(n_week_counter + 1).valid = '1') else 0;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- n_week_ptr control
  process(i_reset_n, s_schedule, n_week_counter) is
  begin
    if(i_reset_n = '0') then
      n_week_ptr <= 0;
    else
      if(s_schedule.pattern(n_week_counter).valid = '1') then
        n_week_ptr <= s_schedule.pattern(n_week_counter).week_ptr;
      else
        n_week_ptr <= 0;
      end if;
    end if;
  end process;

  -- n_day control
  process(i_reset_n, i_day_time.day) is
  begin
    if(i_reset_n = '0') then
      n_day <= 0;
    else
      case i_day_time.day is
        when 7x"1" =>
          n_day <= 0;
        when 7x"2" =>
          n_day <= 1;
        when 7x"4" =>
          n_day <= 2;
        when 7x"8" =>
          n_day <= 3;
        when 7x"10" =>
          n_day <= 4;
        when 7x"20" =>
          n_day <= 5;
        when 7x"40" =>
          n_day <= 6;
        when others =>
          n_day <= 0;
      end case;
    end if;
  end process;

  -- n_day_ptr control
  process(i_reset_n, s_schedule, n_week_ptr, n_day) is
  begin
    if(i_reset_n = '0') then
      n_day_ptr <= 0;
    else
      if(s_schedule.weeks(n_week_ptr).valid = '1') then
        n_day_ptr <= s_schedule.weeks(n_week_ptr).day_ptrs(n_day);
      else
        n_day_ptr <= 0;
      end if;
    end if;
  end process;

  -- n_curr_interval control
  process(i_reset_n, i_set_time_n, i_clk) begin
    if(i_reset_n = '0') then
      n_curr_interval <= 0;
    elsif(rising_edge(i_set_time_n)) then
      n_curr_interval <=  (i_day_time.hour * 4) + 3 when ((i_day_time.minute >= 45) and (i_day_time.minute <= 59)) else
                          (i_day_time.hour * 4) + 2 when ((i_day_time.minute >= 30) and (i_day_time.minute < 45)) else
                          (i_day_time.hour * 4) + 1 when ((i_day_time.minute >= 15) and (i_day_time.minute < 30)) else
                          (i_day_time.hour * 4);
    else
      if(rising_edge(i_clk)) then
        if((i_day_time.second = 59) and (i_day_time.fsecond = g_clk_freq - 1))then
          if((i_day_time.hour = 23) and (i_day_time.minute = 59)) then
            n_curr_interval <= 0;
          elsif((i_day_time.minute = 14) or (i_day_time.minute = 29) or (i_day_time.minute = 44) or (i_day_time.minute = 59)) then
            n_curr_interval <= n_curr_interval + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- s_prog_err control
  process(i_reset_n, s_schedule, n_week_counter, n_week_ptr, n_day_ptr) is
  begin
    if(i_reset_n = '0') then
      s_prog_err <= '1';
    else
      if( (s_schedule.pattern(0).valid = '1') and
          (s_schedule.pattern(n_week_counter).valid = '1') and
          (s_schedule.weeks(n_week_ptr).valid = '1') and
          (s_schedule.days(n_day_ptr).valid = '1'))
      then
        s_prog_err <= '0';
      else
        s_prog_err <= '1';
      end if;
    end if;
  end process;
  o_program_error <= s_prog_err;
  
  -- prog_stc control
  process(i_reset_n, i_sys_pwr_n, i_run_prog_n, i_set_time_n, i_reprogram_n, s_schedule, s_day_sch_array, n_week_counter, n_day_ptr, n_curr_interval) is
  begin
    if(i_reset_n = '0') then
      s_active_stc <= c_stc_idle;
    else
      if( (i_sys_pwr_n = '0') and
          (i_run_prog_n = '0') and
          (i_set_time_n = '1') and
          (i_reprogram_n = '1') and
          (s_schedule.pattern(n_week_counter).valid = '1') and
          (s_schedule.weeks(s_schedule.pattern(n_week_counter).week_ptr).valid = '1') and
          (s_day_sch_array(n_day_ptr).valid(n_curr_interval) = '1'))
      then 
        s_active_stc.heat_on      <= s_day_sch_array(n_day_ptr).intervals(n_curr_interval).heat_on;
        s_active_stc.cool_on      <= s_day_sch_array(n_day_ptr).intervals(n_curr_interval).cool_on;
        s_active_stc.force_fan    <= s_day_sch_array(n_day_ptr).intervals(n_curr_interval).force_fan;
        s_active_stc.trgt_c_ofst  <= s_day_sch_array(n_day_ptr).intervals(n_curr_interval).trgt_c_ofst;
        s_active_stc.trgt_f_ofst  <= s_day_sch_array(n_day_ptr).intervals(n_curr_interval).trgt_f_ofst;
      else
        s_active_stc <= c_stc_idle;
      end if;
    end if;
  end process;
  o_program_stc <= s_active_stc;

end architecture;
