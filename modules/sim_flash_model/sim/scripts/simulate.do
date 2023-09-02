
# Execute perl script to generate flash data
eval perl ../scripts/gen_flash.pl
# Start Simulation
vsim -voptargs=+acc -t 1us work.tb_flash_model
# Log all signals
# log -r *
# Add testbench signals
add wave -expand -group "Testbench" -radix binary   sim:/tb_flash_model/s_sck
add wave -expand -group "Testbench" -radix binary   sim:/tb_flash_model/s_ce_n
add wave -expand -group "Testbench" -radix binary   sim:/tb_flash_model/s_si
add wave -expand -group "Testbench" -radix binary   sim:/tb_flash_model/s_so
add wave -expand -group "Testbench" -radix hex      sim:/tb_flash_model/s_curr_xfer
add wave -expand -group "Testbench" -radix hex      sim:/tb_flash_model/s_expt_data
add wave -expand -group "Testbench" -radix hex      sim:/tb_flash_model/s_last_xfer
for {set i 0} {$i < 16} {incr i} {
  add wave -expand -group "Testbench" -group "s_mem"  -radix hex      sim:/tb_flash_model/s_mem([expr {15-$i}])
}
# Add UUT Signals
add wave -expand -group "UUT" -radix hex      sim:/tb_flash_model/uut/i_sck
add wave -expand -group "UUT" -radix unsigned sim:/tb_flash_model/uut/n_cmd_clk_counter
add wave -expand -group "UUT" -radix hex      sim:/tb_flash_model/uut/s_cmd
add wave -expand -group "UUT" -radix unsigned sim:/tb_flash_model/uut/n_cmd_counter
add wave -expand -group "UUT" -radix hex      sim:/tb_flash_model/uut/s_addr
add wave -expand -group "UUT" -radix unsigned sim:/tb_flash_model/uut/n_addr_counter
add wave -expand -group "UUT" -radix unsigned sim:/tb_flash_model/uut/n_read_counter
add wave -expand -group "UUT"                 sim:/tb_flash_model/uut/s_spi_mem_nstate
add wave -expand -group "UUT"                 sim:/tb_flash_model/uut/s_spi_mem_state
for {set i 0} {$i < 128} {incr i} {
  add wave -expand -group "UUT" -group "Flash Array" -radix hex sim:/tb_flash_model/uut/s_flash_array([expr {127-$i}])
}

configure wave -signalnamewidth 1

# Run Test
run -all

wave zoom full
