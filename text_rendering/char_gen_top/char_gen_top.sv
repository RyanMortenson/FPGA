/***************************************************************************
* 
* Filename: char_gen_top.sv
*
* Author: Ryan Mortenson
* Description: top-level character generator module
*
****************************************************************************/

module char_gen_top #(
    parameter FILENAME = "",	// Specifies the filename of the initial contents of character memory
    parameter CLK_FREQUENCY = 100_000_000, // Specifies the frequency of the clock in Hz
    parameter BAUD_RATE = 19_200, // Determines the baud rate of the receiver
    parameter WAIT_TIME_US = 5_000, // Determines the wait time, in micro seconds, for the debounce circuit
    parameter REFRESH_RATE = 200 // Specifies the display refresh rate in Hz
)(
    input logic         clk,        // 100MHz System Clock
    input logic         btnd,        // Reset
    input logic         btnc,       // Write character
    input logic         btnl,       // Set background color
    input logic         btnr,       // Set foreground color
    input logic         rx_in,      // UART Receiver Input
    input logic [11:0]  sw,         // Determines character to write or color to display
    output logic        Hsync,      // Horizontal synchronization signal
    output logic        Vsync,      // Vertical synchronization signal
    output logic [3:0]  vgaRed,     // Red color signal
    output logic [3:0]  vgaGreen,   // Green color signal
    output logic [3:0]  vgaBlue,    // Blue color signal
    output logic [3:0]  anode,      //Anode signals for each of the four display digits
    output logic [7:0]  segment      //Cathode signals for seven-segment display
);


// Intermediate signals
logic btnd_r, db_r, btnl_r, btnr_r, rx_in_r, ack_r, hsync_r, vsync_r, btnc_r;
logic btnd_rr, db_rr, btnl_rr, btnr_rr, rx_in_rr, hsync_rr, vsync_rr, btnc_rr;
logic hsync_rrr, vsync_rrr;
logic hsync_int, vsync_int;
logic char_we, pixel_out, blank, ack, debounced, btnc_pressed, ack_asserted, rx_received;
logic btnl_pressed, btnr_pressed;
logic [11:0] char_addr;
logic [6:0] char_value, char_write_value;
logic [11:0] sw_r;
logic [7:0] Dout;
logic [9:0] pixel_x, pixel_y;
logic last_column, last_row;

// RGB pipeline regs (3-stage)
logic [11:0] rgb_stage0;
logic [11:0] rgb_r, rgb_rr, rgb_rrr;

// foreground/background color registers
logic [11:0] bg_color, fg_color;


// delay registers for button and switch inputs, 
// and for rx input and ack signal from UART receiver
// to synchronize to clk and to detect edges
// and for synchronizing Hsync and Vsync to VGA output timing, 
// and for synchronizing RGB output to VGA timing

//btnd_r
always_ff @(posedge clk) begin
    btnd_r <= btnd;
end
//btnd_rr
always_ff @(posedge clk) begin
    btnd_rr <= btnd_r;
end
//db_r is the registered version of the debounced btnc signal, which we use to detect btnc presses in a synchronous way. We need to debounce btnc because it's used for writing characters, and we don't want multiple writes from a single press due to button bounce.
always_ff @(posedge clk) begin
    db_r <= debounced;
end
//db_rr
always_ff @(posedge clk) begin
    db_rr <= db_r;
end
//btnl_r
always_ff @(posedge clk) begin
    btnl_r <= btnl;
end
//btnl_rr
always_ff @(posedge clk) begin
    btnl_rr <= btnl_r;
end
//btnr_r
always_ff @(posedge clk) begin
    btnr_r <= btnr;
end
//btnr_rr
always_ff @(posedge clk) begin
    btnr_rr <= btnr_r;
end
//rx_in_r
always_ff @(posedge clk) begin
    rx_in_r <= rx_in;
end
//rx_in_rr
always_ff @(posedge clk) begin
    rx_in_rr <= rx_in_r;
end
//sw_r
always_ff @(posedge clk) begin
    sw_r <= sw;
end
//ack_r
always_ff @(posedge clk) begin
    ack_r <= ack;
end
//hsync_r
always_ff @(posedge clk) begin
    hsync_r <= hsync_int;
end
//hsync_rr
always_ff @(posedge clk) begin
    hsync_rr <= hsync_r;
end
//hsync_rrr
always_ff @(posedge clk) begin
    hsync_rrr <= hsync_rr;
end
//vsync_r
always_ff @(posedge clk) begin
    vsync_r <= vsync_int;
end
//vsync_rr
always_ff @(posedge clk) begin
    vsync_rr <= vsync_r;
end
//vsync_rrr
always_ff @(posedge clk) begin
    vsync_rrr <= vsync_rr;
end
// rgb_r
always_ff @(posedge clk) begin
    rgb_r <= rgb_stage0;
end
// rgb_rr
always_ff @(posedge clk) begin
    rgb_rr <= rgb_r;
end
// rgb_rrr
always_ff @(posedge clk) begin
    rgb_rrr <= rgb_rr;
end
//btnc_r
always_ff @(posedge clk) begin
    btnc_r <= btnc;
