//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: tb_vga_timing.sv
//
//////////////////////////////////////////////////////////////////////////////////

module tb;

  // Testbench signals
  logic         clk;
  logic         rst;
  logic         h_sync;
  logic         v_sync;
  logic  [9:0]  pixel_x;
  logic  [9:0]  pixel_y;
  logic         last_column;
  logic         last_row;
  logic         blank;

  int errors;

  //-------------------------------------------------------------------------
  // Instantiate the VGA timing module (DUT)
  //-------------------------------------------------------------------------
  vga_timing uut (
    .clk        (clk),
    .rst        (rst),
    .h_sync     (h_sync),
    .v_sync     (v_sync),
    .pixel_x    (pixel_x),
    .pixel_y    (pixel_y),
    .last_column(last_column),
    .last_row   (last_row),
    .blank      (blank)
  );

  //-------------------------------------------------------------------------
  // Clock Generation: 100 MHz clock (10 ns period)
  //-------------------------------------------------------------------------
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  //-------------------------------------------------------------------------
  // Reset Generation: Assert reset for 20 ns at the start.
  //-------------------------------------------------------------------------
  initial begin
    rst = 1'b1;
    #20;
    rst = 1'b0;
  end

  //-------------------------------------------------------------------------
  // Set simulation time display format.
  //-------------------------------------------------------------------------
  initial begin
    $timeformat(-9, 0, " ns", 20);
  end

  //-------------------------------------------------------------------------
  // Task: wait_for_pixel_update
  // Wait until the pixel coordinates equal the target row and column.
  // Since the design updates the pixel counters every 4 clock cycles,
  // we wait in steps of 4 cycles.
  //-------------------------------------------------------------------------
  task wait_for_pixel_update(input int target_row, input int target_col);
    begin
      while ((pixel_y !== target_row) || (pixel_x !== target_col)) begin
        // Wait 4 clock cycles (one pixel update period)
        repeat (4) @(posedge clk);
      end
    end
  endtask

  //-------------------------------------------------------------------------
  // Task: wait_next_pixel_update
  // Wait until the pixel coordinates change from their current value.
  // This is used to sample the counters immediately after a wrap-around.
  //-------------------------------------------------------------------------
  task wait_next_pixel_update();
    int curr_x, curr_y;
    begin
      curr_x = pixel_x;
      curr_y = pixel_y;
      // Wait until a pixel update occurs (check every 4 clock cycles)
      while ((pixel_x === curr_x) && (pixel_y === curr_y)) begin
        repeat (4) @(posedge clk);
      end
    end
  endtask

  //-------------------------------------------------------------------------
  // Task: check_condition
  // Compare actual vs. expected value; print a message and update the error count.
  //-------------------------------------------------------------------------
  task check_condition(input string signal_name, input logic actual, input logic expected);
    begin
      if (actual !== expected) begin
        $display("*** ERROR: %s is %b, expected %b at time %0t", signal_name, actual, expected, $time);
        errors++;
      end
      else begin
        $display("Correct: %s is %b at time %0t", signal_name, actual, $time);
      end
    end
  endtask

  //-------------------------------------------------------------------------
  // Main Test Sequence
  //-------------------------------------------------------------------------
  initial begin
    errors = 0;
    
    // Wait for reset deassertion and allow the counters to settle.
    @(negedge rst);
    repeat (4) @(posedge clk);

    //---------------------------------------------------------------------
    // Test 1: Beginning of visible area at (0,0)
    //---------------------------------------------------------------------
    wait_for_pixel_update(0, 0);
    $display("\n---- Testing pixel (0,0) ----");
    check_condition("h_sync",      h_sync,      1'b1);
    check_condition("v_sync",      v_sync,      1'b1);
    check_condition("blank",       blank,       1'b0);
    check_condition("last_column", last_column, 1'b0);
    check_condition("last_row",    last_row,    1'b0);

    //---------------------------------------------------------------------
    // Test 2: End of visible horizontal region at (0,639)
    //---------------------------------------------------------------------
    wait_for_pixel_update(0, 639);
    $display("\n---- Testing pixel (0,639) ----");
    check_condition("h_sync",      h_sync,      1'b1);
    check_condition("blank",       blank,       1'b0);
    check_condition("last_column", last_column, 1'b1);

    //---------------------------------------------------------------------
    // Test 3: First pixel of horizontal blanking (0,640)
    //---------------------------------------------------------------------
    wait_for_pixel_update(0, 640);
    $display("\n---- Testing pixel (0,640) ----");
    check_condition("blank", blank, 1'b1);

    //---------------------------------------------------------------------
    // Test 4: Beginning of horizontal sync active region (0,656)
    //---------------------------------------------------------------------
    wait_for_pixel_update(0, 656);
    $display("\n---- Testing pixel (0,656) ----");
    check_condition("h_sync", h_sync, 1'b0);
    check_condition("blank",  blank,  1'b1);

    //---------------------------------------------------------------------
    // Test 5: End of horizontal sync active region (0,751)
    //---------------------------------------------------------------------
    wait_for_pixel_update(0, 751);
    $display("\n---- Testing pixel (0,751) ----");
    check_condition("h_sync", h_sync, 1'b0);
    check_condition("blank",  blank,  1'b1);

    //---------------------------------------------------------------------
    // Test 6: Start of horizontal back porch (0,752)
    //---------------------------------------------------------------------
    wait_for_pixel_update(0, 753);
    $display("\n---- Testing pixel (0,752) ----");
    check_condition("h_sync", h_sync, 1'b1);
    check_condition("blank",  blank,  1'b1);

    //---------------------------------------------------------------------
    // Test 7: Last visible row, final pixel (479,639)
    //---------------------------------------------------------------------
    wait_for_pixel_update(479, 639);
    $display("\n---- Testing pixel (479,639) ----");
    check_condition("v_sync",   v_sync,   1'b1);
    check_condition("blank",    blank,    1'b0);
    check_condition("last_row", last_row, 1'b1);

    //---------------------------------------------------------------------
    // Test 8: Beginning of vertical blanking (480,0)
    //---------------------------------------------------------------------
    wait_for_pixel_update(480, 0);
    $display("\n---- Testing pixel (480,0) ----");
    check_condition("v_sync", v_sync, 1'b1);
    check_condition("blank",  blank,  1'b1);

    //---------------------------------------------------------------------
    // Test 9: Start of vertical sync active region (490,0)
    //---------------------------------------------------------------------
    wait_for_pixel_update(490, 0);
    $display("\n---- Testing pixel (490,0) ----");
    check_condition("v_sync", v_sync, 1'b0);
    check_condition("blank",  blank,  1'b1);

    //---------------------------------------------------------------------
    // Test 10: End of vertical sync active region (491,0)
    //---------------------------------------------------------------------
    wait_for_pixel_update(491, 0);
    $display("\n---- Testing pixel (491,0) ----");
    check_condition("v_sync", v_sync, 1'b0);
    check_condition("blank",  blank,  1'b1);

    //---------------------------------------------------------------------
    // Test 11: End of vertical sync, back porch begins (492,0)
    //---------------------------------------------------------------------
    wait_for_pixel_update(492, 0);
    $display("\n---- Testing pixel (492,0) ----");
    check_condition("v_sync", v_sync, 1'b1);
    check_condition("blank",  blank,  1'b1);

    //---------------------------------------------------------------------
    // Test 12: Horizontal Wrap-Around Check
    // When the horizontal counter reaches (10,799), the next pixel update
    // should set the counters to (11,0).
    //---------------------------------------------------------------------
    wait_for_pixel_update(10, 799);
    $display("\n---- Testing horizontal wrap-around from pixel (10,799) ----");
    wait_next_pixel_update();
    check_condition("wrap-around pixel_x", pixel_x, 10'd0);
    check_condition("wrap-around pixel_y", pixel_y, 10'd11);

    //---------------------------------------------------------------------
    // Test 13: Frame Wrap-Around Check
    // When the counters reach (520,799), the next pixel update should be (0,0).
    //---------------------------------------------------------------------
    wait_for_pixel_update(520, 799);
    $display("\n---- Testing frame wrap-around from pixel (520,799) ----");
    wait_next_pixel_update();
    check_condition("frame wrap-around pixel_x", pixel_x, 10'd0);
    check_condition("frame wrap-around pixel_y", pixel_y, 10'd0);

    //---------------------------------------------------------------------
    // Test 14: Mid-Run Reset Test
    // Assert reset mid-frame and verify that the counters immediately reset to 0.
    //---------------------------------------------------------------------
    wait_for_pixel_update(100, 100);
    $display("\n---- Testing mid-run reset ----");
    rst = 1;
    @(posedge clk);
    rst = 0;
    wait_next_pixel_update();
    check_condition("mid-run reset pixel_x", pixel_x, 10'd1);
    check_condition("mid-run reset pixel_y", pixel_y, 10'd0);

    //---------------------------------------------------------------------
    // Final Report
    //---------------------------------------------------------------------
    #50;
    if (errors == 0)
      $display("\n*** Simulation COMPLETED SUCCESSFULLY with %0d errors at time %0t ***", errors, $time);
    else
      $display("\n*** Simulation COMPLETED with %0d errors at time %0t ***", errors, $time);
    $finish;
  end

endmodule
