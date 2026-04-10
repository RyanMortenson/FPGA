/***************************************************************************
* 
* Filename: project_top.sv
*
* Author: Ryan Mortenson
* Description: project top module (pong)
*
****************************************************************************/

module project_top (
    input  logic        clk,
    input  logic        btnc,
    input  logic        btnd,
    input  logic        btnl,
    input  logic        btnr,
    input  logic        btnu,
    output logic        Hsync,
    output logic        Vsync,
    output logic [3:0]  vgaRed,
    output logic [3:0]  vgaGreen,
    output logic [3:0]  vgaBlue,
    output logic [3:0]  anode,
    output logic [7:0]  segment
);

    logic game_enable;

    // Internal signals
    logic [9:0] pixel_x;
    logic [9:0] pixel_y;
    logic       last_column;
    logic       last_row;
    logic       blank;
    logic [3:0] score_left, score_right;

    // Bitmap memory write-side muxed signals
    logic [8:0] wr_x;
    logic [7:0] wr_y;
    logic [2:0] wr_color;
    logic       wr_en;

    // Screen clear signals
    logic       clearing;
    logic [8:0] clear_x;
    logic [7:0] clear_y;

    // Pong write-side signals
    logic [8:0] vga_x;
    logic [7:0] vga_y;
    logic [2:0] vga_color;
    logic       vga_wr_en;

    // Bitmap memory read-side signals
    logic [3:0] mem_red;
    logic [3:0] mem_green;
    logic [3:0] mem_blue;

    // Seven-segment packed display data
    logic [15:0] seg_data;

    assign seg_data = {score_left, 4'd0, 4'd0, score_right}; // Display scores on the middle two digits

    // VGA TIMING
    vga_timing vga_timing_inst (
        .clk(clk),
        .rst(btnc),
        .h_sync(Hsync),
        .v_sync(Vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .last_column(last_column),
        .last_row(last_row),
        .blank(blank)
    );

    // PONG
    pong pong_inst (
        .clk(clk),
        .reset(btnc | clearing),
        .paddle_up_l(btnl),
        .paddle_down_l(btnd),
        .paddle_up_r(btnu),
        .paddle_down_r(btnr),
        .vga_x(vga_x),
        .vga_y(vga_y),
        .vga_color(vga_color),
        .vga_wr_en(vga_wr_en),
        .score_left(score_left),
        .score_right(score_right)
    );

    // BITMAP MEMORY
    bitmap_mem bitmap_mem_inst (
        .clk(clk),
        .rd_x_vga(pixel_x),
        .rd_y_vga(pixel_y[8:0]),
        .rd_data_r(mem_red),
        .rd_data_g(mem_green),
        .rd_data_b(mem_blue),
        .wr_x_qvga(wr_x),
        .wr_y_qvga(wr_y),
        .wr_color(wr_color),
        .wr_en(wr_en)
    );

    // VGA COLOR LOGIC
    always_comb begin
        if (blank) begin
            vgaRed   = 4'h0;
            vgaGreen = 4'h0;
            vgaBlue  = 4'h0;
        end else begin
            vgaRed   = mem_red;
            vgaGreen = mem_green;
            vgaBlue  = mem_blue;
        end
    end

    // SEVEN-SEGMENT DISPLAY
    seven_segment4 seven_segment4_inst (
        .clk(clk),
        .rst(btnc),
        .data_in(seg_data),
        .dp_in(4'b0100),
        .blank(4'b0110),   // blank outer digits, show middle two
        .segment(segment),
        .anode(anode)
    );

    // Screen clear logic
    always_ff @(posedge clk) begin
        if (btnc) begin
            clearing <= 1'b1;
            clear_x  <= 9'd0;
            clear_y  <= 8'd0;
        end else if (clearing) begin
            if (clear_x == 9'd319) begin
                clear_x <= 9'd0;
                if (clear_y == 8'd239) begin
                    clear_y  <= 8'd0;
                    clearing <= 1'b0;
                end else begin
                    clear_y <= clear_y + 1'b1;
                end
            end else begin
                clear_x <= clear_x + 1'b1;
            end
        end else begin
            clearing <= 1'b0;
            clear_x  <= clear_x;
            clear_y  <= clear_y;
        end
    end

    // Write mux: clear screen first, otherwise let pong draw
    always_comb begin
        if (clearing) begin
            wr_x     = clear_x;
            wr_y     = clear_y;
            wr_color = 3'b000;
            wr_en    = 1'b1;
        end else begin
            wr_x     = vga_x;
            wr_y     = vga_y;
            wr_color = vga_color;
            wr_en    = vga_wr_en;
        end
    end

endmodule