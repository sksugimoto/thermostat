
vsim -voptargs=+acc -t 1us work.testbench

# Add testbench signals
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_clk
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_reset_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_sys_pwn_n
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_use_f
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_amb_hc
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/r_temperature_c(9:2)
add wave -expand -group "Testbench" -radix binary   sim:/testbench/r_temperature_c(1:0)
add wave -expand -group "Testbench" -radix unsigned sim:/testbench/w_temperature(6:0)
add wave -expand -group "Testbench" -radix binary   {sim:/testbench/w_temperature[-1]}
add wave -expand -group "Testbench" -radix binary   {sim:/testbench/w_temperature[-2]}
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_prog_stc
add wave -expand -group "Testbench" -radix hex      sim:/testbench/r_man_stc
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_cycling
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_green_fan
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_yellow_ac
add wave -expand -group "Testbench" -radix binary   sim:/testbench/w_white_heat

# Add UUT signals
add wave -expand -group "UUT"                 sim:/testbench/UUT/controller/s_therm_state
add wave -expand -group "UUT"                 sim:/testbench/UUT/controller/s_therm_nstate
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/controller/s_target_temp(6:0)
add wave -expand -group "UUT" -radix binary   {sim:/testbench/UUT/controller/s_target_temp[-1]}
add wave -expand -group "UUT"                 sim:/testbench/UUT/controller/i_prog_stc
add wave -expand -group "UUT"                 sim:/testbench/UUT/controller/i_man_stc
add wave -expand -group "UUT"                 sim:/testbench/UUT/controller/s_man_stc_active
add wave -expand -group "UUT"                 sim:/testbench/UUT/controller/s_man_stc_settled
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/controller/n_man_stc_stl_cntr
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_mode
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_auto_range
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_buffer
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_auto_cool_on
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_auto_heat_on
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_auto_cool_off
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_auto_heat_off
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_cool_on
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_heat_on
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_cool_off
add wave -expand -group "UUT" -radix binary   sim:/testbench/UUT/controller/s_heat_off
add wave -expand -group "UUT" -radix unsigned sim:/testbench/UUT/controller/n_delay_counter

# Add Thermometer Model signals
add wave -expand -group "Therm Model"                 sim:/testbench/therm0/s_spi_state
add wave -expand -group "Therm Model"                 sim:/testbench/therm0/s_spi_nstate
add wave -expand -group "Therm Model" -radix unsigned sim:/testbench/therm0/n_counter
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm0/s_air_temperature
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm0/s_temperature
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm0/s_spi_temperature

# Add SPI inter-module SPI signals
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_clk
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_cs_n
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_si
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_so

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
