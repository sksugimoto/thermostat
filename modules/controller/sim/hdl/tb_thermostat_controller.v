// tb_thermostat_controller.v
// Author: Samuel Sugimoto
// Date:

// Testbench for the thermostat control module

`timescale 1us/1us

module testbench;
  // Parameters
  parameter       p_clk_freq  = 20;
  parameter[31:0] p_stc_heat  = 32'h41F1C;  // Heat on @ 78F (25.5C)
  parameter[31:0] p_stc_cool  = 32'h21412;  // Cool on @ 68F (20.0C)
  parameter[31:0] p_stc_auto  = 32'h61816;  // Auto on @ 72F (22.0C)
  parameter[31:0] p_stc_off   = 32'h0;      // Heat and Cool off.

  // Controler signals
  reg         r_clk;
  reg         r_reset_n;
  reg         r_sys_pwn_n;
  wire        w_cycling;
  reg         r_use_f;
  wire[6:-2]  w_temperature;
  reg [31:0]  r_prog_stc;
  reg [31:0]  r_man_stc;
  wire        w_green_fan;
  wire        w_yellow_ac;
  wire        w_white_heat;

  // SPI Handler signals
  reg       r_read_therm;
  wire[9:0] w_spi_temperature;
  reg [9:0] r_temperature_c;
  wire      w_therm_ready;
  integer   n_clk_counter;
  wire      w_spi_clk;
  wire[1:0] w_spi_cs_n;
  wire      w_spi_si;
  wire      w_spi_so;

  // Thermometer Model signals
  reg       r_amb_hc;

  // -------------------------------------------
  // --         MODULE INSTANTIATIONS         --
  // -------------------------------------------
  wrapper_thermostat_controller # (
    .g_sc_delay_time(p_clk_freq*10),  // 10 seconds
    .g_man_stc_itime(p_clk_freq*5)    // 5 seconds
  ) UUT (
    // Clock and Reset
    .i_clk(r_clk),
    .i_reset_n(r_reset_n),
    // User Control Inputs
    .i_sys_pwr_n(r_sys_pwn_n),
    .o_cycling(w_cycling),
    // Temperature Control Inputs
    .i_use_f(r_use_f),
    .i_temperature(w_temperature),
    // STC Inputs
    .i_prog_stc(r_prog_stc),
    .i_man_stc(r_man_stc),
    // HVAC Control wires
    .o_green_fan(w_green_fan),
    .o_yellow_ac(w_yellow_ac),
    .o_white_heat(w_white_heat)
  );

  wrapper_spi_handler spi_handler (
    // System clock
    .i_clk(r_clk),                      // : in  std_logic;
    .i_reset_n(r_reset_n),              // : in  std_logic;
    // Programming Request Controls
    .i_read_program(1'b0),              // : in  std_logic;
    .o_program_data(),                  // : out std_logic_vector(16895 downto 0);
    .o_program_ready(),                 // : out std_logic;
    // Temperatrue Request Controls
    .i_read_therm(r_read_therm),        // : in  std_logic;
    .o_temperature(w_spi_temperature),  // : out std_logic_vector(9 downto 0);
    .o_therm_ready(w_therm_ready),      // : out std_logic;
    // SPI Port
    .i_spi_disconnect(1'b0),            // : in  std_logic;
    .o_spi_clk(w_spi_clk),              // : out std_logic;  -- 10KHz clock
    .o_spi_cs_n(w_spi_cs_n),            // : out std_logic_vector(1 downto 0);
    .o_spi_si(w_spi_si),                // : out std_logic;
    .i_spi_so(w_spi_so)                 // : in  std_logic
  );

  // Thermoter Module
  thermometer_model # (
    .g_spi_clk_freq(p_clk_freq/2),
    .g_temp_chg_sec(1)
  ) therm0 (
    .i_spi_clk(w_spi_clk),
    .i_spi_cs_n(w_spi_cs_n[0]),
    .i_spi_si(w_spi_si),
    .o_spi_so(w_spi_so),
    .i_heat(w_white_heat),
    .i_cool(w_yellow_ac),
    .i_amb_hc(r_amb_hc)
  );

  // SPI Data to ufixed temperature data
  spi_to_temp s2t (
    .i_use_f(r_use_f),
    .i_spi_data(r_temperature_c),
    .o_temp_data(w_temperature)
  );

  // --------------------------------------------
  // --            CLOCK GENERATION            --
  // --------------------------------------------
  // System clock generation (20KHz)
  initial r_clk <= 1'b1;
  always #25 r_clk <= ~r_clk;

  // --------------------------------------------
  // --     TEMPERATURE REQUEST GENERATION     --
  // --------------------------------------------
  // Get temperature ever 0.5 second
  initial n_clk_counter <= 0;
  always begin
    @(posedge r_clk) n_clk_counter <= n_clk_counter == ((p_clk_freq/2)-1) ? 0 : n_clk_counter + 1;
  end

  initial begin
    r_read_therm <= 1'b0;
    r_temperature_c <= 9'h0;
  end
  always begin
    wait(n_clk_counter == ((p_clk_freq/2)-1)) r_read_therm <= 1'b1;
    wait(w_therm_ready == 1'b1);
    @(posedge r_clk) r_temperature_c <= w_spi_temperature;
    r_read_therm <= 1'b0;
  end

  // --------------------------------------------
  // --             TEST PROCEDURE             --
  // --------------------------------------------
  initial begin
    // Set initial values
    r_reset_n   <= 1'b1;  // Reset deasserted
    r_sys_pwn_n <= 1'b1;  // System off
    r_use_f     <= 1'b1;  // Use Fahrenheit
    r_prog_stc  <= 32'h0; // Program STC to off
    r_man_stc   <= 32'h0; // Manual STC to off
    r_amb_hc    <= 1'b0;  // Temperature falling nautrally
    
    // Wait 1 second for first temperatrue to load
    repeat(p_clk_freq) @(posedge r_clk);
    // Switch System on
    r_sys_pwn_n <= 1'b0;
    // Set STCs
    test_program_heat;
    test_program_cool;
    test_program_auto;
    test_manual;
    $display("Testing System off...");
    r_sys_pwn_n <= 1'b1;

    repeat(p_clk_freq*20) @(posedge r_clk);
    $stop;
  end

  task test_program_heat;
  begin
    $display("Testing Program Heat...");
    r_amb_hc    <= 1'b0;
    r_prog_stc  <= p_stc_heat;
    r_man_stc   <= p_stc_off;
    repeat(2) @(posedge w_white_heat);
    @(negedge w_white_heat);
  end
  endtask

  task test_program_cool;
  begin
    $display("Testing Program Cool...");
    r_amb_hc    <= 1'b1;
    r_prog_stc  <= p_stc_cool;
    r_man_stc   <= p_stc_off;
    repeat(2) @(posedge w_yellow_ac);
    @(negedge w_yellow_ac);
  end
  endtask

  task test_program_auto;
  begin
    $display("Testing Program Auto...");
    // Test Heat
    r_amb_hc    <= 1'b0;
    r_prog_stc  <= p_stc_auto;
    r_man_stc   <= p_stc_off;
    repeat(2) @(posedge w_white_heat);

    // Test Cool
    r_amb_hc    <= 1'b1;
    repeat(2) @(posedge w_yellow_ac);
  end
  endtask

  task test_manual;
  begin
    $display("Testing Manual Override...");
    r_amb_hc  <= 1'b0;
    r_man_stc <= p_stc_heat;
    repeat(2) @(posedge w_white_heat);
    @(negedge w_white_heat);
    r_amb_hc  <= 1'b1;
    r_man_stc <= p_stc_cool;
    repeat(2) @(posedge w_yellow_ac);
    @(negedge w_yellow_ac);

  end
  endtask

endmodule
