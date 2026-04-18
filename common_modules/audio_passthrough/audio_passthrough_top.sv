/***************************************************************************
*
* Filename: audio_passthrough_top.sv
*
* Author: OpenAI Codex
* Description: Basys3 top level for the Digilent Pmod I2S2 audio passthrough.
*
****************************************************************************/

module audio_passthrough_top #(
    parameter integer SAMPLE_WIDTH = 24
)(
    input  logic clk,
    input  logic btnc,
    output logic [2:0] led,
    output logic jc1_dac_mclk,
    output logic jc2_dac_lrck,
    output logic jc3_dac_sclk,
    output logic jc4_dac_sdin,
    output logic jc7_adc_mclk,
    output logic jc8_adc_lrck,
    output logic jc9_adc_sclk,
    input  logic jc10_adc_sdout
);

logic rst;
logic audio_clk;
logic audio_clk_locked;
logic signed [SAMPLE_WIDTH-1:0] rx_left_sample;
logic signed [SAMPLE_WIDTH-1:0] rx_right_sample;
logic                           rx_sample_valid;
logic signed [SAMPLE_WIDTH-1:0] tx_left_sample;
logic signed [SAMPLE_WIDTH-1:0] tx_right_sample;
logic                           tx_sample_valid;
logic                           tx_sample_ready;
logic [20:0]                    rx_activity_counter;
logic                           rx_nonzero_seen;

reset_sync u_reset_sync(
    .clk(audio_clk),
    .rst_in(btnc || !audio_clk_locked),
    .rst_out(rst)
);

audio_clock_mmcm u_audio_clock_mmcm (
    .clk_in(clk),
    .audio_clk(audio_clk),
    .locked(audio_clk_locked)
);

pmod_i2s2_engine #(
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
) u_pmod_i2s2_engine (
    .audio_clk(audio_clk),
    .rst(rst),
    .tx_left_sample(tx_left_sample),
    .tx_right_sample(tx_right_sample),
    .rx_left_sample(rx_left_sample),
    .rx_right_sample(rx_right_sample),
    .rx_sample_valid(rx_sample_valid),
    .tx_mclk(jc1_dac_mclk),
    .tx_lrck(jc2_dac_lrck),
    .tx_sclk(jc3_dac_sclk),
    .tx_sdout(jc4_dac_sdin),
    .rx_mclk(jc7_adc_mclk),
    .rx_lrck(jc8_adc_lrck),
    .rx_sclk(jc9_adc_sclk),
    .rx_sdin(jc10_adc_sdout)
);

audio_passthrough_core #(
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
) u_audio_passthrough_core (
    .clk(audio_clk),
    .rst(rst),
    .rx_left_sample(rx_left_sample),
    .rx_right_sample(rx_right_sample),
    .rx_sample_valid(rx_sample_valid),
    .tx_left_sample(tx_left_sample),
    .tx_right_sample(tx_right_sample),
    .tx_sample_valid(tx_sample_valid),
    .tx_sample_ready(tx_sample_ready)
);

assign tx_sample_ready = 1'b1;

always_ff @(posedge audio_clk or posedge rst) begin
    if (rst) begin
        rx_activity_counter <= '0;
        rx_nonzero_seen <= 1'b0;
    end else begin
        if (rx_sample_valid) begin
            rx_activity_counter <= {21{1'b1}};
            if (rx_left_sample != '0 || rx_right_sample != '0) begin
                rx_nonzero_seen <= 1'b1;
            end
        end else if (rx_activity_counter != '0) begin
            rx_activity_counter <= rx_activity_counter - 1'b1;
        end
    end
end

// LED meanings:
// led[0] is forced on to confirm the programmed bitstream is alive.
// led[1] lights solid when the MMCM audio clock is locked.
// led[2] lights when RX audio activity has been seen recently or when a
// non-zero sample has been captured at least once.
assign led[0] = 1'b1;
assign led[1] = audio_clk_locked;
assign led[2] = (rx_activity_counter != '0) || rx_nonzero_seen;

endmodule
