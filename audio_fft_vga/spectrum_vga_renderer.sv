module spectrum_vga_renderer #(
    parameter int N_BINS       = 16,
    parameter int BAR_HEIGHT_W = 8,
    parameter int BAR_W        = 40,
    parameter int GRAPH_TOP    = 20,
    parameter int GRAPH_HEIGHT = 220
) (
    input  logic [9:0]                               pixel_x,
    input  logic [9:0]                               pixel_y,
    input  logic                                     blank,
    input  logic [N_BINS-1:0][BAR_HEIGHT_W-1:0]      bar_heights,

    output logic [3:0]                               red,
    output logic [3:0]                               green,
    output logic [3:0]                               blue
);
    localparam int GRAPH_BASE = GRAPH_TOP + GRAPH_HEIGHT;

    logic [4:0] bar_idx;
    logic [7:0] bar_height;
    logic [9:0] bar_top;
    logic in_graph_x;
    logic in_bar;
    logic in_grid;

    always_comb begin
        in_graph_x = (pixel_x < (N_BINS * BAR_W));
        bar_idx = pixel_x / BAR_W;

        if (bar_idx < N_BINS) bar_height = bar_heights[bar_idx];
        else bar_height = '0;

        if (bar_height > GRAPH_HEIGHT[7:0]) bar_top = GRAPH_TOP;
        else bar_top = GRAPH_BASE - bar_height;

        in_bar = in_graph_x && (pixel_y >= bar_top) && (pixel_y <= GRAPH_BASE);
        in_grid = in_graph_x && (pixel_y >= GRAPH_TOP) && (pixel_y <= GRAPH_BASE) && (pixel_y[4:0] == 5'd0);

        red = 4'h0;
        green = 4'h0;
        blue = 4'h0;

        if (!blank) begin
            if (in_bar) begin
                if (bar_height < 8'd60) begin
                    red = 4'h0; green = 4'hA; blue = 4'h3;
                end else if (bar_height < 8'd140) begin
                    red = 4'hC; green = 4'hB; blue = 4'h2;
                end else begin
                    red = 4'hF; green = 4'h3; blue = 4'h2;
                end
            end else if (in_grid) begin
                red = 4'h1; green = 4'h1; blue = 4'h3;
            end
        end
    end
endmodule
