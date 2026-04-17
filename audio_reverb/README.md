# audio_reverb

Basys3 real-time audio passthrough with optional echo effect for Digilent Pmod I2S2 on header **JC**.

This project is intentionally separate from VGA/FFT logic to keep implementation small and practical for Basys3.

## What this project does

- Captures stereo audio from Pmod I2S2 ADC side.
- Outputs stereo audio to Pmod I2S2 DAC side.
- Dry passthrough is the default path.
- Optional single-switch echo effect uses a conservative feedback delay line.

## Basys3 controls

- `SW[0]`: echo enable
  - `0` = dry passthrough (default)
  - `1` = enable echo/reverb-like feedback delay
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

DAC / Line-Out
- `JC1  = D/A MCLK  = K17`
- `JC2  = D/A LRCK  = M18`
- `JC3  = D/A SCLK  = N17`
- `JC4  = D/A SDIN  = P18`

## Architecture notes

- Clocks are generated once in the ADC receiver and reused by the DAC transmitter.
- Echo depth is `2^10 = 1024` samples (~65 ms at 15.625 kHz frame rate).
- Mix is conservative (`dry + 0.25*delay`, feedback `dry + 0.5*delay`) with saturation.

## Build

From repo root:

```bash
make synth MOD=audio_reverb
make implement MOD=audio_reverb
make download MOD=audio_reverb
```
