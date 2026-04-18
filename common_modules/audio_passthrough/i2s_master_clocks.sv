/***************************************************************************
*
* Filename: i2s_master_clocks.sv
*
* Author: OpenAI Codex
* Description: Generates synchronous master, bit, and left/right clocks for
*              a simple I2S master sourced from the Basys3 100 MHz clock.
*
****************************************************************************/

module i2s_master_clocks #(
    parameter integer MCLK_DIV = 8,
    parameter integer SCLK_DIV = 64,
    parameter integer LRCK_DIV = 2048
)(
    input  logic clk,
    input  logic rst,
    output logic mclk,
    output logic sclk,
    output logic lrck,
    output logic sclk_rise,
    output logic sclk_fall,
    output logic lrck_edge
);

localparam integer MCLK_HALF_DIV = MCLK_DIV / 2;
localparam integer SCLK_HALF_DIV = SCLK_DIV / 2;
localparam integer LRCK_HALF_DIV = LRCK_DIV / 2;
localparam integer MCLK_COUNT_W = (MCLK_HALF_DIV > 1) ? $clog2(MCLK_HALF_DIV) : 1;
localparam integer SCLK_COUNT_W = (SCLK_HALF_DIV > 1) ? $clog2(SCLK_HALF_DIV) : 1;
localparam integer LRCK_COUNT_W = (LRCK_HALF_DIV > 1) ? $clog2(LRCK_HALF_DIV) : 1;

logic [MCLK_COUNT_W-1:0] mclk_count;
logic [SCLK_COUNT_W-1:0] sclk_count;
logic [LRCK_COUNT_W-1:0] lrck_count;

always_ff @(posedge clk) begin
    if (rst) begin
        mclk       <= 1'b0;
        sclk       <= 1'b1;
        lrck       <= 1'b0;
        sclk_rise  <= 1'b0;
        sclk_fall  <= 1'b0;
        lrck_edge  <= 1'b0;
        mclk_count <= 0;
        sclk_count <= 0;
        lrck_count <= 0;
    end else begin
        sclk_rise <= 1'b0;
        sclk_fall <= 1'b0;
        lrck_edge <= 1'b0;

        if (mclk_count == MCLK_HALF_DIV - 1) begin
            mclk_count <= 0;
            mclk <= ~mclk;
        end else begin
            mclk_count <= mclk_count + 1;
        end

        if (sclk_count == SCLK_HALF_DIV - 1) begin
            sclk_count <= 0;
            sclk <= ~sclk;
            if (sclk) begin
                sclk_fall <= 1'b1;
            end else begin
                sclk_rise <= 1'b1;
            end
        end else begin
            sclk_count <= sclk_count + 1;
        end

        if (lrck_count == LRCK_HALF_DIV - 1) begin
            lrck_count <= 0;
            lrck <= ~lrck;
            lrck_edge <= 1'b1;
        end else begin
            lrck_count <= lrck_count + 1;
        end
    end
end

endmodule
