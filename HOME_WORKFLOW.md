# Home Workflow for ECEN 320

This keeps the class Makefiles intact, but removes the need to manually baby the Vivado environment every time.

## 1) One-time shell setup

Add this line to your `~/.bashrc`:

```bash
source /absolute/path/to/FPGA/resources/shell_helpers.sh
```

Then open a new shell (or run `source ~/.bashrc`).

Useful commands after that:

```bash
fpga                     # jump to repo root
viv                         # source Vivado into the current shell
ecmods                      # list buildable module directories
ecmake lab_project/pong sim
ecmake lab_project/project_top synth
ecdoctor                    # check toolchain wiring
```

## 2) Pin the Vivado version you want

If you want your home machine to consistently use 2025.2, add one of these to `~/.bashrc` **before** the helper is sourced:

```bash
export VIVADO_VERSION=2025.2
```

If auto-detection misses your install, set the exact file instead:

```bash
export VIVADO_SETTINGS=/absolute/path/to/settings64.sh
```

## 3) Root-level workflow

From the repo root:

```bash
make mods
make doctor
make sim MOD=lab_project/pong
make sim_tb MOD=lab_multiseg/seven_segment4
make synth MOD=lab_project/project_top
make implement MOD=lab_project/project_top
```

You can still use the original class flow too:

```bash
cd lab_project/project_top
make synth
make implement
```

The difference now is that the Make infrastructure auto-sources Vivado when needed.

## 4) Important note about exact class parity

Your class machine example used Vivado 2024.1. You installed 2025.2.
That is usually fine for simulation and synthesis, but if you want exact behavior parity with the lab machines, install 2024.1 and set:

```bash
export VIVADO_VERSION=2024.1
```

## 5) Expected module usage pattern

- `sim` is for modules that have a local `sim.tcl`
- `sim_tb` is for modules that have a local `tb.sv`
- `synth` / `implement` are typically for the `*_top` modules with `basys3.xdc`
- `download` also needs `openocd`
