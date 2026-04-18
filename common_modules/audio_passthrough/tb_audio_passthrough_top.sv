module tb_audio_passthrough_top;

logic clk;
logic btnc;
logic [2:0] led;
logic jc1_dac_mclk;
logic jc2_dac_lrck;
logic jc3_dac_sclk;
logic jc4_dac_sdin;
logic jc7_adc_mclk;
logic jc8_adc_lrck;
logic jc9_adc_sclk;
logic jc10_adc_sdout;
int errors;

audio_passthrough_top dut (
    .clk(clk),
    .btnc(btnc),
    .led(led),
    .jc1_dac_mclk(jc1_dac_mclk),
    .jc2_dac_lrck(jc2_dac_lrck),
    .jc3_dac_sclk(jc3_dac_sclk),
    .jc4_dac_sdin(jc4_dac_sdin),
    .jc7_adc_mclk(jc7_adc_mclk),
    .jc8_adc_lrck(jc8_adc_lrck),
    .jc9_adc_sclk(jc9_adc_sclk),
    .jc10_adc_sdout(jc10_adc_sdout)
);

initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
end

initial begin
    errors = 0;
    btnc = 1'b1;
    jc10_adc_sdout = 1'b0;

    repeat (20) @(posedge clk);
    btnc = 1'b0;

    repeat (4000) @(posedge clk);

    if (!led[1]) begin
        $display("*** ERROR: MMCM never reported lock on led[1]");
        errors += 1;
    end

    if (jc1_dac_mclk !== jc7_adc_mclk) begin
        $display("*** ERROR: ADC and DAC MCLK should match");
        errors += 1;
    end
    if (jc2_dac_lrck !== jc8_adc_lrck) begin
        $display("*** ERROR: ADC and DAC LRCK should match");
        errors += 1;
    end
    if (jc3_dac_sclk !== jc9_adc_sclk) begin
        $display("*** ERROR: ADC and DAC SCLK should match");
        errors += 1;
    end

    if ((jc1_dac_mclk === 1'bx) || (jc2_dac_lrck === 1'bx) || (jc3_dac_sclk === 1'bx)) begin
        $display("*** ERROR: generated clocks should not stay unknown");
        errors += 1;
    end

    if (errors == 0) begin
        $display("*** tb_audio_passthrough_top PASSED ***");
    end else begin
        $display("*** tb_audio_passthrough_top FAILED with %0d errors ***", errors);
    end
    $finish;
end

endmodule
