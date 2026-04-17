module audio_reverb_top (
    input  logic       clk,
    input  logic       btnc,
    input  logic [0:0] sw,

    output logic       jc1_dac_mclk,
    output logic       jc2_dac_lrck,
    output logic       jc3_dac_sclk,
    output logic       jc4_dac_sdin,

    output logic       jc7_adc_mclk,
    output logic       jc8_adc_lrck,
    output logic       jc9_adc_sclk,
    input  logic       jc10_adc_sdout
);

    logic signed [23:0] left_sample;
    logic signed [23:0] right_sample;
    logic sample_strobe;

    logic signed [23:0] left_proc;
    logic signed [23:0] right_proc;

    i2s2_adc_receiver i2s2_adc_receiver_inst (
        .clk(clk),
        .rst(btnc),
        .adc_mclk(jc7_adc_mclk),
        .adc_lrck(jc8_adc_lrck),
        .adc_sclk(jc9_adc_sclk),
        .adc_sdout(jc10_adc_sdout),
        .left_sample(left_sample),
        .right_sample(right_sample),
        .sample_strobe(sample_strobe)
    );

    // Reuse ADC-generated clocks for DAC interface.
    assign jc1_dac_mclk = jc7_adc_mclk;
    assign jc2_dac_lrck = jc8_adc_lrck;
    assign jc3_dac_sclk = jc9_adc_sclk;

    audio_echo audio_echo_inst (
        .clk(clk),
        .rst(btnc),
        .sample_strobe(sample_strobe),
        .effect_en(sw[0]),
        .left_in(left_sample),
        .right_in(right_sample),
        .left_out(left_proc),
        .right_out(right_proc)
    );

    i2s2_dac_transmitter i2s2_dac_transmitter_inst (
        .clk(clk),
        .rst(btnc),
        .dac_sclk(jc3_dac_sclk),
        .left_sample_in(left_proc),
        .right_sample_in(right_proc),
        .sample_strobe(sample_strobe),
        .dac_sdin(jc4_dac_sdin)
    );

endmodule
