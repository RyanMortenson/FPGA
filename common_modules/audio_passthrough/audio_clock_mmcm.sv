/***************************************************************************
*
* Filename: audio_clock_mmcm.sv
*
* Author: OpenAI Codex
* Description: Generates the audio fabric/master clock used by the Pmod I2S2
*              interface. This mirrors Digilent's working demo strategy by
*              creating an approximately 22.59 MHz clock from the Basys3
*              100 MHz oscillator.
*
****************************************************************************/

module audio_clock_mmcm (
    input  logic clk_in,
    output logic audio_clk,
    output logic locked
);

`ifdef SYNTHESIS
logic clk_fb;
logic clk_fb_buf;
logic audio_clk_mmcm;

MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT4_CASCADE("FALSE"),
    .COMPENSATION("ZHOLD"),
    .STARTUP_WAIT("FALSE"),
    .DIVCLK_DIVIDE(6),
    .CLKFBOUT_MULT_F(48.625),
    .CLKFBOUT_PHASE(0.0),
    .CLKFBOUT_USE_FINE_PS("FALSE"),
    .CLKOUT0_DIVIDE_F(35.875),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_USE_FINE_PS("FALSE"),
    .CLKIN1_PERIOD(10.0)
) u_mmcm (
    .CLKFBOUT(clk_fb),
    .CLKFBOUTB(),
    .CLKOUT0(audio_clk_mmcm),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBIN(clk_fb_buf),
    .CLKIN1(clk_in),
    .CLKIN2(1'b0),
    .CLKINSEL(1'b1),
    .DADDR(7'h0),
    .DCLK(1'b0),
    .DEN(1'b0),
    .DI(16'h0),
    .DO(),
    .DRDY(),
    .DWE(1'b0),
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSDONE(),
    .LOCKED(locked),
    .CLKINSTOPPED(),
    .CLKFBSTOPPED(),
    .PWRDWN(1'b0),
    .RST(1'b0)
);

BUFG u_clkfb_buf (
    .I(clk_fb),
    .O(clk_fb_buf)
);

BUFG u_audio_buf (
    .I(audio_clk_mmcm),
    .O(audio_clk)
);
`else
initial begin
    locked = 1'b0;
    #100ns;
    locked = 1'b1;
end

initial begin
    audio_clk = 1'b0;
    forever #22.13ns audio_clk = ~audio_clk;
end
`endif

endmodule
