module audio_fft_vga_top (
    input  logic       clk,
    input  logic       btnc,
    input  logic [5:0] sw,

    output logic       Hsync,
    output logic       Vsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,

    output logic       jc7_adc_mclk,
    output logic       jc8_adc_lrck,
    output logic       jc9_adc_sclk,
    input  logic       jc10_adc_sdout
);

    logic blank;
    logic [9:0] pixel_x;
    logic [9:0] pixel_y;

    logic signed [23:0] left_sample;
    logic signed [23:0] right_sample;
    logic signed [23:0] mono_sample;
    logic sample_strobe;

    logic [15:0][7:0] bar_heights;

    assign mono_sample = (left_sample >>> 1) + (right_sample >>> 1);

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

    mini_spectrum_analyzer mini_spectrum_analyzer_inst (
        .clk(clk),
        .rst(btnc),
        .sample_strobe(sample_strobe),
        .sample_in(mono_sample),
        .noise_floor_ctrl(sw[3:0]),
        .sensitivity_ctrl(sw[5:4]),
        .bar_heights(bar_heights)
    );

    spectrum_vga_renderer spectrum_vga_renderer_inst (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .blank(blank),
        .bar_heights(bar_heights),
        .red(vgaRed),
        .green(vgaGreen),
        .blue(vgaBlue)
    );

endmodule
