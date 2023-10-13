vcom -2008 -check_synthesis ../../modules/global_package/global_package.vhd
vcom -2008 -check_synthesis ../../modules/scheduler_control/hdl/schedule_package.vhd
vcom -2008 -check_synthesis ../../modules/controller/hdl/stc_package.vhd
vcom -2008 -check_synthesis ../../modules/time_keeper/hdl/time_package.vhd
vcom -2008 -check_synthesis ../../modules/hex_ascii_to_14seg/hdl/display_14seg_package.vhd
vcom -2008 -check_synthesis ../../modules/spi_handler_thermometer/hdl/spi_handler_thermometer.vhd
vcom -2008 -check_synthesis ../../modules/spi_handler_flash/hdl/spi_handler_flash.vhd
vcom -2008 -check_synthesis ../../modules/spi_handler/hdl/spi_handler.vhd
vcom -2008 -check_synthesis ../../modules/spi_data_handler/hdl/spi_data_handler.vhd
vcom -2008 -check_synthesis ../../modules/spi_to_temp/hdl/spi_to_temp.vhd
vcom -2008 -check_synthesis ../../modules/usr_ctrl_ovride/hdl/usr_ctrl_ovride.vhd
vcom -2008 -check_synthesis ../../modules/scheduler_control/hdl/scheduler_control.vhd
vcom -2008 -check_synthesis ../../modules/controller/hdl/thermostat_controller.vhd
vcom -2008 -check_synthesis ../../modules/time_keeper/hdl/time_keeper.vhd
vcom -2008 -check_synthesis ../../modules/hex_ascii_to_14seg/hdl/hex_ascii_to_14seg.vhd
vcom -2008 -check_synthesis ../../modules/display_controller/hdl/display_controller.vhd
vcom -2008 -check_synthesis ../../hdl/thermostat_top.vhd
vcom -2008 ../../modules/sim_flash_model/hdl/flash_model.vhd
vcom -2008 ../../modules/sim_flash_model/sim/hdl/wrapper_flash_model.vhd
vcom -2008 ../../modules/sim_thermometer_model/hdl/thermometer_model.vhd
vlog ../hdl/tb_thermostat_top.v
