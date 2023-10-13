
vsim -voptargs=+acc -t 1us work.testbench

# Add testbench signals
add wave -expand -group "Testbench"                         -radix binary   sim:/testbench/r_clk
add wave -expand -group "Testbench"                         -radix binary   sim:/testbench/r_reset_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_sys_on_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_use_f_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_run_prog_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_force_fan_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_heat_cool_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_reprogram_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_set_time_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_incr_week_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_incr_day_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_incr_hr_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_incr_min_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_temp_up_n
add wave -expand -group "Testbench" -group "User Controls"  -radix binary   sim:/testbench/r_temp_down_n
add wave -expand -group "Testbench" -group "Time"           -radix binary   sim:/testbench/w_day_time_day_n
add wave -expand -group "Testbench" -group "Time"           -radix hex      sim:/testbench/w_14seg_n(3)
add wave -expand -group "Testbench" -group "Time"           -radix hex      sim:/testbench/w_14seg_n(2)
add wave -expand -group "Testbench" -group "Time"           -radix hex      sim:/testbench/w_14seg_n(1)
add wave -expand -group "Testbench" -group "Time"           -radix hex      sim:/testbench/w_14seg_n(0)
add wave -expand -group "Testbench" -group "LEDs"           -radix binary   sim:/testbench/w_prgm_error_n
add wave -expand -group "Testbench" -group "LEDs"           -radix binary   sim:/testbench/w_prgm_ovride_n
add wave -expand -group "Testbench" -group "LEDs"           -radix binary   sim:/testbench/w_heat_on_n
add wave -expand -group "Testbench" -group "LEDs"           -radix binary   sim:/testbench/w_cool_on_n
add wave -expand -group "Testbench" -group "LEDs"           -radix binary   sim:/testbench/w_force_fan_n
add wave -expand -group "Testbench" -group "Amb Temp"       -radix binary   sim:/testbench/w_14seg_n(7)
add wave -expand -group "Testbench" -group "Amb Temp"       -radix binary   sim:/testbench/w_14seg_n(6)
add wave -expand -group "Testbench" -group "Amb Temp"       -radix binary   sim:/testbench/w_14seg_n(5)
add wave -expand -group "Testbench" -group "Amb Temp"       -radix binary   sim:/testbench/w_14seg_n(4)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(15)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(14)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(13)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(12)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(11)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(10)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(9)
add wave -expand -group "Testbench" -group "Msg/Set Temp"   -radix binary   sim:/testbench/w_14seg_n(8)
add wave -expand -group "Testbench" -group "3 Wire Control" -radix binary   sim:/testbench/w_green_fan
add wave -expand -group "Testbench" -group "3 Wire Control" -radix binary   sim:/testbench/w_yellow_ac
add wave -expand -group "Testbench" -group "3 Wire Control" -radix binary   sim:/testbench/w_white_heat

# Add UUT signals
add wave -expand -group "UUT"                                 sim:/testbench/UUT/s_prog_stc
add wave -expand -group "UUT"                                 sim:/testbench/UUT/s_man_stc
add wave -expand -group "UUT" -group "Reset"                  sim:/testbench/UUT/s_sys_reset_n
add wave -expand -group "UUT" -group "Reset"  -radix binary   sim:/testbench/UUT/s_sys_reset_n
add wave -expand -group "UUT" -group "Reset"  -radix binary   sim:/testbench/UUT/s_spi_reset_n
add wave -expand -group "UUT" -group "Reset"  -radix unsigned sim:/testbench/UUT/n_rst_cntr
add wave -expand -group "UUT" -group "SPI Data Handler" -radix binary   sim:/testbench/UUT/s_read_program
add wave -expand -group "UUT" -group "SPI Data Handler" -radix binary   sim:/testbench/UUT/s_program_ready
add wave -expand -group "UUT" -group "SPI Data Handler" -radix binary   sim:/testbench/UUT/s_read_therm
add wave -expand -group "UUT" -group "SPI Data Handler" -radix binary   sim:/testbench/UUT/s_therm_ready
add wave -expand -group "UUT" -childformat {{/testbench/UUT/s_day_time.day -radix binary} {/testbench/UUT/s_day_time.hour -radix unsigned} {/testbench/UUT/s_day_time.minute -radix unsigned} {/testbench/UUT/s_day_time.second -radix unsigned}} -expand -subitemconfig {/testbench/UUT/s_day_time.day {-radix binary} /testbench/UUT/s_day_time.hour {-radix unsigned} /testbench/UUT/s_day_time.minute {-radix unsigned} /testbench/UUT/s_day_time.second {-radix unsigned}} /testbench/UUT/s_day_time

# Add SPI inter-module SPI signals
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_clk
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_cs_n
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_si
add wave -expand -group "SPI" -radix binary sim:/testbench/w_spi_so

# Add Thermometer Model signals
add wave -expand -group "Therm Model" -radix binary   sim:/testbench/r_amb_hc
add wave -expand -group "Therm Model"                 sim:/testbench/therm_0/s_spi_state
add wave -expand -group "Therm Model"                 sim:/testbench/therm_0/s_spi_nstate
add wave -expand -group "Therm Model" -radix unsigned sim:/testbench/therm_0/n_counter
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm_0/s_air_temperature
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm_0/s_temperature
add wave -expand -group "Therm Model" -radix hex      sim:/testbench/therm_0/s_spi_temperature

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
