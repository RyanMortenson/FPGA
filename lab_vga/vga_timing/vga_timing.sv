/***************************************************************************
* 
* Filename: vga_timing.sv
*
* Author: Ryan Mortenson
* Description: contains the timing generator for your VGA controller
*
****************************************************************************/

module vga_timing (
        input logic         clk,  //100 MHz Clock signal
        input logic         rst,  //Synchronous reset
        output logic        h_sync,  //Low asserted horizontal sync VGA signal
        output logic        v_sync,  //Low asserted vertical sync VGA signal
        output logic [9:0]  pixel_x, //Column of the current VGA pixel
        output logic [9:0]  pixel_y, //Row of the current VGA pixel
        output logic        last_column, //The current pixel_x correspond to the last visible column
        output logic        last_row, //The current pixel_y corresponds to the last visible row
        output logic        blank  //The current pixel is part of a horizontal or vertical retrace and that the output color must be blanked.
    );

//internal signals and stuff
localparam COUNTER_WIDTH = $clog2(4); //Divisor 100/4 =  25
logic [COUNTER_WIDTH-1:0] pixel_clk_counter;
logic pixel_en;

//counter to 4
always_ff @(posedge clk) begin
    if (rst) begin pixel_clk_counter <= '0;
    end else begin
        if (pixel_clk_counter == 3) begin
            pixel_clk_counter <= 0;
        end else begin
            pixel_clk_counter <= pixel_clk_counter + 1;
        end
    end

end


//3 off 1 on
always_ff @(posedge clk) begin
    if (rst) pixel_en <= 0;
    else
        pixel_en <= (pixel_clk_counter == '0);

end


//counter 0 to 799 for pixel_x
always_ff @(posedge clk) begin
    if (rst) begin pixel_x <= '0;
    end else begin
        if (pixel_en) begin
            if (pixel_x == 799) begin
                pixel_x <= 0;
            end else begin
                pixel_x <= pixel_x + 1;
            end
        end
    end

end


//counter 0 to 520 for pixel_y
always_ff @(posedge clk) begin
    if (rst) begin pixel_y <= '0;
    end else begin
        if (pixel_en && pixel_x == 799) begin
            if (pixel_y == 520) begin
                pixel_y <= 0;
            end else begin
                pixel_y <= pixel_y + 1;
            end
        end
    end

end

//comb block for last colomn for x
always_comb begin
    last_column = 0;
    if (pixel_x == 639) last_column = 1;
end


//comb block for last row for y
always_comb begin
    last_row = 0;
    if (pixel_y == 479) last_row = 1;
end


//combinational logic to generate the h_sync and v_sync signals based on the current values of the pixel_x and pixel_y counters.
//h_sync
always_comb begin
    h_sync = 1;
    if (pixel_x >= 656 && pixel_x <= 751) h_sync = 0;
end


//v_sync
always_comb begin
    v_sync = 1;
    if (pixel_y >= 490 && pixel_y <= 491) v_sync = 0;
end

//blank
always_comb begin
    blank = 0;
    if ((pixel_x >= 640 && pixel_x <= 799) || (pixel_y >= 480 && pixel_y <= 520)) blank = 1;
end

endmodule