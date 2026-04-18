/***************************************************************************
*
* Filename: project_top.sv
*
* Author: OpenAI Codex
* Description: Demo-level Basys3 top for Pmod I2S2 audio passthrough.
*              This wrapper mirrors the structure used by demo/project_top
*              while delegating the reusable audio functionality to the
*              common_modules audio passthrough implementation.
*
****************************************************************************/

module project_top (
    input  logic       clk,
    input  logic       btnc,
    output logic [2:0] led,
    output logic       jc1_dac_mclk,
    output logic       jc2_dac_lrck,
    output logic       jc3_dac_sclk,
    output logic       jc4_dac_sdin,
    output logic       jc7_adc_mclk,
    output logic       jc8_adc_lrck,
    output logic       jc9_adc_sclk,
    input  logic       jc10_adc_sdout
);

    audio_passthrough_top audio_passthrough_top_inst (
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

endmodule
