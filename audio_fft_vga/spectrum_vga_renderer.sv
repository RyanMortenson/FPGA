/***************************************************************************
*
* Filename: spectrum_vga_renderer.sv
*
* Description: Draws a simple spectrum display using bar heights.
*
****************************************************************************/

module spectrum_vga_renderer #(
    parameter int N_BINS       = 32,
    parameter int BAR_HEIGHT_W = 8
) (
    input  logic [9:0]                               pixel_x,
    input  logic [9:0]                               pixel_y,
    input  logic                                     blank,
    input  logic [N_BINS-1:0][BAR_HEIGHT_W-1:0]      bar_heights,

    output logic [3:0]                               red,
    output logic [3:0]                               green,
    output logic [3:0]                               blue
);

    localparam int BAR_W      = 20;
    localparam int GRAPH_TOP  = 16;
    localparam int GRAPH_BASE = 16 + 239;

    logic [5:0] bar_idx;
    logic [7:0] bar_height;
    logic [9:0] bar_top;
    logic in_graph_x;
    logic in_bar;
    logic grid_line;

    always_comb begin
        in_graph_x = (pixel_x < N_BINS*BAR_W);
        bar_idx    = pixel_x / BAR_W;

        if (bar_idx < N_BINS) begin
            bar_height = bar_heights[bar_idx];
        end else begin
            bar_height = '0;
        end

        if (bar_height > 8'd239) begin
            bar_top = GRAPH_TOP;
        end else begin
            bar_top = GRAPH_BASE - bar_height;
        end

        in_bar = in_graph_x && (pixel_y >= bar_top) && (pixel_y <= GRAPH_BASE);

        grid_line = ((pixel_y >= GRAPH_TOP) && (pixel_y <= GRAPH_BASE) && (pixel_y[4:0] == 5'd0));

        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;

        if (!blank) begin
            if (in_bar) begin
                if (bar_idx < 10) begin
                    red = 4'h2;
                    green = 4'hF;
                    blue = 4'h2;
                end else if (bar_idx < 22) begin
                    red = 4'hE;
                    green = 4'hD;
                    blue = 4'h2;
                end else begin
                    red = 4'hF;
                    green = 4'h3;
                    blue = 4'h2;
                end
            end else if (grid_line && in_graph_x) begin
                red = 4'h1;
                green = 4'h1;
                blue = 4'h3;
            end else if (pixel_y == GRAPH_BASE + 1 && in_graph_x) begin
                red = 4'h4;
                green = 4'h4;
                blue = 4'h6;
            end
        end
    end

endmodule
