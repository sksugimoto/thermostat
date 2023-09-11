// tb_spi_handler_flash.v
// Author: Samuel Sugimoto
// Date: 

// Testbench for Flash SPI handler.

`timescale 1us/1us

module testbench;
  // Handler Control signals
  reg           r_sys_clk;
  reg           r_reset_n;
  reg           r_data_request;
  reg[23:0]     r_read_addr;
  reg[11:0]     r_read_num;
  wire          w_data_ready;
  wire          w_command_error;
  wire[32767:0] w_data; // Originally t_array_slv8(2047 downto 0)

  // Flash model control signals
  reg             r_wp_n;
  reg             r_hold_n;
  wire[1048575:0] w_mem;
  integer         scan_file;

  // SPI signals
  reg   r_spi_clk;
  wire  w_spi_cs_n;
  wire  w_spi_si;
  wire  w_spi_so;

  // Testbench signals
  genvar  g_i;
  integer i;
  integer fh;
  integer n_addr_ptr;
  integer n_num_reads;
  reg [63:0]    r_mem_array [16383:0];          // Test Flash data
  reg [32767:0] r_handler_data;                 // Data produced by handler, 1-D array
  wire[7:0]     w_handler_data_array [4095:0];  // Data produced by handler, 2-D array
  reg [7:0]     r_expt_data_array[4095:0];      // Data expected from handler, 2-D array
  reg [32767:0] r_expt_data;                    // Data expected from handler, 1-D array
  reg           r_data_mismatch;
  
  // -------------------------------------------
  // --         MODULE INSTANTIATIONS         --
  // -------------------------------------------
  // SPI Handler module uut
  wrapper_spi_handler_flash #(
    .g_addr_max_width(8'd17)
  ) 
  UUT (
    // Generics
    
    // System clock/reset
    .i_sys_clk(r_sys_clk),
    .i_reset_n(r_reset_n),
    // Control Signals
    .i_data_request(r_data_request),  // Only goes high when SPI bus is available
    .i_read_addr(r_read_addr),
    .i_read_num(r_read_num),
    .o_data_ready(w_data_ready),
    .o_command_error(w_command_error),
    .o_data(w_data),
    // SPI Port
    .i_spi_clk(r_spi_clk),
    .o_spi_cs_n(w_spi_cs_n),
    .o_spi_si(w_spi_si),
    .i_spi_so(w_spi_so)
  );

  // Flash model for handler to communicate with
  wrapper_flash_model flash_0 (
    // Normal SST25VG010A connections
    .i_sck(r_spi_clk),
    .i_ce_n(w_spi_cs_n),
    .i_wp_n(r_wp_n),
    .i_hold_n(r_hold_n),
    .i_si(w_spi_si),
    .o_so(w_spi_so),
    // Additional I/O for simulation/model purposes
    .i_mem(w_mem)
  );

  // --------------------------------------------
  // --            CLOCK GENERATION            --
  // --------------------------------------------
  // System clock generation (20KHz)
  initial r_sys_clk <= 1'b1;
  always #25 r_sys_clk <= ~r_sys_clk;

  // SPI clock generation (10KHz)
  initial r_spi_clk <= 1'b1;
  always #50 r_spi_clk <= ~r_spi_clk;

  // --------------------------------------------
  // --         DATA ARRAY CONVERSIONS         --
  // --------------------------------------------
  // Convert r_mem_array 2d-array to 1d-wire w_mem.
  generate
    for(g_i = 0; g_i < 16384; g_i = g_i + 1) begin
      assign w_mem[(g_i*64+63):(g_i*64)] = r_mem_array[g_i];
    end
  endgenerate
  // Convert r_handler_data 1d-array to 2d w_handler_data_array
  generate
    for(g_i = 0; g_i < 4096; g_i = g_i + 1) begin
      assign w_handler_data_array[g_i] = r_handler_data[(g_i*8+7):(g_i*8)];
    end
  endgenerate

  // --------------------------------------------
  // --        EXPECTED DATA GENERATION        --
  // --------------------------------------------
  always @(*) begin
    for(i = 0; i < 4096; i = i + 1) begin
      if(i < n_num_reads) begin
        r_expt_data_array[i] <= (n_addr_ptr + i) < 131072 ? r_mem_array[(n_addr_ptr+i)/8][(((n_addr_ptr+i) % 8)*8) +: 8] : r_mem_array[(n_addr_ptr+i-131072)/8][(((n_addr_ptr+i-131072) % 8)*8) +: 8];
        r_expt_data[(8*i) +: 8] <= (n_addr_ptr + i) < 131072 ? r_mem_array[(n_addr_ptr+i)/8][(((n_addr_ptr+i) % 8)*8) +: 8] : r_mem_array[(n_addr_ptr+i-131072)/8][(((n_addr_ptr+i-131072) % 8)*8) +: 8];
      end else begin
        r_expt_data_array[i] <= 8'h0;
        r_expt_data[(8*i) +: 8] <= 8'h0;
      end
    end
  end

  // --------------------------------------------
  // --             TEST PROCEDURE             --
  // --------------------------------------------
  initial begin
    // Read test file
    fh = $fopen("test_flash.dat", "r");
    if(fh == 0) begin
      $display("Error: File Handler was NULL");
      $stop;
    end
    for(i = 0; i < 16384; i = i + 1) begin
      if(i == 0) begin
        $display("Reading file...");
      end
      scan_file <= i == 16383 ? $fscanf(fh, "%h", r_mem_array[i]) : $fscanf(fh,"%x\n", r_mem_array[i]);
    end
    $display("Done reading file.");
    $fclose(fh);

    // Set initial values
    r_reset_n         <= 1'b1;
    r_data_request    <= 1'b0;
    r_read_addr       <= 24'h0;
    r_read_num        <= 12'h0;
    r_wp_n            <= 1'b1;
    r_hold_n          <= 1'b1;
    r_data_mismatch   <= 1'b0;

    // Wait 10 clock cycles before starting test
    repeat (10) @(posedge r_sys_clk);
    
    // Run test
    req_flash_data(24'h5, 12'd16);
    req_flash_data(24'h0, 12'd24);
    req_flash_data(24'h1FFFC, 12'd16);
    // req_flash_data(24'h0, 12'd2112);

    // Wait 10 clock cycles before stopping test
    repeat (10) @(posedge r_sys_clk);
    if(r_data_mismatch == 1'b0) begin
      $display("Test completed successfully, data out matches expected data.");
    end else begin
      $display("Test failed, data out does not match expected data.");
    end
    $stop;
  end

  task req_flash_data;
    input [23:0] ti_flash_addr;
    input [11:0] ti_flash_read_num;
  begin
    // Set signals to request data from flash
    @(posedge r_sys_clk) r_data_request <= 1'b1;
    r_read_addr <= ti_flash_addr;
    r_read_num  <= ti_flash_read_num;
    n_addr_ptr  <= {8'h0, ti_flash_addr};
    n_num_reads <= {20'h0, ti_flash_read_num};
    // Wait for SPI flash handler to obtain data
    wait(w_data_ready == 1'b1);
    // Save data obtained from flash handler
    @(posedge r_sys_clk) r_handler_data <= w_data;
    r_data_request  <= 1'b0;
    wait(w_data_ready == 1'b0);
    if(r_expt_data != r_handler_data) begin
      r_data_mismatch <= 1'b1;
    end
  end 
  endtask

endmodule
