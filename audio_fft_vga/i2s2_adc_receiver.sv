/***************************************************************************
*
* Filename: i2s2_adc_receiver.sv
*
* Description: Generates I2S clocks for the Pmod I2S2 (ADC path) and
* captures left/right audio samples from ADC SDOUT.
*
****************************************************************************/

module i2s2_adc_receiver #(
    parameter int SAMPLE_BITS = 24
) (
    input  logic                        clk,
    input  logic                        rst,

    // Pmod I2S2 ADC-side pins (JC7..JC10 mapping)
    output logic                        adc_mclk,
    output logic                        adc_lrck,
    output logic                        adc_sclk,
    input  logic                        adc_sdout,

    output logic signed [SAMPLE_BITS-1:0] left_sample,
    output logic signed [SAMPLE_BITS-1:0] right_sample,
    output logic                        sample_strobe
);

    // 100 MHz / 25 = 4 MHz MCLK
    // SCLK = MCLK / 4 = 1 MHz
    // LRCK = SCLK / 64 = 15.625 kHz
    logic [4:0] mclk_div;
    logic [1:0] sclk_div;
    logic [5:0] bit_count;

    logic adc_sclk_q;
    logic adc_lrck_q;

    logic [SAMPLE_BITS-1:0] shift_reg;
    logic [4:0]             data_bit_count;

    always_ff @(posedge clk) begin
        if (rst) begin
            mclk_div      <= '0;
            sclk_div      <= '0;
            adc_mclk      <= 1'b0;
            adc_sclk      <= 1'b0;
            adc_lrck      <= 1'b0;
            adc_sclk_q    <= 1'b0;
            adc_lrck_q    <= 1'b0;
            bit_count     <= '0;
            shift_reg     <= '0;
            data_bit_count <= '0;
            left_sample   <= '0;
            right_sample  <= '0;
            sample_strobe <= 1'b0;
        end else begin
            sample_strobe <= 1'b0;

            // Generate 4 MHz MCLK
            if (mclk_div == 5'd24) begin
                mclk_div <= '0;
                adc_mclk <= ~adc_mclk;
            end else begin
                mclk_div <= mclk_div + 1'b1;
            end

            // Divide MCLK by 4 to generate SCLK
            if (mclk_div == 5'd24) begin
                if (sclk_div == 2'd3) begin
                    sclk_div <= '0;
                    adc_sclk <= ~adc_sclk;
                end else begin
                    sclk_div <= sclk_div + 1'b1;
                end
            end

            adc_sclk_q <= adc_sclk;
            adc_lrck_q <= adc_lrck;

            // Operate shift logic on SCLK rising edges.
            if (!adc_sclk_q && adc_sclk) begin
                if (bit_count == 6'd63) begin
                    bit_count <= '0;
                end else begin
                    bit_count <= bit_count + 1'b1;
                end

                // 32 SCLK cycles per channel
                adc_lrck <= (bit_count >= 6'd31);

                // I2S data has one-bit delay after LRCK transition.
                if (bit_count == 6'd0 || bit_count == 6'd32) begin
                    data_bit_count <= '0;
                end else if (data_bit_count < SAMPLE_BITS) begin
                    shift_reg <= {shift_reg[SAMPLE_BITS-2:0], adc_sdout};
                    data_bit_count <= data_bit_count + 1'b1;

                    if (data_bit_count == SAMPLE_BITS-1) begin
                        if (!adc_lrck) begin
                            left_sample <= {shift_reg[SAMPLE_BITS-2:0], adc_sdout};
                        end else begin
                            right_sample <= {shift_reg[SAMPLE_BITS-2:0], adc_sdout};
                            sample_strobe <= 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule
