# Audio Passthrough

This project is a reusable Basys3 + Digilent Pmod I2S2 audio passthrough foundation. It receives stereo audio from the Pmod I2S2 line-in ADC path and immediately retransmits the same samples to the line-out DAC path with no filtering or DSP effects.

The intended future processing chain is:

`pmod_i2s2_engine -> audio_passthrough_core -> pmod_i2s2_engine`

For future projects, insert FIR, gain, LFO, echo, reverb, or other sample-domain processing between receive and transmit by replacing or extending [audio_passthrough_core.sv](/home/ryan/FPGA/common_modules/audio_passthrough/audio_passthrough_core.sv).

## Module Breakdown

- [audio_passthrough_top.sv](/home/ryan/FPGA/common_modules/audio_passthrough/audio_passthrough_top.sv): Basys3 top level, `JC` PMOD pin integration, reset handling, and passthrough wiring.
- [audio_clock_mmcm.sv](/home/ryan/FPGA/common_modules/audio_passthrough/audio_clock_mmcm.sv): MMCM-based audio clock generator adapted from Digilent's working Pmod I2S2 reference design.
- [pmod_i2s2_engine.sv](/home/ryan/FPGA/common_modules/audio_passthrough/pmod_i2s2_engine.sv): Proven shared RX/TX engine that drives the Pmod I2S2 clocks and shifts 24-bit stereo samples in and out.
- [audio_passthrough_core.sv](/home/ryan/FPGA/common_modules/audio_passthrough/audio_passthrough_core.sv): Thin one-stereo-sample bridge from RX to TX. This is the intentional insertion point for future audio effects.
- [i2s_rx.sv](/home/ryan/FPGA/common_modules/audio_passthrough/i2s_rx.sv) and [i2s_tx.sv](/home/ryan/FPGA/common_modules/audio_passthrough/i2s_tx.sv): Earlier reusable protocol-edge modules that are still kept in the project for unit simulation and future experimentation.
- [reset_sync.sv](/home/ryan/FPGA/common_modules/audio_passthrough/reset_sync.sv): Synchronizes reset deassertion into the generated audio clock domain.

## Sample Flow

1. `audio_clock_mmcm` generates the audio master clock from the Basys3 100 MHz oscillator.
2. `pmod_i2s2_engine` derives the Pmod I2S2 `MCLK`, `LRCK`, and `SCLK` timing from that audio clock and drives both ADC-side and DAC-side PMOD pins.
3. `pmod_i2s2_engine` reconstructs one stereo sample pair from `JC10`.
4. `audio_passthrough_core` buffers that stereo pair and forwards it unchanged.
5. On the next audio frame, `pmod_i2s2_engine` serializes the forwarded stereo pair onto `JC4`.

In the current implementation the transmit path starts with one muted stereo frame after reset while the first received stereo pair is being captured. After that, the design continuously forwards audio one stereo frame later.

## PMOD Pin Assumptions

This design stays on the Basys3 `JC` header in standard orientation. It does not use `JA`.

### ADC / line-in side

- `JC7  = A/D MCLK`
- `JC8  = A/D LRCK`
- `JC9  = A/D SCLK`
- `JC10 = A/D SDOUT`

### DAC / line-out side

- `JC1  = D/A MCLK`
- `JC2  = D/A LRCK`
- `JC3  = D/A SCLK`
- `JC4  = D/A SDIN`

The constraints are in [basys3.xdc](/home/ryan/FPGA/common_modules/audio_passthrough/basys3.xdc).

## Clocking Assumptions

This project treats the FPGA as the I2S clock master for both the ADC and DAC interfaces. That means the FPGA drives the Pmod clocks rather than trying to recover them from the module.

The design assumes:

- The Pmod I2S2 ADC side is configured so it accepts externally supplied clocks. Digilent’s Pmod I2S2 documentation describes using the input converter in slave mode for FPGA-driven demonstrations.
- The DAC side accepts externally supplied `MCLK`, `LRCK`, `SCLK`, and serial data.
- A dedicated MMCM generates an approximately `22.590 MHz` audio clock from the Basys3 100 MHz oscillator.
- All Pmod I2S2 timing is derived from that generated audio clock, so there are no asynchronous crossings inside the active audio datapath.

The hardware-facing clocking now follows Digilent's working Pmod I2S2 reference structure:

- `MCLK = audio_clk ~= 22.590 MHz`
- `SCLK = audio_clk / 8 ~= 2.824 MHz`
- `LRCK = audio_clk / 512 ~= 44.1 kHz`

This gives:

- `MCLK / LRCK ~= 512`
- `SCLK / LRCK = 64`

With the default `SAMPLE_WIDTH=24`, the design sends 24-bit stereo audio using the framing style from the Digilent reference design. There is idle padding in the frame, matching the working vendor implementation.

## Supported I2S Format Assumptions

The active hardware datapath is intentionally aligned with the Digilent Pmod I2S2 demo and is intended for:

- Stereo I2S
- Signed two’s-complement samples
- `LRCK=0` for left channel and `LRCK=1` for right channel
- One-bit delay between `LRCK` transition and MSB, as required by standard I2S
- 24-bit samples per channel
- `SCLK = 64 * Fs`

The older standalone `i2s_rx.sv` and `i2s_tx.sv` modules remain in the tree, but the Basys3 implementation target now uses `pmod_i2s2_engine.sv` because that matches the working board behavior more closely.

## Simulation

From `common_modules/audio_passthrough`:

- `make sim_tb_i2s_rx`
- `make sim_tb_i2s_tx`
- `make sim_tb_core`
- `make sim_tb_top`
- `make sim_tb_all`

Testbench coverage:

- [tb_i2s_rx.sv](/home/ryan/FPGA/common_modules/audio_passthrough/tb_i2s_rx.sv): Drives known I2S words and checks stereo reconstruction, sign handling, and channel ordering.
- [tb_i2s_tx.sv](/home/ryan/FPGA/common_modules/audio_passthrough/tb_i2s_tx.sv): Loads known signed stereo samples and checks transmitted serial bit order and framing.
- [tb_audio_passthrough_core.sv](/home/ryan/FPGA/common_modules/audio_passthrough/tb_audio_passthrough_core.sv): Verifies that the core forwards received stereo samples unchanged through its bridge buffer.
- [tb_audio_passthrough_top.sv](/home/ryan/FPGA/common_modules/audio_passthrough/tb_audio_passthrough_top.sv): Feeds a simple ADC I2S stream into the top level and confirms the DAC output matches after the expected startup latency.

## Synthesis And Build

From `common_modules/audio_passthrough`:

- `make synth`
- `make implement`

The project follows the same `common.mk` workflow used elsewhere in this repository.

## Programming The Basys3

After implementation succeeds:

- Connect the Basys3 over USB.
- From `common_modules/audio_passthrough`, run `make download`.

That uses the repository’s shared OpenOCD-based download flow.

## Future Processing Insertion Point

For future effects projects, keep the active top-level chain:

`pmod_i2s2_engine -> processor -> pmod_i2s2_engine`

and replace the direct bridge inside [audio_passthrough_core.sv](/home/ryan/FPGA/common_modules/audio_passthrough/audio_passthrough_core.sv).

The intended processing interface is:

`rx_left_sample`, `rx_right_sample`, `rx_sample_valid` in, and `tx_left_sample`, `tx_right_sample` out.

The current passthrough core keeps one stereo frame of latency and forwards samples unchanged.
