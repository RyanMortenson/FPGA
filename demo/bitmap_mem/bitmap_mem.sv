/***************************************************************************
*
* Module: bitmap_mem
*
* Author: Jeff Goeders
* Date: March 23, 2026
*
* Description: Stores a 320x240 bitmap (QVGA), which can be read using 
                VGA timing.
*
****************************************************************************/

module bitmap_mem (
    input logic         clk,

    input logic [9:0]   rd_x_vga,
    input logic [8:0]   rd_y_vga,
    output logic [3:0]  rd_data_r,
    output logic [3:0]  rd_data_g,
    output logic [3:0]  rd_data_b,
    
    input logic [8:0]   wr_x_qvga,
    input logic [7:0]   wr_y_qvga,
    input logic [2:0]   wr_color,
    input logic         wr_en

);

reg     [2:0]   ram [122879:0];  // 512x240

logic rd_data_r1, rd_data_g1, rd_data_b1;

// Read port
always_ff @(posedge clk) begin
    rd_data_r1 <= ram[{rd_y_vga[8:1], rd_x_vga[9:1]}][2];
    rd_data_g1 <= ram[{rd_y_vga[8:1], rd_x_vga[9:1]}][1];
    rd_data_b1 <= ram[{rd_y_vga[8:1], rd_x_vga[9:1]}][0];
end

assign rd_data_r = {4{rd_data_r1}};
assign rd_data_g = {4{rd_data_g1}};
assign rd_data_b = {4{rd_data_b1}};

// Write port 
always_ff @(posedge clk) begin
    if (wr_en) begin
        ram[{wr_y_qvga, wr_x_qvga}] <= wr_color;
    end
end

endmodule