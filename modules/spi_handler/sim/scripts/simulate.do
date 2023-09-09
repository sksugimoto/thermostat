
# Execute perl script to generate flash data
eval perl ../../../sim_flash_model/sim/scripts/gen_flash.pl

vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_clk
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_reset_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_read_program
add wave -expand -group "Testbench" -radix hex      sim:/testbench/w_program_data
add wave -expand -group "Testbench" -group "w_program_array" -radix hex sim:/testbench/w_program_array(263)
for {set i 0} {$i < 4} {incr i} {
  add wave -expand -group "Testbench" -group "w_program_array" -radix hex sim:/testbench/w_program_array([expr {3-$i}])
}
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_program_ready
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_read_therm
add wave -expand -group "Testbench" -radix hex      sim:/testbench/w_temperature
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_temperature
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_therm_ready
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_spi_disconnect

# Add UUT signals
add wave -expand -group "UUT" sim:/testbench/UUT/spi_handler_0/s_handler_state
add wave -expand -group "UUT" sim:/testbench/UUT/spi_handler_0/s_handler_nstate

# Add Flash Model Signals
add wave -expand -group "Flash Model"                 sim:/testbench/flash_0/flash_model/s_spi_mem_state
add wave -expand -group "Flash Model"                 sim:/testbench/flash_0/flash_model/s_spi_mem_nstate
add wave -expand -group "Flash Model" -radix unsigned sim:/testbench/flash_0/flash_model/n_cmd_clk_counter
add wave -expand -group "Flash Model" -radix unsigned sim:/testbench/flash_0/flash_model/n_cmd_counter
add wave -expand -group "Flash Model" -radix unsigned sim:/testbench/flash_0/flash_model/n_addr_counter
add wave -expand -group "Flash Model" -radix unsigned sim:/testbench/flash_0/flash_model/n_read_counter

# Add Thermometer Model signals
add wave -expand -group "Therm Model"                 sim:/testbench/therm_0/s_spi_state
add wave -expand -group "Therm Model"                 sim:/testbench/therm_0/s_spi_nstate
add wave -expand -group "Therm Model" -radix unsigned sim:/testbench/therm_0/n_counter
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm_0/s_air_temperature
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm_0/s_temperature
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm_0/s_spi_temperature

# Add SPI inter-module SPI signals
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_clk
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_cs_n
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_cs_n_pullup
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_si
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_so

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
