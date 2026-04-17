# audio_fft_vga

Real-time audio frequency-response display for **Basys3 + Digilent Pmod I2S2**.

This project captures audio from the Pmod I2S2 ADC interface on the Basys3 **JC** header and renders a continuously updating spectrum graph on VGA.

## Architecture overview

The design is split into four hardware blocks:

1. **`i2s2_adc_receiver.sv`**
   - Generates the ADC-side I2S clocks (`MCLK`, `LRCK`, `SCLK`) from Basys3 100 MHz.
   - Captures `SDOUT` samples from the Pmod I2S2.
   - Produces signed left/right 24-bit samples and a `sample_strobe` once per stereo frame.

2. **`goertzel_spectrum.sv`**
   - Implements a practical resource-aware spectrum engine using a **Goertzel filter bank** (32 bins).
   - Processes a 256-sample analysis window.
   - Computes one magnitude value per bin and converts it into an 8-bit bar height.

3. **`spectrum_vga_renderer.sv`**
   - Converts bar heights into a 32-bar VGA graph.
   - Draws low/mid/high bands with different colors plus horizontal grid lines.

4. **`audio_fft_vga_top.sv`**
   - Top-level Basys3 integration.
   - Reuses repo VGA timing helper (`common_modules/video_signal/vga_timing/vga_timing.sv`).
   - Connects I2S capture -> spectral analysis -> VGA renderer.

## Audio capture details (Pmod I2S2)

Assumptions used here:

- Board: **Basys3**
- Audio PMOD: **Digilent Pmod I2S2**
- Plugged directly into **JC** in standard orientation
- `JP1 = SLV` on Pmod I2S2
- Design captures ADC/line-in path (`SDOUT`)

Implemented clock plan from 100 MHz:

- `MCLK = 4.000 MHz`
- `SCLK = 1.000 MHz`
- `LRCK = SCLK / 64 = 15.625 kHz`

So effective sampling is ~15.625 kS/s stereo frame rate. The analyzer uses a mono mix of left/right channels.

## JC pin mapping used

Exact mapping from request:

### ADC / Line-In side
- `JC7  = A/D MCLK  = L17` (`jc7_adc_mclk`)
- `JC8  = A/D LRCK  = M19` (`jc8_adc_lrck`)
- `JC9  = A/D SCLK  = P17` (`jc9_adc_sclk`)
- `JC10 = A/D SDOUT = R18` (`jc10_adc_sdout`)

### Optional DAC / Line-Out side
- `JC1  = D/A MCLK  = K17` (`jc1_dac_mclk`)
- `JC2  = D/A LRCK  = M18` (`jc2_dac_lrck`)
- `JC3  = D/A SCLK  = N17` (`jc3_dac_sclk`)
- `JC4  = D/A SDIN  = P18` (`jc4_dac_sdin`)

DAC outputs are currently driven idle (playback is optional in this project).

## Spectrum method and tradeoffs

A full pipelined FFT is possible but relatively heavy/complex for a simple, maintainable Basys3 repo project. This implementation uses a **Goertzel bank** as a realistic alternative:

- 32 frequency bins
- 256-sample window
- Shared sequential arithmetic at 100 MHz (resource-conscious)
- Periodic magnitude update suitable for real-time display

Tradeoff summary:

- **Pros**: significantly lower implementation complexity than a full FFT IP flow, easy to synthesize and inspect, good real-time visualization.
- **Cons**: discrete chosen bins (not every FFT bin), update cadence tied to analysis window, magnitude scaling is approximate/compressed for display.

## Build and program (repo workflow)

From repo root:

```bash
make synth MOD=audio_fft_vga
make implement MOD=audio_fft_vga
make download MOD=audio_fft_vga
```

The project uses the standard repository flow:

- `Makefile` defines `REPO_PATH`, `MODULE_NAME`, `SV_FILES`
- Includes `$(REPO_PATH)/resources/common.mk`

## Hardware bring-up checklist

Before programming:

1. Verify Pmod I2S2 is on **JC** with correct orientation.
2. Verify `JP1` is set to **SLV**.
3. Connect a VGA monitor that supports 640x480@60 timing.
4. Provide an audio source into the Pmod I2S2 line-in path.
5. Press `BTNC` after configuration to reset/restart the pipeline.

If the graph does not move:

- Re-check JC pin orientation.
- Probe `JC7/JC9/JC8` for MCLK/SCLK/LRCK activity.
- Confirm input source level (line-level vs mic-level path).
