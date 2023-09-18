
vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_spi_clk
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_spi_cs_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_spi_si
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_spi_so
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_heat
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_cool
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_amb_hc
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_spi_in
add wave -expand -group "Testbench" -radix hex      sim:/testbench/w_conv_temp
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/i
# Add UUT signals
add wave -expand -group "UUT" -radix binary   sim:/therm0/i_spi_clk
add wave -expand -group "UUT" -radix binary   sim:/therm0/i_spi_cs_n
add wave -expand -group "UUT" -radix binary   sim:/therm0/i_spi_si
add wave -expand -group "UUT" -radix binary   sim:/therm0/o_spi_so
add wave -expand -group "UUT" -radix binary   sim:/therm0/i_heat
add wave -expand -group "UUT" -radix binary   sim:/therm0/i_cool
add wave -expand -group "UUT" -radix binary   sim:/therm0/i_amb_hc
add wave -expand -group "UUT" -radix hex      sim:/therm0/s_air_temperature
add wave -expand -group "UUT" -radix unsigned sim:/therm0/s_air_temp_clk_cntr
add wave -expand -group "UUT" -radix hex      sim:/therm0/s_temperature
add wave -expand -group "UUT" -radix unsigned sim:/therm0/s_temp_clk_cntr
add wave -expand -group "UUT" -radix hex      sim:/therm0/s_spi_temperature
add wave -expand -group "UUT" -radix unsigned sim:/therm0/n_counter
add wave -expand -group "UUT"                 sim:/therm0/s_spi_state
add wave -expand -group "UUT"                 sim:/therm0/s_spi_nstate

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
