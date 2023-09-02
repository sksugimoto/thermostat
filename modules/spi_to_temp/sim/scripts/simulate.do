vsim -voptargs=+acc -t 1us work.testbench

# Add testbench signals
add wave -group "Testbench" -radix binary   sim:/testbench/r_use_f
add wave -group "Testbench" -radix hex      sim:/testbench/r_spi_data
add wave -group "Testbench" -radix hex      sim:/testbench/w_spi_data
add wave -group "Testbench" -radix ufixed   sim:/testbench/w_temp_data
add wave -group "Testbench" -radix unsigned sim:/testbench/w_temp_num
add wave -group "Testbench" -radix binary   sim:/testbench/w_temp_dec
add wave -group "Testbench" -radix unsigned sim:/testbench/i
add wave -group "Testbench" -radix unsigned sim:/testbench/j

# Add UUT signals
add wave -group "UUT" -radix hex  sim:/testbench/s2t/s_c_temp

# Run Test
run -all

wave zoom full
