
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

# Add UUT signals
add wave -expand -group "UUT" -expand -group "Seconds" -radix unsigned  sim:/testbench/UUT/n_clk_counter
add wave -expand -group "UUT" -expand -group "Seconds" -radix unsigned  sim:/testbench/UUT/n_second
add wave -expand -group "UUT" -group "Minutes" -radix unsigned  sim:/testbench/UUT/n_min_cntr
add wave -expand -group "UUT" -group "Minutes" -radix binary    sim:/testbench/UUT/s_incr_min_hld
add wave -expand -group "UUT" -expand -group "Hours" -radix unsigned  sim:/testbench/UUT/n_hr_cntr
add wave -expand -group "UUT" -expand -group "Hours" -radix binary    sim:/testbench/UUT/s_incr_hr_hld

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
