
vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -group "Testbench" -radix binary   sim:/testbench/r_spi_clk
add wave -group "Testbench" -radix binary   sim:/testbench/r_spi_cs_n
add wave -group "Testbench" -radix binary   sim:/testbench/r_spi_si
add wave -group "Testbench" -radix binary   sim:/testbench/w_spi_so
add wave -group "Testbench" -radix binary   sim:/testbench/r_heat
add wave -group "Testbench" -radix binary   sim:/testbench/r_cool
add wave -group "Testbench" -radix binary   sim:/testbench/r_amb_hc
add wave -group "Testbench" -radix hex      sim:/testbench/r_spi_in
add wave -group "Testbench" -radix hex      sim:/testbench/w_conv_temp
add wave -group "Testbench" -radix unsigned sim:/testbench/i
# Add UUT signals
add wave -group "UUT" -radix binary   sim:/therm0/i_spi_clk
add wave -group "UUT" -radix binary   sim:/therm0/i_spi_cs_n
add wave -group "UUT" -radix binary   sim:/therm0/i_spi_si
add wave -group "UUT" -radix binary   sim:/therm0/o_spi_so
add wave -group "UUT" -radix binary   sim:/therm0/i_heat
add wave -group "UUT" -radix binary   sim:/therm0/i_cool
add wave -group "UUT" -radix binary   sim:/therm0/i_amb_hc
add wave -group "UUT" -radix hex      sim:/therm0/s_air_temperature
add wave -group "UUT" -radix hex      sim:/therm0/s_temperature
add wave -group "UUT" -radix hex      sim:/therm0/s_spi_temperature
add wave -group "UUT" -radix unsigned sim:/therm0/n_counter
add wave -group "UUT"                 sim:/therm0/s_spi_state
add wave -group "UUT"                 sim:/therm0/s_spi_nstate

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
