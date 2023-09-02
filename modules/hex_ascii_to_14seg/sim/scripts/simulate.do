
# Start simulation
vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_data
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_ascii
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_dp_en
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_14seg
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/i
# Add UUT signals
add wave -expand -group "UUT" sim:/testbench/UUT/s_14seg_t

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
