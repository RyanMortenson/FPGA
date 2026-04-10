/***************************************************************************
* 
* Filename: vga_top.sv
*
* Author: Ryan Mortenson
* Description: contains the logic for generating the pixel colors on the VGA display
*
****************************************************************************/

module vga_top (
        input logic         clk,        //100 MHz Clock signal
        input logic         btnd,       //Asynchronous reset
        input logic         btnc,       //Display color from switches
        input logic         btnl,       //Display White
        input logic         btnr,       //Display Black
        input logic  [11:0] sw,         //Switches to determine color to display
        output logic        Hsync,      //Horizontal synchronization signal
        output logic        Vsync,      //Vertical synchronization signal
        output logic [3:0]  vgaRed,     //Red color signal
        output logic [3:0]  vgaGreen,   //Green color signal
        output logic [3:0]  vgaBlue     //Blue color signal
    );

//internal signals
logic blank;
logic [3:0] red_disp, green_disp, blue_disp;
logic [9:0] pixel_x, pixel_y;

//instantiation of vga_timing module
vga_timing vga_u (
    .clk(clk),
    .rst(btnd), 
    .h_sync(Hsync),  
    .v_sync(Vsync),  
    .pixel_x(pixel_x), 
    .pixel_y(pixel_y), 
    .last_column(), //not connected
    .last_row(),    //not connected
    .blank(blank)
);

// RED
always_comb begin
    red_disp = 4'h0;

    if (blank || btnr) begin
        red_disp = 4'h0;
    end else if (btnl) begin
        red_disp = 4'hF;
    end else if (btnc) begin
        red_disp = sw[11:8];
    end else begin
        // 8 bars, 80 pixels each
        if      (pixel_x < 10'd80)  red_disp = 4'h0; // Black
        else if (pixel_x < 10'd160) red_disp = 4'h0; // Blue
        else if (pixel_x < 10'd240) red_disp = 4'h0; // Green
        else if (pixel_x < 10'd320) red_disp = 4'h0; // Cyan
        else if (pixel_x < 10'd400) red_disp = 4'hF; // Red
        else if (pixel_x < 10'd480) red_disp = 4'hF; // Magenta
        else if (pixel_x < 10'd560) red_disp = 4'hF; // Yellow
        else if (pixel_x < 10'd640) red_disp = 4'hF; // White
        else                        red_disp = 4'h0; // (outside visible)
    end
end

// GREEN
always_comb begin
    green_disp = 4'h0;

    if (blank || btnr) begin
        green_disp = 4'h0;
    end else if (btnl) begin
        green_disp = 4'hF;
    end else if (btnc) begin
        green_disp = sw[7:4];
    end else begin
        if      (pixel_x < 10'd80)  green_disp = 4'h0; // Black
        else if (pixel_x < 10'd160) green_disp = 4'h0; // Blue
        else if (pixel_x < 10'd240) green_disp = 4'hF; // Green
        else if (pixel_x < 10'd320) green_disp = 4'hF; // Cyan
        else if (pixel_x < 10'd400) green_disp = 4'h0; // Red
        else if (pixel_x < 10'd480) green_disp = 4'h0; // Magenta
        else if (pixel_x < 10'd560) green_disp = 4'hF; // Yellow
        else if (pixel_x < 10'd640) green_disp = 4'hF; // White
        else                        green_disp = 4'h0;
    end
end

// BLUE
always_comb begin
    blue_disp = 4'h0;

    if (blank || btnr) begin
        blue_disp = 4'h0;
    end else if (btnl) begin
        blue_disp = 4'hF;
    end else if (btnc) begin
        blue_disp = sw[3:0];
    end else begin
        if      (pixel_x < 10'd80)  blue_disp = 4'h0; // Black
        else if (pixel_x < 10'd160) blue_disp = 4'hF; // Blue
        else if (pixel_x < 10'd240) blue_disp = 4'h0; // Green
        else if (pixel_x < 10'd320) blue_disp = 4'hF; // Cyan
        else if (pixel_x < 10'd400) blue_disp = 4'h0; // Red
        else if (pixel_x < 10'd480) blue_disp = 4'hF; // Magenta
        else if (pixel_x < 10'd560) blue_disp = 4'h0; // Yellow
        else if (pixel_x < 10'd640) blue_disp = 4'hF; // White
        else                        blue_disp = 4'h0;
    end
end

assign vgaRed   = red_disp;
assign vgaGreen = green_disp;
assign vgaBlue  = blue_disp;


endmodule