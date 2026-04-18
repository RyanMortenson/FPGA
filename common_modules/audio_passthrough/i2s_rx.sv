/***************************************************************************
*
* Filename: i2s_rx.sv
*
* Author: OpenAI Codex
* Description: Reconstructs stereo I2S samples from a serial data stream.
*
****************************************************************************/

module i2s_rx #(
    parameter integer SAMPLE_WIDTH = 16
)(
    input  logic                           clk,
    input  logic                           rst,
    input  logic                           sclk_rise,
    input  logic                           lrck,
    input  logic                           lrck_edge,
    input  logic                           sdata,
    output logic signed [SAMPLE_WIDTH-1:0] left_sample,
    output logic signed [SAMPLE_WIDTH-1:0] right_sample,
    output logic                           sample_valid
);

logic [$clog2(SAMPLE_WIDTH+1)-1:0] bit_count;
logic                              capture_enable;
logic                              channel_is_right;
logic signed [SAMPLE_WIDTH-1:0]    shift_reg;

always_ff @(posedge clk) begin
    if (rst) begin
        bit_count        <= '0;
        capture_enable   <= 1'b0;
        channel_is_right <= 1'b0;
        shift_reg        <= '0;
        left_sample      <= '0;
        right_sample     <= '0;
        sample_valid     <= 1'b0;
    end else begin
        sample_valid <= 1'b0;

        if (lrck_edge) begin
            capture_enable   <= 1'b0;
            bit_count        <= SAMPLE_WIDTH;
            channel_is_right <= lrck;
        end

        if (sclk_rise) begin
            if (!capture_enable) begin
                capture_enable <= 1'b1;
            end else if (bit_count != 0) begin
                shift_reg <= {shift_reg[SAMPLE_WIDTH-2:0], sdata};

                if (bit_count == 1) begin
                    if (channel_is_right) begin
                        right_sample <= {shift_reg[SAMPLE_WIDTH-2:0], sdata};
                        sample_valid <= 1'b1;
                    end else begin
                        left_sample <= {shift_reg[SAMPLE_WIDTH-2:0], sdata};
                    end
                    capture_enable <= 1'b0;
                end

                bit_count <= bit_count - 1'b1;
            end
        end
    end
end

endmodule
