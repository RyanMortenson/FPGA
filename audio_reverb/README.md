# audio_reverb

Basys3 real-time audio passthrough with an intentionally lightweight optional echo effect for Digilent Pmod I2S2 on header **JC**.

This project is intentionally separate from VGA/FFT logic to keep implementation small and practical for Basys3.

## Why this version exists

The earlier reverb/echo approach could overuse Basys3 slice/register resources when synthesized with some tool settings.
This version was simplified specifically to reduce register pressure and make the effect path map to FPGA memory resources.

## What this project does

- Captures stereo audio from Pmod I2S2 ADC side.
- Outputs stereo audio to Pmod I2S2 DAC side.
- Dry passthrough is the default path.
- Optional single-switch **small echo/comb-style effect** uses one mono circular delay buffer.

## Basys3 controls

- `SW[0]`: echo effect enable
  - `0` = dry passthrough (default)
  - `1` = enable simplified echo/comb effect
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

## Lightweight architecture notes

- Clocks are generated once in the ADC receiver and reused by the DAC transmitter.
- The effect path is intentionally reduced from full-width stereo processing to a **shared mono buffer**.
- Delay memory is coded in synchronous RAM style (circular buffer) so Vivado can infer FPGA memory (BRAM/LUTRAM) instead of large FF arrays.
- Delay depth is `2^12 = 4096` samples.
- Internal effect precision is reduced to **16-bit** (`EFFECT_BITS=16`) from the 24-bit I/O sample width.
- Current simplified mix:
  - wet = dry + `0.5 * delayed`
  - feedback write = dry + `0.25 * delayed`

### Fidelity/resource tradeoff

This design deliberately trades effect fidelity/complexity for implementation size and fit margin:

- Reduced-width effect math/storage (16-bit)
- One shared mono delay line instead of dual stereo delay lines
- Single small feedback echo/comb instead of multi-stage reverb network

## Build

From repo root:

```bash
make synth MOD=audio_reverb
make implement MOD=audio_reverb
make download MOD=audio_reverb
```
