
vsim -voptargs=+acc -t 1us work.testbench
# Add UUT Wrapper signals
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/r_clk
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/r_reset_n
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/r_sys_pwr_n
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/r_run_prog_n
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/r_reprogram_n
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/r_sys_pwr_n
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/r_sys_pwr_n
add wave -expand -group "UUT Wrapper" -radix hex      sim:/testbench/UUT/s_program_data
add wave -expand -group "UUT Wrapper" -radix binary   sim:/testbench/UUT/o_program_error
add wave -expand -group "UUT Wrapper"                 sim:/testbench/UUT/s_prog_stc

# Add UUT signals
add wave -expand -group "UUT"                 sim:/testbench/UUT/sch_ctrl_0/s_schedule
add wave -expand -group "UUT"                 sim:/testbench/UUT/sch_ctrl_0/s_day_sch_array
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/sch_ctrl_0/n_week_counter
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/sch_ctrl_0/n_week_ptr
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/sch_ctrl_0/n_day_ptr
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/sch_ctrl_0/n_curr_interval

# Add Time Keeper signals
add wave -expand -group "Time" -childformat {{/testbench/time_keeper_0/time_keeper_0/o_day_time.day -radix binary} {/testbench/time_keeper_0/time_keeper_0/o_day_time.hour -radix unsigned} {/testbench/time_keeper_0/time_keeper_0/o_day_time.minute -radix unsigned} {/testbench/time_keeper_0/time_keeper_0/o_day_time.second -radix unsigned}} -expand -subitemconfig {/testbench/time_keeper_0/time_keeper_0/o_day_time.day {-radix binary} /testbench/time_keeper_0/time_keeper_0/o_day_time.hour {-radix unsigned} /testbench/time_keeper_0/time_keeper_0/o_day_time.minute {-radix unsigned} /testbench/time_keeper_0/time_keeper_0/o_day_time.second {-radix unsigned}} /testbench/time_keeper_0/time_keeper_0/o_day_time
add wave -expand -group "Time" -group "Control" -radix binary   sim:/testbench/r_set_time_n
add wave -expand -group "Time" -group "Control" -radix binary   sim:/testbench/r_incr_day_n
add wave -expand -group "Time" -group "Control" -radix binary   sim:/testbench/r_incr_hr_n
add wave -expand -group "Time" -group "Control" -radix binary   sim:/testbench/r_incr_min_n

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
