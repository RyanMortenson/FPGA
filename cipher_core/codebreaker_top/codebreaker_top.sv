/***************************************************************************
* 
* Filename: codebreaker_top.sv
*
* Author: Ryan Mortenson
* Description: code breaker module
*
****************************************************************************/

module codebreaker_top #(
    parameter FILENAME = "",	// Specifies the filename of the initial contents of character memory
    parameter CLK_FREQUENCY = 100_000_000, // Specifies the frequency of the clock in Hz
    parameter BAUD_RATE = 19_200, // Determines the baud rate of the receiver
    parameter WAIT_TIME_US = 5_000, // Determines the wait time, in micro seconds, for the debounce circuit
    parameter REFRESH_RATE = 200, // Specifies the display refresh rate in Hz
    parameter FOREGROUND_COLOR = 12'hfff, // Specifies the default foreground color
    parameter BACKGROUND_COLOR = 12'h000 // Specifies the default background color
)(
    input logic         clk,        // 100MHz Clock
    input logic         btnd,      // Reset
    input logic         btnc,      // Start codebreaker
    input logic         rx_in,     // UART Receiver Input
    output logic [15:0]  led,        // Display upper 16 bits of key
    output logic       Hsync,      // Horizontal synchronization signal
    output logic       Vsync,      // Vertical synchronization signal
    output logic [3:0] vgaRed,     // Red color signal
    output logic [3:0] vgaGreen,   // Green color signal
    output logic [3:0] vgaBlue,    // Blue color signal
    output logic [3:0] anode,      // Anode signals for each of
    output logic [7:0] segment      // Cathode signals for seven-segment display
);


// Intermediate signals
logic hsync_int, vsync_int;
logic rx_in_r, btnc_r, hsync_r, vsync_r, btnd_r, vgaRed_r, vgaGreen_r, vgaBlue_r;
logic rx_in_rr, btnc_rr, hsync_rr, vsync_rr, btnd_rr;
logic hsync_rrr, vsync_rrr;
logic ack, rx_received, btnc_pressed, blank;
logic [23:0] key; // 24-bit key output from codebreaker (upper 16 bits displayed on LEDs)
// in the signal declaration, and when the reset signal is asserted. Note: although initializing signals at declaration is generally prohibited (see coding standard rule S12), this lab explicitly allows initializing ciphertext at signal declaration as described above.
logic [127:0] ciphertext = 128'h7d1fd1e0e0b4eeeba6d6d91e2c05d5cb;
logic [127:0] plaintext; // Output plaintext from decrypt_rc4
logic [9:0] pixel_x;
logic [8:0] pixel_y;
logic last_column, last_row, char_we, pixel_out;
logic [11:0] char_addr;
logic [6:0] char_value; // aka char_data
logic done, error; // Output signals from codebreaker indicating whether the codebreaking process is done and whether it resulted in an error (no match found)
logic [7:0] Dout; // Output from UART receiver

// ff's for synchronizing inputs/outputs
//rx_in_r
always_ff @(posedge clk) begin
    rx_in_r <= rx_in;
end
//rx_in_rr
always_ff @(posedge clk) begin
    rx_in_rr <= rx_in_r;
end
//btnc_r
always_ff @(posedge clk) begin
    btnc_r <= btnc;
end
//btnc_rr
always_ff @(posedge clk) begin
    btnc_rr <= btnc_r;
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
//Hsync output
always_ff @(posedge clk) begin
    Hsync <= hsync_rrr;
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
//Vsync output
always_ff @(posedge clk) begin
    Vsync <= vsync_rrr;
end
//btnd_r
always_ff @(posedge clk) begin
    btnd_r <= btnd;
end
//btnd_rr
always_ff @(posedge clk) begin
    btnd_rr <= btnd_r;
end
//vgaRed_r
always_ff @(posedge clk) begin
    vgaRed <= vgaRed_r;
end
//vgaGreen_r
always_ff @(posedge clk) begin
    vgaGreen <= vgaGreen_r;
end
//vgaBlue_r
always_ff @(posedge clk) begin
    vgaBlue <= vgaBlue_r;
end


// Character write logic
assign ack = rx_received;

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


// set ciphertext on reset and shift in new bytes from UART
always_ff @(posedge clk) begin
    if (btnd_rr) begin
        ciphertext <= 128'h7d1fd1e0e0b4eeeba6d6d91e2c05d5cb; // Reset to initial value on reset
    end else if (rx_received) begin
        ciphertext <= {ciphertext[119:0], Dout}; // Shift in new byte from UART
    end
