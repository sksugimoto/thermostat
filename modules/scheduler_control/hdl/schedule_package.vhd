-- schedule_package.vhd
-- Author: Samuel Sugimoto
-- Date:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.global_package.all;

package schedule_package is
  -----------------------------------------
  --          ARRAY DEFINITIONS          --
  -----------------------------------------
  type t_array_integer  is array(natural range <>) of integer;
  type t_array_tset is array(natural range <>) of ufixed(6 downto -1);
  ------------------------------------------
  --          RECORD DEFINITIONS          --
  ------------------------------------------
  type t_schedule_instance is record
    valid       : std_logic;
    heat_on     : std_logic;
    cool_on     : std_logic;
    force_fan   : std_logic;
    recovery    : std_logic;
    trgt_c_ofst : integer;
    trgt_f_ofst : integer;
    intervals   : std_logic_vector(95 downto 0);
  end record t_schedule_instance;
  type t_array_sch_inst is array(natural range <>) of t_schedule_instance;

  type t_schedule_day is record
    valid         : std_logic;
    instance_ptrs : std_logic_vector(62 downto 0);  -- One hot reference to instances
  end record t_schedule_day;
  type t_array_sch_day is array (natural range <>) of t_schedule_day;

  type t_schedule_week is record
    valid     : std_logic;
    day_ptrs  : t_array_integer(6 downto 0);
  end record t_schedule_week;
  type t_array_sch_week is array (natural range <>) of t_schedule_week;

  type t_schedule_pattern is record
    valid     : std_logic;
    week_ptr  : integer;
  end record t_schedule_pattern;
  type t_array_sch_pattern is array(natural range <>) of t_schedule_pattern;

  type t_schedule is record
    pattern   : t_array_sch_pattern(51 downto 0);
    weeks     : t_array_sch_week(51 downto 0);
    days      : t_array_sch_day(63 downto 0);
    instances : t_array_sch_inst(62 downto 0);
  end record t_schedule;

  type t_interval_settings is record
    heat_on       : std_logic;
    cool_on       : std_logic;
    force_fan     : std_logic;
    recovery      : std_logic;
    -- temp_target_c : ufixed(6 downto -1);
    -- temp_target_f : ufixed(6 downto -1);
    trgt_c_ofst : integer;
    trgt_f_ofst : integer;
  end record t_interval_settings;
  type t_array_intervals is array(natural range <>) of t_interval_settings;

  type t_day_schedule is record
    valid     : std_logic_vector(95 downto 0);
    intervals : t_array_intervals(95 downto 0);
  end record t_day_schedule;
  type t_array_day_sch is array(natural range <>) of t_day_schedule;

  -------------------------------------------
  --         FUNCITON DECLARATIONS         --
  -------------------------------------------

  function slva_to_instance (
    i_slva_instance : in  t_array_slv64(1 downto 0)
  ) return t_schedule_instance;

  function slv_to_day (
    i_slv_day : in std_logic_vector(63 downto 0)
  ) return t_schedule_day;

  function slv_to_week (
    i_slv_week : in std_logic_vector(63 downto 0)
  ) return t_schedule_week;

  function slv_to_pattern (
    i_slv_pattern : in std_logic_vector(7 downto 0)
  ) return t_schedule_pattern;
  
  function slva_to_schedule (
    i_slva_schedule : in t_array_slv64(263 downto 0)
  ) return t_schedule;

  function interval_active (
    i_schedule  : in t_schedule;
    i_day       : in integer;
    i_instance  : in integer;
    i_interval  : in integer
  ) return boolean;

  function schedule_instance_to_interval (
    i_instance : in t_schedule_instance
  ) return t_interval_settings;

  ------------------------------------------
  --           RECORD CONSTANTS           --
  ------------------------------------------

  constant c_schedule_instance_empty : t_schedule_instance := (
    valid       => '0',
    heat_on     => '0',
    cool_on     => '0',
    force_fan   => '0',
    recovery    => '0',
    trgt_c_ofst => 0,
    trgt_f_ofst => 0,
    intervals   => (others => '0')
  );

  constant c_schedule_day_empty : t_schedule_day := (
    valid         => '0',
    instance_ptrs => (others => '0')
  );

  constant c_schedule_week_empty : t_schedule_week := (
    valid     => '0',
    day_ptrs  => (others => 0)
  );

  constant c_schedule_pattern_empty : t_schedule_pattern := (
    valid     => '0',
    week_ptr  => 0
  );
  
  constant c_schedule_empty : t_schedule := (
    pattern   => (others => c_schedule_pattern_empty),
    weeks     => (others => c_schedule_week_empty),
    days      => (others => c_schedule_day_empty),
    instances => (others => c_schedule_instance_empty)
  );

  constant c_day_interval_empty : t_interval_settings := (
    heat_on       => '0',
    cool_on       => '0',
    force_fan     => '0',
    recovery      => '0',
    -- temp_target_c => to_ufixed(0, 6, -1),
    -- temp_target_f => to_ufixed(0, 6, -1)
    trgt_c_ofst => 0,
    trgt_f_ofst => 0
  );

  constant c_day_schedule_empty : t_day_schedule := (
    valid     => (others => '0'),
    intervals => (others => c_day_interval_empty)
  );
end package;

