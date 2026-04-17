/***************************************************************************
*
* Filename: i2s2_dac_transmitter.sv
*
* Description: I2S DAC transmitter for Pmod I2S2 line-out path.
* Uses externally supplied LRCK/SCLK clocks and serializes
* left/right 24-bit samples using I2S framing.
*
****************************************************************************/

module i2s2_dac_transmitter #(
    parameter int SAMPLE_BITS = 24
) (
    input  logic                           clk,
    input  logic                           rst,

    input  logic                           dac_sclk,

    input  logic signed [SAMPLE_BITS-1:0]  left_sample_in,
    input  logic signed [SAMPLE_BITS-1:0]  right_sample_in,
    input  logic                           sample_strobe,

    output logic                           dac_sdin
);

    logic dac_sclk_q;
    logic [5:0] bit_count;

    logic signed [SAMPLE_BITS-1:0] left_latched;
    logic signed [SAMPLE_BITS-1:0] right_latched;

    logic [SAMPLE_BITS-1:0] left_shift;
    logic [SAMPLE_BITS-1:0] right_shift;

    always_ff @(posedge clk) begin
        if (rst) begin
            dac_sclk_q    <= 1'b0;
            bit_count     <= '0;
            left_latched  <= '0;
            right_latched <= '0;
            left_shift    <= '0;
            right_shift   <= '0;
            dac_sdin      <= 1'b0;
        end else begin
            if (sample_strobe) begin
                // Update source samples once per full stereo frame.
                left_latched  <= left_sample_in;
                right_latched <= right_sample_in;
            end

            dac_sclk_q <= dac_sclk;

            // Shift on falling edge so data is stable before next rising edge.
            if (dac_sclk_q && !dac_sclk) begin
                if (bit_count == 6'd63) begin
                    bit_count <= '0;
                end else begin
                    bit_count <= bit_count + 1'b1;
                end

                // Left channel frame.
                if (bit_count == 6'd0) begin
                    left_shift <= left_latched;
                    dac_sdin   <= 1'b0; // I2S one-bit delay slot
                end else if (bit_count >= 6'd1 && bit_count <= 6'd24) begin
                    dac_sdin   <= left_shift[SAMPLE_BITS-1];
                    left_shift <= {left_shift[SAMPLE_BITS-2:0], 1'b0};
                end else if (bit_count < 6'd32) begin
                    dac_sdin <= 1'b0;
                end

                // Right channel frame.
                if (bit_count == 6'd32) begin
                    right_shift <= right_latched;
                    dac_sdin    <= 1'b0; // I2S one-bit delay slot
                end else if (bit_count >= 6'd33 && bit_count <= 6'd56) begin
                    dac_sdin    <= right_shift[SAMPLE_BITS-1];
                    right_shift <= {right_shift[SAMPLE_BITS-2:0], 1'b0};
                end else if (bit_count > 6'd56) begin
                    dac_sdin <= 1'b0;
                end
            end
        end
    end

endmodule
