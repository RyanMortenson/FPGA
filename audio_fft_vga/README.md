# audio_fft_vga

Basys3 real-time audio spectrum display for Digilent Pmod I2S2 on header **JC**.

This project is intentionally separated from audio output/reverb processing to reduce implementation cost and fit comfortably on Artix-7 (Basys3).

## What this project does

- Captures stereo audio from Pmod I2S2 ADC side.
- Mixes to mono for analysis only.
- Runs a **small 16-bin Goertzel filter-bank** (128-sample window).
- Applies log-like magnitude mapping.
- Applies switch-tunable noise floor / sensitivity.
- Renders bars on VGA using repository `vga_timing` helper.

No DAC output, passthrough, or reverb logic is included in this project.

## Basys3 controls

- `SW[3:0]`: noise-floor threshold (higher = suppresses background more)
- `SW[5:4]`: sensitivity attenuation (higher = less sensitive)
- `BTNC`: reset

## Hardware assumptions

- Board: Digilent Basys3
- PMOD: Digilent Pmod I2S2
- Header: JC, standard orientation
- Pmod `JP1 = SLV`

JC mapping used:

ADC / Line-In
- `JC7  = A/D MCLK  = L17`
- `JC8  = A/D LRCK  = M19`
- `JC9  = A/D SCLK  = P17`
- `JC10 = A/D SDOUT = R18`

(Only ADC pins are used by this project.)

## Build

From repo root:

```bash
make synth MOD=audio_fft_vga
make implement MOD=audio_fft_vga
make download MOD=audio_fft_vga
```
