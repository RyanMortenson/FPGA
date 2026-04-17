# audio_fft_vga

Real-time audio frequency-response display for **Basys3 + Digilent Pmod I2S2**.

This project captures audio from the Pmod I2S2 ADC interface on the Basys3 **JC** header, renders a continuously updating spectrum graph on VGA, and routes captured audio to the DAC line-out path for near-real-time passthrough.

## Architecture overview

The design is split into six hardware blocks:

1. **`i2s2_adc_receiver.sv`**
   - Generates the ADC-side I2S clocks (`MCLK`, `LRCK`, `SCLK`) from Basys3 100 MHz.
   - Captures `SDOUT` samples from the Pmod I2S2.
   - Produces signed left/right 24-bit samples and a `sample_strobe` once per stereo frame.

2. **`goertzel_spectrum.sv`**
   - Implements a practical resource-aware spectrum engine using a **Goertzel filter bank** (32 bins).
   - Processes a 256-sample analysis window.
   - Uses a synthesizable **log-like magnitude mapping** for display values.

3. **`spectrum_vga_renderer.sv`**
   - Converts bar heights into a 32-bar VGA graph.
   - Uses height-based color thresholds to reduce constant warm-color saturation.

4. **`audio_echo_reverb.sv`**
   - Optional lightweight feedback-delay effect for audio output.
   - Disabled by default, so dry passthrough remains the normal path.

5. **`i2s2_dac_transmitter.sv`**
   - Serializes stereo samples to DAC `SDIN` in I2S format.
   - Uses the shared ADC-generated I2S clocks.

6. **`audio_fft_vga_top.sv`**
   - Top-level Basys3 integration.
   - Connects capture -> analyzer -> VGA and capture/effect -> DAC output.

## Audio capture + passthrough details (Pmod I2S2)

Assumptions used here:

- Board: **Basys3**
- Audio PMOD: **Digilent Pmod I2S2**
- Plugged directly into **JC** in standard orientation
- `JP1 = SLV` on Pmod I2S2

Implemented clock plan from 100 MHz:

- `MCLK = 4.000 MHz`
- `SCLK = 1.000 MHz`
- `LRCK = SCLK / 64 = 15.625 kHz`

Effective stereo sampling rate is ~15.625 kS/s. The analyzer uses a mono mix of left/right channels, while passthrough/effect keeps stereo output.

Passthrough note:

- Output is frame-synchronous with captured samples and intentionally simple/stable.
- This is a practical low-latency implementation, not a full codec feature-complete audio pipeline.

## JC pin mapping used

### ADC / Line-In side
- `JC7  = A/D MCLK  = L17` (`jc7_adc_mclk`)
- `JC8  = A/D LRCK  = M19` (`jc8_adc_lrck`)
- `JC9  = A/D SCLK  = P17` (`jc9_adc_sclk`)
- `JC10 = A/D SDOUT = R18` (`jc10_adc_sdout`)

### DAC / Line-Out side
- `JC1  = D/A MCLK  = K17` (`jc1_dac_mclk`)
- `JC2  = D/A LRCK  = M18` (`jc2_dac_lrck`)
- `JC3  = D/A SCLK  = N17` (`jc3_dac_sclk`)
- `JC4  = D/A SDIN  = P18` (`jc4_dac_sdin`)

## Logarithmic spectrum mapping and sensitivity behavior

`goertzel_spectrum.sv` computes Goertzel power (`mag_sq`) and then applies a synthesizable log approximation:

1. Find the highest-set bit of `mag_sq` (integer log2 estimate).
2. Capture the next 4 lower bits as a fractional term.
3. Build `log_mag = (msb_index * 4) + frac`.

This yields a practical log-like magnitude response without expensive true log hardware and improves weak-signal visibility.

To reduce saturation, the display pipeline also applies:

- Input down-scaling
- Floor subtraction
- Base attenuation + switch-selectable sensitivity attenuation
- Fast-attack / slow-decay smoothing
- Height-based color thresholds

## Basys3 controls (SW0..SW8)

- `SW[3:0]` = `noise_floor_ctrl`
  - Higher value suppresses low-level background noise.

- `SW[5:4]` = `sensitivity_ctrl`
  - `00`: highest sensitivity.
  - `11`: lowest sensitivity.

- `SW[7:6]` = `color_scale_ctrl`
  - Raises low/mid color thresholds so warm colors require stronger peaks.

- `SW[8]` = `reverb_en`
  - `0`: dry passthrough (default).
  - `1`: enable lightweight echo/reverb approximation.

## Optional reverb / echo effect (lightweight approximation)

`audio_echo_reverb.sv` implements a conservative feedback-delay effect:

- Delay depth: 2048 samples/channel (`~131 ms` at 15.625 kHz).
- Output mix: `wet = x + 0.25 * delayed_sample`.
- Feedback write: `delay_next = x + 0.5 * delayed_sample`.
- Saturation is applied to avoid signed wraparound.

Limitations:

- Fixed delay length unless RTL parameter is changed.
- This is a simple comb/echo style effect, not studio-quality reverb.
- Uses additional BRAM resources for delay storage.

## Build and program

From repo root:

```bash
make synth MOD=audio_fft_vga
make implement MOD=audio_fft_vga
make download MOD=audio_fft_vga
```

## Hardware bring-up checklist

1. Verify Pmod I2S2 is on **JC** with correct orientation.
2. Verify `JP1` is set to **SLV**.
3. Connect VGA monitor (640x480@60).
4. Connect line-in source and line-out monitor/speakers.
5. Program the bitstream, then press `BTNC`.
6. Tune `SW0..SW7` for desired display behavior.
7. Toggle `SW8` for dry vs. echo/reverb output.
