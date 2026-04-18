/***************************************************************************
*
* Filename: audio_passthrough_core.sv
*
* Author: OpenAI Codex
* Description: One-sample stereo bridge between I2S receive and transmit
*              paths. Future audio processing blocks should be inserted here.
*
****************************************************************************/

module audio_passthrough_core #(
    parameter integer SAMPLE_WIDTH = 16
)(
    input  logic                           clk,
    input  logic                           rst,
    input  logic signed [SAMPLE_WIDTH-1:0] rx_left_sample,
    input  logic signed [SAMPLE_WIDTH-1:0] rx_right_sample,
    input  logic                           rx_sample_valid,
    output logic signed [SAMPLE_WIDTH-1:0] tx_left_sample,
    output logic signed [SAMPLE_WIDTH-1:0] tx_right_sample,
    output logic                           tx_sample_valid,
    input  logic                           tx_sample_ready
);

logic signed [SAMPLE_WIDTH-1:0] buffered_left;
logic signed [SAMPLE_WIDTH-1:0] buffered_right;
logic                           buffer_valid;

assign tx_left_sample  = buffered_left;
assign tx_right_sample = buffered_right;
assign tx_sample_valid = buffer_valid;

always_ff @(posedge clk) begin
    if (rst) begin
        buffered_left  <= '0;
        buffered_right <= '0;
        buffer_valid   <= 1'b0;
    end else begin
        // For direct passthrough we want the most recently received stereo
        // sample pair to stay stable until a newer pair arrives. This keeps
        // the TX side driven for the full next frame instead of only for one
        // fabric clock after RX completion.
        if (rx_sample_valid) begin
            buffered_left  <= rx_left_sample;
            buffered_right <= rx_right_sample;
            buffer_valid   <= 1'b1;
        end
    end
end

endmodule
