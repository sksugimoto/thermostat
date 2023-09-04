
# Execute perl script to generate flash data
eval perl ../../../sim_flash_model/sim/scripts/gen_flash.pl

vsim -voptargs=+acc -t 1us work.testbench
# Add testbench signals
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_sys_clk
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_reset_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_data_request
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_read_addr
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/r_read_num
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_data_ready
add wave -expand -group "Testbench" -radix hex      sim:/testbench/req_flash_data/ti_flash_addr
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/req_flash_data/ti_flash_read_num
add wave -expand -group "Testbench" -radix hex      sim:/testbench/n_addr_ptr
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/n_num_reads
for {set i 0} {$i < 24} {incr i} {
  add wave -expand -group "Testbench" -group "r_expt_data_array"    -radix hex  sim:/testbench/r_expt_data_array([expr {24-$i}])
  add wave -expand -group "Testbench" -group "w_handler_data_array" -radix hex  sim:/testbench/w_handler_data_array([expr {24-$i}])
}
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_expt_data
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_handler_data
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_data_mismatch

# Add UUT signals
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/spi_handler_flash/s_valid_data_req
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/spi_handler_flash/n_spi_cmd_cnt
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/spi_handler_flash/n_spi_addr_cnt
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/spi_handler_flash/n_spi_bit_cnt
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/spi_handler_flash/n_spi_word_cnt
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/spi_handler_flash/n_spi_clk_cnt
add wave -expand -group "UUT"                 sim:/testbench/UUT/spi_handler_flash/s_sys_state
add wave -expand -group "UUT"                 sim:/testbench/UUT/spi_handler_flash/s_sys_nstate
add wave -expand -group "UUT"                 sim:/testbench/UUT/spi_handler_flash/s_spi_state
add wave -expand -group "UUT"                 sim:/testbench/UUT/spi_handler_flash/s_spi_nstate
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/spi_handler_flash/s_spi_xfer_done

# Add Flash Model signals
# add wave -expand -group "Flash Model" -radix hex  sim:/testbench/flash_0/s_air_temperature
# add wave -expand -group "Flash Model" -radix hex  sim:/testbench/flash_0/s_temperature
# add wave -expand -group "Flash Model" -radix hex  sim:/testbench/flash_0/s_spi_temperature

# Add SPI inter-module SPI signals
add wave -expand -group "SPI" -radix binary sim:/testbench/r_spi_clk
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_cs_n
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_si
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_so
add wave -expand -group "SPI" -radix binary sim:/testbench/r_wp_n
add wave -expand -group "SPI" -radix binary sim:/testbench/r_hold_n

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
