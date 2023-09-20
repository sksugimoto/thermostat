
vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_clk
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_reset_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_set_time_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_incr_day_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_incr_hr_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_incr_min_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_day
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/w_hour
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/w_minute
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/w_second

# Add UUT signals
add wave -expand -group "UUT" -childformat {{/testbench/UUT/time_keeper_0/o_day_time.day -radix binary} {/testbench/UUT/time_keeper_0/o_day_time.hour -radix unsigned} {/testbench/UUT/time_keeper_0/o_day_time.minute -radix unsigned} {/testbench/UUT/time_keeper_0/o_day_time.second -radix unsigned}} -expand -subitemconfig {/testbench/UUT/time_keeper_0/o_day_time.day {-radix binary} /testbench/UUT/time_keeper_0/o_day_time.hour {-radix unsigned} /testbench/UUT/time_keeper_0/o_day_time.minute {-radix unsigned} /testbench/UUT/time_keeper_0/o_day_time.second {-radix unsigned}} /testbench/UUT/time_keeper_0/o_day_time
add wave -expand -group "UUT" -expand -group "Seconds" -radix unsigned  sim:/testbench/UUT/time_keeper_0/n_clk_counter
add wave -expand -group "UUT" -expand -group "Seconds" -radix unsigned  sim:/testbench/UUT/time_keeper_0/n_second
add wave -expand -group "UUT" -group "Minutes" -radix unsigned  sim:/testbench/UUT/time_keeper_0/n_min_cntr
add wave -expand -group "UUT" -group "Minutes" -radix binary    sim:/testbench/UUT/time_keeper_0/s_incr_min_hld
add wave -expand -group "UUT" -expand -group "Hours" -radix unsigned  sim:/testbench/UUT/time_keeper_0/n_hr_cntr
add wave -expand -group "UUT" -expand -group "Hours" -radix binary    sim:/testbench/UUT/time_keeper_0/s_incr_hr_hld

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