end


// Instantiate the codebreaker module
codebreaker codebreaker_inst(
    .clk(clk),              // 100MHz Clock
    .reset(btnd_rr),          // Active high reset signal
    .start(btnc_rr),          // Set high to start running the codebreaker
    .done(done),            // High when the key search completes (on success or error). Stays high until reset or starting a new search
    .error(error),          // Indicates the previous codebreak resulted in no match. Stays high until reset or starting a new search
    .key(key),              // Encryption key [23:0] - upper 16 bits displayed on LEDs
    .bytes_in(ciphertext),    // input bytes (cipher text) [127:0]
    .bytes_out(plaintext)   // output bytes (plain text)
);

// Display upper 16 bits of key on LEDs
assign led = key[23:8]; // Display upper 16 bits of key on LEDs


// VGA TIMING
vga_timing vga_timing_inst (
    .clk        (clk),         // 100 MHz Clock signal
    .rst        (btnd_rr),     // Synchronous reset
    .h_sync     (hsync_int),   // Internal horizontal sync (we register it)
    .v_sync     (vsync_int),   // Internal vertical sync (we register it)
    .pixel_x    (pixel_x),     // Column of the current VGA pixel (10 bits)
    .pixel_y    (pixel_y),     // Row of the current VGA pixel (9 bits)
    .last_column(last_column), // Current pixel_x is the last visible column
    .last_row   (last_row),    // Current pixel_y is the last visible row
    .blank      (blank)        // Blank (true during blanking intervals)
);


// WRITE VGA
write_vga write_vga_inst(
    .clk(clk),
    .rst(btnd_rr),
    .write_display(last_column && last_row), // Write to display at the end of each frame
    .ciphertext(ciphertext), // 128-bit ciphertext to display
    .plaintext(plaintext),  // 128-bit plaintext to display
    .key(key),     // 24-bit key to display (only lower 6 nibbles will be displayed)
    .char_addr(char_addr), // The write address of the character memory (12 bits)
    .char_data(char_value),   // The 7-bit value to pad and write into the character memory (7 bits)
    .write_char(char_we)       // Character write enable
);



// CHAR GEN
char_gen #(
    .FILENAME(FILENAME)
)
char_gen_inst(
    .clk(clk),        // 100MHz Clock
    .char_we(char_we),    // Character write enable
    .char_addr(char_addr),  // The write address of the character memory (12 bits)
    .char_value(char_value), // The 7-bit value to pad and write into the character memory (7 bits)
    .pixel_x(pixel_x),    // The column address of the current pixel (10 bits)
    .pixel_y(pixel_y),    // The row address of the current pixel    (9 bits)
    .pixel_out(pixel_out)   // The value of the character output pixel (1 bit)
);


// VGA COLOR LOGIC
// red
always_comb begin
    if (blank) begin
        vgaRed_r = 4'h0;
    end else if (pixel_out) begin
        vgaRed_r = FOREGROUND_COLOR[11:8];
    end else begin
        vgaRed_r = BACKGROUND_COLOR[11:8];
    end
end

// green
always_comb begin
    if (blank) begin
        vgaGreen_r = 4'h0;
    end else if (pixel_out) begin
        vgaGreen_r = FOREGROUND_COLOR[7:4];
    end else begin
        vgaGreen_r = BACKGROUND_COLOR[7:4];
    end
end

// blue
always_comb begin
    if (blank) begin
        vgaBlue_r = 4'h0;
    end else if (pixel_out) begin
        vgaBlue_r = FOREGROUND_COLOR[3:0];
    end else begin
        vgaBlue_r = BACKGROUND_COLOR[3:0];
    end
end



// SEVEN-SEGMENT DISPLAY
seven_segment4 seven_segment4_inst (
    .clk(clk),
    .rst(btnd_rr),
    .data_in((!done) ? 16'h0000 : (!error) ? 16'hC0DE : 16'hDEAD), // Display "CODE" if done without error, "DEAD" if done with error, and blank if not done
    .dp_in(4'b0000), // no decimal points
    .blank((!done) ? 4'b1111 : 4'b0000), // display the right three digits and blank the leftmost digit
    .segment(segment),
    .anode(anode)
);




endmodule