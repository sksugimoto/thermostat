vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -expand -group "Testbench" -radix binary sim:/testbench/r_sys_clk
add wave -expand -group "Testbench" -radix binary sim:/testbench/r_data_request
add wave -expand -group "Testbench" -radix hex    sim:/testbench/w_data
add wave -expand -group "Testbench" -radix binary sim:/testbench/w_data_valid
add wave -expand -group "Testbench" -radix hex    sim:/testbench/r_coll_data
add wave -expand -group "Testbench" -radix hex    sim:/testbench/w_temperature_trunc
add wave -expand -group "Testbench" -radix binary sim:/testbench/w_spi_clk
add wave -expand -group "Testbench" -radix binary sim:/testbench/w_spi_cs_n
add wave -expand -group "Testbench" -radix binary sim:/testbench/w_spi_si
add wave -expand -group "Testbench" -radix binary sim:/testbench/w_spi_so
# Add UUT signals
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/i_clk
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/i_data_request
add wave -expand -group "UUT" -radix hex      sim:/testbench/sh_0/o_data
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/o_data_valid
add wave -expand -group "UUT"                 sim:/testbench/sh_0/s_sys_state
add wave -expand -group "UUT"                 sim:/testbench/sh_0/s_sys_nstate
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/i_spi_clk
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/o_spi_cs_n
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/o_spi_si
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/i_spi_so
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/s_spi_data_requested
add wave -expand -group "UUT" -radix binary   sim:/testbench/sh_0/s_spi_data_ready
add wave -expand -group "UUT"                 sim:/testbench/sh_0/s_spi_state
add wave -expand -group "UUT"                 sim:/testbench/sh_0/s_spi_nstate
add wave -expand -group "UUT" -radix unsigned sim:/testbench/sh_0/n_counter
add wave -expand -group "UUT" -radix unsigned sim:/testbench/sh_0/n_spi_clk_cnt

# Add Thermometer Model signals
add wave -expand -group "Thermometer Model" -radix hex  sim:/testbench/therm0/s_air_temperature
add wave -expand -group "Thermometer Model" -radix hex  sim:/testbench/therm0/s_temperature
add wave -expand -group "Thermometer Model" -radix hex  sim:/testbench/therm0/s_spi_temperature

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
