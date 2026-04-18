/***************************************************************************
*
* Filename: i2s_tx.sv
*
* Author: OpenAI Codex
* Description: Serializes stereo samples onto an I2S data output.
*
****************************************************************************/

module i2s_tx #(
    parameter integer SAMPLE_WIDTH = 16
)(
    input  logic                           clk,
    input  logic                           rst,
    input  logic                           sclk_fall,
    input  logic                           lrck,
    input  logic                           lrck_edge,
    input  logic signed [SAMPLE_WIDTH-1:0] left_sample,
    input  logic signed [SAMPLE_WIDTH-1:0] right_sample,
    input  logic                           sample_valid,
    output logic                           sample_ready,
    output logic                           sdata
);

logic signed [SAMPLE_WIDTH-1:0] frame_left;
logic signed [SAMPLE_WIDTH-1:0] frame_right;
logic signed [SAMPLE_WIDTH-1:0] shift_reg;
logic [$clog2(SAMPLE_WIDTH+1)-1:0] bit_index;
logic                              wait_for_msb;
logic                              pending_valid;
logic signed [SAMPLE_WIDTH-1:0]    pending_left;
logic signed [SAMPLE_WIDTH-1:0]    pending_right;

assign sample_ready = !pending_valid;

always_ff @(posedge clk) begin
    if (rst) begin
        frame_left    <= '0;
        frame_right   <= '0;
        shift_reg     <= '0;
        bit_index     <= '0;
        wait_for_msb  <= 1'b0;
        pending_valid <= 1'b0;
        pending_left  <= '0;
        pending_right <= '0;
        sdata         <= 1'b0;
    end else begin
        if (sample_valid && sample_ready) begin
            pending_left  <= left_sample;
            pending_right <= right_sample;
            pending_valid <= 1'b1;
        end

        if (lrck_edge) begin
            if (!lrck && pending_valid) begin
                frame_left    <= pending_left;
                frame_right   <= pending_right;
                pending_valid <= 1'b0;
            end

            if (lrck) begin
                shift_reg <= frame_right;
            end else begin
                shift_reg <= pending_valid ? pending_left : frame_left;
            end

            bit_index    <= SAMPLE_WIDTH - 1;
            wait_for_msb <= 1'b1;
            sdata        <= 1'b0;
        end

        if (sclk_fall) begin
            if (wait_for_msb) begin
                sdata <= shift_reg[SAMPLE_WIDTH-1];
                if (SAMPLE_WIDTH > 1) begin
                    bit_index <= SAMPLE_WIDTH - 2;
                end
                wait_for_msb <= 1'b0;
            end else if (bit_index < SAMPLE_WIDTH) begin
                sdata <= shift_reg[bit_index];
                if (bit_index == 0) begin
                    bit_index <= SAMPLE_WIDTH;
                end else begin
                    bit_index <= bit_index - 1'b1;
                end
            end else begin
                sdata <= 1'b0;
            end
        end
    end
end

endmodule
