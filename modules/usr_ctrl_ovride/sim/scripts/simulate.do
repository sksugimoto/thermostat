
vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_clk
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_reset_n
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_prog_stc
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/r_temp[6:0]
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_use_f
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_sys_pwr_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_run_prog_n
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_heat_cool_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_t_down_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_t_up_n
add wave -expand -group "Testbench" -radix hex      sim:/testbench/w_man_stc

# Add UUT signals
add wave -expand -group "UUT" -radix hex      sim:/testbench/UUT/usr_control/i_temp
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/usr_control/s_temp[6:0]
add wave -expand -group "UUT"                 sim:/testbench/UUT/usr_control/s_stc
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/usr_control/s_stc_settled
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/usr_control/n_stc_settle_cntr
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/usr_control/n_f_offset
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/usr_control/n_c_offset
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/usr_control/s_stc_settled
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/usr_control/s_btn_hold
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/usr_control/n_btn_counter
add wave -expand -group "UUT"                 sim:/testbench/UUT/usr_control/s_manual_state
add wave -expand -group "UUT"                 sim:/testbench/UUT/usr_control/s_manual_nstate

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
