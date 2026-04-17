# FPGA Workflow Guide (Arch Linux / CachyOS, Make-based)

This repository uses a **Make-first workflow** for FPGA development with AMD Vivado.

---

## 1) Getting started: clone the repository

```bash
git clone <your-repo-url> "$HOME/FPGA"
cd "$HOME/FPGA"
```

If you already cloned somewhere else, substitute that path in the commands throughout this guide.

---

## 2) One-time environment setup

Install required tooling:

```bash
sudo pacman -S --needed git make python openocd
```

Install Vivado, then add a sourcing alias in your `~/.bashrc` so each new shell can load Vivado quickly:

```bash
export FPGA_REPO="$HOME/FPGA"
export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
# Optional alternative:
# export VIVADO_SETTINGS="/tools/Xilinx/Vivado/2025.2/settings64.sh"

alias vivadoenv='source "$VIVADO_ROOT/settings64.sh"'
```

Reload your shell config and verify:

```bash
source ~/.bashrc
vivadoenv
make doctor
```

> If you use `VIVADO_SETTINGS` instead of `VIVADO_ROOT`, set the alias to:
> `alias vivadoenv='source "$VIVADO_SETTINGS"'`

---

## 3) Core make workflow (root vs module directories)

### Run from repository root (`$FPGA_REPO`)

Use root-level targets when you want to pick a module with `MOD=...`.

```bash
make mods
make sim MOD=demo/pong
make sim_tb MOD=common_modules/seven_segment/seven_segment
make synth MOD=demo/project_top
make implement MOD=demo/project_top
make download MOD=demo/project_top
make clean MOD=demo/project_top
```

### Run from inside a module directory

If you `cd` into a specific module directory, run the same targets directly:

```bash
cd "$FPGA_REPO/demo/pong"
make sim
make sim_nogui
make clean
```

For a testbench-driven module:

```bash
cd "$FPGA_REPO/common_modules/seven_segment/seven_segment"
make sim_tb
make sim_tb_gui
```

---

## 4) What each make target does

- `make mods` (root): lists module directories that contain Makefiles.
- `make doctor` (root): checks local toolchain and environment.
- `make sim`: runs simulation using `sim.tcl` in the module.
- `make sim_nogui`: same as `sim`, but without Vivado GUI.
- `make sim_tb`: compiles/runs `tb.sv`-based testbench flow.
- `make sim_tb_gui`: GUI variant of `sim_tb`.
- `make pre_synth_schematic`: opens pre-synthesis schematic flow.
- `make synth`: synthesizes and produces `work/synth.dcp`.
- `make open_synth_checkpoint`: opens synthesized checkpoint.
- `make implement`: runs implementation to produce `work/implement.dcp`.
- `make open_implement_checkpoint`: opens implemented checkpoint.
- `make download`: programs generated bitstream through OpenOCD.
- `make clean`: removes module-local `work/` artifacts.

---

## 5) How to create a Makefile for each module

Each module folder should contain a `Makefile` with:

- `REPO_PATH`: relative path from module folder back to repository root.
- `MODULE_NAME`: design top module name.
- `SV_FILES`: space-separated SystemVerilog source list.
- Include of shared rules from `resources/common.mk`.

### Typical module layout

```text
<module>/
  Makefile
  <module>.sv
  tb.sv          # optional, for sim_tb
  sim.tcl        # optional, for sim/sim_nogui
  basys3.xdc     # needed for synth/implement/download
```

### Minimal Makefile template

```make
REPO_PATH=../..
MODULE_NAME = my_top
SV_FILES = my_top.sv helper.sv

include $(REPO_PATH)/resources/common.mk
```

Use `REPO_PATH` values like:

- `..` for a module one level below repo root
- `../..` for two levels below
- `../../..` for three levels below

---

## 6) Basic daily workflow

1. Open terminal and load Vivado:
   ```bash
   vivadoenv
   ```
2. From repo root, list modules and pick one:
   ```bash
   cd "$FPGA_REPO"
   make mods
   ```
3. Run simulation first (`sim` or `sim_tb`).
4. Run synthesis and implementation.
5. Download bitstream to board.
6. Clean module artifacts when needed.

Example loop:

```bash
cd "$FPGA_REPO"
vivadoenv
make sim MOD=demo/pong
make synth MOD=demo/project_top
make implement MOD=demo/project_top
make download MOD=demo/project_top
```

---

## 7) Resources

- Root command help:
  ```bash
  make help
  ```
- Shared make rules: `resources/common.mk`
- Environment checker: `resources/doctor.sh`
- Vivado env bootstrap used by make: `resources/vivado_env.sh`
- Example modules:
  - `demo/pong`
  - `demo/project_top`
  - `common_modules/seven_segment/seven_segment`
