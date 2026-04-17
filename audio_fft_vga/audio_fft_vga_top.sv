/***************************************************************************
*
* Filename: audio_fft_vga_top.sv
*
* Description: Basys3 + Pmod I2S2 real-time audio spectrum over VGA.
*
****************************************************************************/

module audio_fft_vga_top (
    input  logic        clk,
    input  logic        btnc,
    input  logic [8:0]  sw,

    output logic        Hsync,
    output logic        Vsync,
    output logic [3:0]  vgaRed,
    output logic [3:0]  vgaGreen,
    output logic [3:0]  vgaBlue,

    // JC1..JC4 DAC side
    output logic        jc1_dac_mclk,
    output logic        jc2_dac_lrck,
    output logic        jc3_dac_sclk,
    output logic        jc4_dac_sdin,

    // JC7..JC10 ADC side
    output logic        jc7_adc_mclk,
    output logic        jc8_adc_lrck,
    output logic        jc9_adc_sclk,
    input  logic        jc10_adc_sdout
);

    logic blank;
    logic [9:0] pixel_x;
    logic [9:0] pixel_y;

    logic signed [23:0] left_sample;
    logic signed [23:0] right_sample;
    logic sample_strobe;
    logic signed [23:0] mono_sample;
    logic signed [23:0] left_out_sample;
    logic signed [23:0] right_out_sample;

    logic [31:0][7:0] bar_heights;
    logic bars_valid;

    logic [3:0] red_pix;
    logic [3:0] green_pix;
    logic [3:0] blue_pix;

    assign mono_sample = (left_sample >>> 1) + (right_sample >>> 1);

    // Reused VGA timing helper from common_modules.
    vga_timing vga_timing_inst (
        .clk(clk),
        .rst(btnc),
        .h_sync(Hsync),
        .v_sync(Vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .last_column(),
        .last_row(),
        .blank(blank)
    );

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

    goertzel_spectrum goertzel_spectrum_inst (
        .clk(clk),
        .rst(btnc),
        .sample_strobe(sample_strobe),
        .sample_in(mono_sample),
        .noise_floor_ctrl(sw[3:0]),
        .sensitivity_ctrl(sw[5:4]),
        .bar_heights(bar_heights),
        .bars_valid(bars_valid)
    );

    spectrum_vga_renderer spectrum_vga_renderer_inst (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .blank(blank),
        .bar_heights(bar_heights),
        .color_scale_ctrl(sw[7:6]),
        .red(red_pix),
        .green(green_pix),
        .blue(blue_pix)
    );

    // DAC line-out passthrough uses the same I2S clocks as ADC capture.
    assign jc1_dac_mclk = jc7_adc_mclk;
    assign jc2_dac_lrck = jc8_adc_lrck;
    assign jc3_dac_sclk = jc9_adc_sclk;

    audio_echo_reverb audio_echo_reverb_inst (
        .clk(clk),
        .rst(btnc),
        .sample_strobe(sample_strobe),
        .reverb_en(sw[8]),
        .left_in(left_sample),
        .right_in(right_sample),
        .left_out(left_out_sample),
        .right_out(right_out_sample)
    );

    i2s2_dac_transmitter i2s2_dac_transmitter_inst (
        .clk(clk),
        .rst(btnc),
        .dac_sclk(jc3_dac_sclk),
        .left_sample_in(left_out_sample),
        .right_sample_in(right_out_sample),
        .sample_strobe(sample_strobe),
        .dac_sdin(jc4_dac_sdin)
    );

    assign vgaRed   = red_pix;
    assign vgaGreen = green_pix;
    assign vgaBlue  = blue_pix;

endmodule
