/***************************************************************************
*
* Filename: pmod_i2s2_engine.sv
*
* Author: OpenAI Codex
* Description: Proven Pmod I2S2 line-in/line-out engine adapted from the
*              Digilent reference design for a Basys3 top-level passthrough.
*              The engine generates the clocks required to keep the ADC and
*              DAC on the Pmod I2S2 in slave mode and exposes one stereo
*              sample per frame to the surrounding datapath.
*
****************************************************************************/

module pmod_i2s2_engine #(
    parameter integer SAMPLE_WIDTH = 24,
    parameter integer EOF_COUNT = 9'd455
)(
    input  logic                           audio_clk,
    input  logic                           rst,
    input  logic signed [SAMPLE_WIDTH-1:0] tx_left_sample,
    input  logic signed [SAMPLE_WIDTH-1:0] tx_right_sample,
    output logic signed [SAMPLE_WIDTH-1:0] rx_left_sample,
    output logic signed [SAMPLE_WIDTH-1:0] rx_right_sample,
    output logic                           rx_sample_valid,
    output logic                           tx_mclk,
    output logic                           tx_lrck,
    output logic                           tx_sclk,
    output logic                           tx_sdout,
    output logic                           rx_mclk,
    output logic                           rx_lrck,
    output logic                           rx_sclk,
    input  logic                           rx_sdin
);

localparam logic [4:0] SAMPLE_WIDTH_5 = SAMPLE_WIDTH[4:0];

logic [8:0] count;
logic       lrck;
logic       sclk;
logic [2:0] din_sync_shift;
logic       din_sync;
logic signed [SAMPLE_WIDTH-1:0] tx_left_shift;
logic signed [SAMPLE_WIDTH-1:0] tx_right_shift;
logic signed [SAMPLE_WIDTH-1:0] rx_left_shift;
logic signed [SAMPLE_WIDTH-1:0] rx_right_shift;

assign lrck = count[8];
assign sclk = count[2];

assign tx_mclk = audio_clk;
assign tx_lrck = lrck;
assign tx_sclk = sclk;
assign rx_mclk = audio_clk;
assign rx_lrck = lrck;
assign rx_sclk = sclk;

assign din_sync = din_sync_shift[2];

always_ff @(posedge audio_clk) begin
    if (rst) begin
        count           <= 9'd0;
        din_sync_shift  <= 3'd0;
        tx_left_shift   <= '0;
        tx_right_shift  <= '0;
        rx_left_shift   <= '0;
        rx_right_shift  <= '0;
        rx_left_sample  <= '0;
        rx_right_sample <= '0;
        rx_sample_valid <= 1'b0;
    end else begin
        count <= count + 1'b1;
        din_sync_shift <= {din_sync_shift[1:0], rx_sdin};
        rx_sample_valid <= 1'b0;

        if (count == 9'b000000111) begin
            tx_left_shift  <= tx_left_sample;
            tx_right_shift <= tx_right_sample;
        end else if (count[2:0] == 3'b111 && count[7:3] >= 5'd1 && count[7:3] <= SAMPLE_WIDTH_5) begin
            if (count[8]) begin
                tx_right_shift <= {tx_right_shift[SAMPLE_WIDTH-2:0], 1'b0};
            end else begin
                tx_left_shift <= {tx_left_shift[SAMPLE_WIDTH-2:0], 1'b0};
            end
        end

        if (count[2:0] == 3'b011 && count[7:3] >= 5'd1 && count[7:3] <= SAMPLE_WIDTH_5) begin
            if (lrck) begin
                rx_right_shift <= {rx_right_shift[SAMPLE_WIDTH-2:0], din_sync};
            end else begin
                rx_left_shift <= {rx_left_shift[SAMPLE_WIDTH-2:0], din_sync};
            end
        end

        if (count == EOF_COUNT) begin
            rx_left_sample  <= rx_left_shift;
            rx_right_sample <= rx_right_shift;
            rx_sample_valid <= 1'b1;
        end
    end
end

always_comb begin
    tx_sdout = 1'b0;
    if (count[7:3] >= 5'd1 && count[7:3] <= SAMPLE_WIDTH_5) begin
        if (count[8]) begin
            tx_sdout = tx_right_shift[SAMPLE_WIDTH-1];
        end else begin
            tx_sdout = tx_left_shift[SAMPLE_WIDTH-1];
        end
    end
end

endmodule