end
//btnc_rr
always_ff @(posedge clk) begin
    btnc_rr <= btnc_r;
end

// Instantiate seven segment display module
seven_segment4 seven_segment4_inst (
    .clk(clk),
    .rst(btnd_rr),
    .data_in({4'b0000,sw_r}),
    .dp_in(4'b0000), // no decimal points
    .blank(4'b1000), // display the right three digits and blank the leftmost digit
    .segment(segment),
    .anode(anode)
);

// --- color registers: reset + set on btnl/btnr presses ---
// detect btnl/btnr rising edges (same style as btnc_pressed)
assign btnc_pressed = db_rr && !db_r;       // Detect rising edge of debounced btnc
assign btnl_pressed = btnl_rr && !btnl_r;
assign btnr_pressed = btnr_rr && !btnr_r;

// On reset bg=black, fg=white. On btnl/btnr press, latch switches value (sw_r concat)
always_ff @(posedge clk) begin
    if (btnd_rr) begin
        bg_color <= 12'h000; // black
        fg_color <= 12'hfff; // white
    end else begin
        if (btnl_pressed) begin
            bg_color <= {sw_r, 4'b0000};
        end
        if (btnr_pressed) begin
            fg_color <= {sw_r, 4'b0000};
        end
    end
end

// VGA TIMING
vga_timing vga_timing_inst (
    .clk        (clk),         // 100 MHz Clock signal
    .rst        (btnd_rr),     // Synchronous reset
    .h_sync     (hsync_int),   // Internal horizontal sync (we register it)
    .v_sync     (vsync_int),   // Internal vertical sync (we register it)
    .pixel_x    (pixel_x),     // Column of the current VGA pixel (10 bits)
    .pixel_y    (pixel_y),     // Row of the current VGA pixel (10 bits)
    .last_column(last_column), // Current pixel_x is the last visible column
    .last_row   (last_row),    // Current pixel_y is the last visible row
    .blank      (blank)        // Blank (true during blanking intervals)
);

assign char_write_value = char_value;

//CHARACTER GENERATOR
char_gen #(
    .FILENAME(FILENAME)
)char_gen_inst (
    .clk        (clk),        // 100MHz Clock
    .char_we    (char_we),    // Character write enable
    .char_addr  (char_addr),  // 12-bit write address
    .char_value (char_value), // 7-bit character value to write
    .pixel_x    (pixel_x),    // 10-bit column address
    .pixel_y    (pixel_y[8:0]),    // 9-bit row address
    .pixel_out  (pixel_out)   // output pixel
);

// UART

rx #(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD_RATE(BAUD_RATE)
)rx_inst (
    .clk         (clk),        // Clock
    .rst         (btnd_rr),    // System reset active high
    .Sin         (rx_in_rr),   // Receiver serial input signal
    .ReceiveAck  (ack),        // Indicates host has read Dout (we tie ack = rx_received)
    .Receive     (rx_received),// Byte available flag
    .Dout        (Dout),       // Received 8-bit data
    .parityErr   ()            // Parity error indicator
);



// Debouncer
debounce #(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .WAIT_TIME_US(WAIT_TIME_US)
)debounce_inst (
    .clk        (clk),        // Clock
    .rst        (btnd_rr),    // Active-high synchronous reset
    .noisy      (btnc),    // Noisy input to debounce
    .debounced  (debounced)   // Debounced output
);


// Character write logic
assign ack = rx_received;
assign ack_asserted = rx_received;            // Detect rising edge of ack
assign char_we = btnc_pressed || ack_asserted;  // Write to character memory on btnc press or when a byte is received over UART
assign char_value = ack_asserted ? Dout[6:0] : sw_r[6:0]; // Character value comes from UART data or switches

// Character address logic (fixed syntax + correct wrap behavior)
always_ff @(posedge clk) begin
    if (btnd_rr) begin
        char_addr <= 12'b0;
    end else if (char_we) begin
        // column < 79 -> increment column
        if (char_addr[6:0] < 7'd79) begin
            char_addr <= { char_addr[11:7], char_addr[6:0] + 7'd1 };
        end else begin
            // column == 79
            if (char_addr[11:7] == 5'd29) begin
                // last row, wrap to top-left
                char_addr <= 12'b0;
            end else begin
                // wrap column to 0 and increment row
                char_addr <= { char_addr[11:7] + 5'd1, 7'd0 };
            end
        end
    end
end


// combinational decision for immediate RGB (stage0)
always_comb begin
    if (blank) begin
        rgb_stage0 = 12'h000;              // black during blank
    end else begin
        rgb_stage0 = (pixel_out) ? fg_color : bg_color;
    end
end

// Synchronize RGB output to VGA timing (use your existing 3-stage pipeline regs)
always_ff @(posedge clk) begin
    {vgaRed, vgaGreen, vgaBlue} <= rgb_rrr;
end


// Synchronize Hsync and Vsync to VGA output timing (use your existing 3-stage sync regs)
always_ff @(posedge clk) begin
    Hsync <= hsync_rrr;
end

always_ff @(posedge clk) begin
    Vsync <= vsync_rrr;
end


endmodule