package body schedule_package is
  ------------------------------------------
  --         FUNCTION DEFINITIONS         --
  ------------------------------------------
  -- Convert slv64 array to t_schedule_instance
  function slva_to_instance (
    i_slva_instance : in t_array_slv64(1 downto 0)
  ) return t_schedule_instance is
    variable v_instance : t_schedule_instance;
  begin
    v_instance.valid        := i_slva_instance(1)(63);
    v_instance.heat_on      := i_slva_instance(1)(51);
    v_instance.cool_on      := i_slva_instance(1)(50);
    v_instance.force_fan    := i_slva_instance(1)(49);
    v_instance.recovery     := i_slva_instance(1)(48);
    v_instance.trgt_c_ofst  := to_integer(unsigned(i_slva_instance(1)(45 downto 40)));
    v_instance.trgt_f_ofst  := to_integer(unsigned(i_slva_instance(1)(37 downto 32)));
    v_instance.intervals    := i_slva_instance(1)(31 downto 0) & i_slva_instance(0);
    return v_instance;
  end function;

  -- Convert slv to t_schedule_day
  function slv_to_day (
    i_slv_day : in std_logic_vector(63 downto 0)
  ) return t_schedule_day is
    variable v_day : t_schedule_day;
  begin
    v_day.valid         := i_slv_day(63);
    v_day.instance_ptrs := i_slv_day(62 downto 0);
    return v_day;
  end function;

  function slv_to_week (
    i_slv_week : in std_logic_vector(63 downto 0)
  ) return t_schedule_week is
    variable v_week : t_schedule_week;
  begin
    v_week.valid := i_slv_week(63);
    for i in 0 to 6 loop
      v_week.day_ptrs(i)  := to_integer(unsigned(i_slv_week(((i*8)+5) downto (i*8))));
    end loop;
    return v_week;
  end function;

  function slv_to_pattern (
    i_slv_pattern : in std_logic_vector(7 downto 0)
  ) return t_schedule_pattern is
    variable v_pattern : t_schedule_pattern;
  begin
    v_pattern.valid := i_slv_pattern(6);
    v_pattern.week_ptr := to_integer(unsigned(i_slv_pattern(5 downto 0)));
    return v_pattern;
  end function;

  function slva_to_schedule (
    i_slva_schedule : in t_array_slv64(263 downto 0)
  ) return t_schedule is
    variable v_slva_instances : t_array_slv64(125 downto 0);
    variable v_slva_days      : t_array_slv64(63 downto 0);
    variable v_slva_weeks     : t_array_slv64(51 downto 0);
    variable v_slva_pattern   : t_array_slv64(7 downto 0);
    variable v_schedule       : t_schedule;
  begin
    -- Segment 264 deep slv64 into component parts
    v_slva_instances  := i_slva_schedule(125 downto 0);
    v_slva_days       := i_slva_schedule(191 downto 128);
    v_slva_weeks      := i_slva_schedule(243 downto 192);
    v_slva_pattern    := i_slva_schedule(263 downto 256);
    -- Assign instances
    for i in 0 to 62 loop
      v_schedule.instances(i) := slva_to_instance(v_slva_instances(((2*i)+1) downto (2*i)));
    end loop;
    -- Assign days
    for i in 0 to 63 loop
      v_schedule.days(i) := slv_to_day(v_slva_days(i));
    end loop;
    -- Assign weeks
    for i in 0 to 51 loop
      v_schedule.weeks(i) := slv_to_week(v_slva_weeks(i));
    end loop;
    -- Assign pattern
    for i in 0 to 5 loop
      for j in 0 to 7 loop
        v_schedule.pattern((8*i)+j) := slv_to_pattern(v_slva_pattern(i)(((8*j)+7) downto (8*j)));
      end loop;
    end loop;
    for i in 0 to 3 loop
      v_schedule.pattern(i+48) := slv_to_pattern(v_slva_pattern(6)(((8*i)+7) downto (8*i)));
    end loop;
    return v_schedule;
  end function;

  function interval_active (
    i_schedule  : in t_schedule;
    i_day       : in integer;
    i_instance  : in integer;
    i_interval  : in integer
  ) return boolean is
    variable v_active : boolean;
  begin
    -- v_active := '1' when ((i_schedule.days(i_day).instance_ptrs(i_instance) = '1') and (i_schedule.instances(i_instance).valid = '1') and (i_schedule.instances(i_instance).intervals(i_interval) = '1')) else '0';
    v_active := (i_schedule.days(i_day).instance_ptrs(i_instance) = '1') and (i_schedule.instances(i_instance).valid = '1') and (i_schedule.instances(i_instance).intervals(i_interval) = '1');
    return v_active;
  end function;

  function schedule_instance_to_interval (
    i_instance : in t_schedule_instance
  ) return t_interval_settings is
    variable v_interval : t_interval_settings;
  begin
    v_interval.heat_on        := i_instance.heat_on;
    v_interval.cool_on        := i_instance.cool_on;
    v_interval.force_fan      := i_instance.force_fan;
    v_interval.recovery       := i_instance.recovery;
    -- v_interval.temp_target_c  := stc_offset_c_to_tempc(i_instance.trgt_c_ofst);
    -- v_interval.temp_target_f  := stc_offset_f_to_tempf(i_instance.trgt_f_ofst);
    v_interval.trgt_c_ofst  := i_instance.trgt_c_ofst;
    v_interval.trgt_f_ofst  := i_instance.trgt_f_ofst;
    return v_interval;
  end function;
end package body schedule_package;
