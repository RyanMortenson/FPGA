# FPGA Workflow Guide (Arch Linux / CachyOS, Make-based)

This repository is optimized for a Linux-native, Bash + GNU Make workflow with AMD Vivado.

- Target distro: **Arch Linux family**, especially **CachyOS**.
- Build model: **module-local Makefiles** + shared rules in `resources/common.mk`.
- Shell model: source `resources/shell_helpers.sh` and drive everything with `make`/`ecmake`.

---

## 1) One-time setup (CachyOS)

Install required packages:

```bash
sudo pacman -S --needed git make python openocd
```

Install Vivado, then set environment variables in `~/.bashrc`:

```bash
export FPGA_REPO="$HOME/FPGA"
export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
# Optional: point directly to settings script instead of VIVADO_ROOT
# export VIVADO_SETTINGS="/tools/Xilinx/Vivado/2025.2/settings64.sh"
source "$FPGA_REPO/resources/shell_helpers.sh"
```

Reload and verify:

```bash
source ~/.bashrc
ecdoctor
```

---

## 2) Workflow model

Each module directory has a `Makefile` that defines:

- `MODULE_NAME`
- `SV_FILES`
- `REPO_PATH` (relative path back to repository root)

Then it includes:

```make
include $(REPO_PATH)/resources/common.mk
```

Common targets:

- Simulation: `sim`, `sim_nogui`, `sim_tb`, `sim_tb_gui`
- Build: `synth`, `implement`, `download`
- Cleanup/utilities: `clean`, checkpoint-open targets

---

## 3) Core commands

From repo root:

```bash
make mods
make sim MOD=demo/pong
make sim_tb MOD=common_modules/seven_segment
make synth MOD=demo/project_top
make implement MOD=demo/project_top
make download MOD=demo/project_top
make clean MOD=demo/project_top
```

Using helper functions:

```bash
fpga
ecmods
ecmake demo/pong sim_nogui
ecmake demo/project_top synth
ecmake demo/project_top implement
ecmake demo/project_top download
ecbit demo/project_top
ecclean demo/project_top
```

If already inside a module directory:

```bash
ecmake sim
ecmake implement
```

---

## 4) New module template

```text
<project>/<module>/
  Makefile
  <module>.sv
  tb.sv          # optional (for sim_tb)
  sim.tcl        # optional (for sim/sim_nogui)
  basys3.xdc     # optional (for synth/implement/download)
```

Example `Makefile`:

```make
REPO_PATH=../..
include $(REPO_PATH)/resources/common.mk

MODULE_NAME = my_top
SV_FILES = my_top.sv helper.sv
```

---

## 5) Common issues

- `ecdoctor` fails Vivado checks:
  - Set `VIVADO_ROOT` or `VIVADO_SETTINGS` correctly.
- `make` not found:
  - Install with `sudo pacman -S --needed make`.
- Simulation compile/elaboration fails:
  - Verify every dependent source is listed in `SV_FILES`.
- `work/` cannot be removed:
  - Close running Vivado/xsim processes and run `ecclean <module>`.

---

## 6) Recommended CachyOS daily loop

```bash
fpga
ecmods
ecmake demo/pong sim_nogui
ecmake demo/project_top synth
ecmake demo/project_top implement
ecmake demo/project_top download
```

For fast iteration, use `sim_nogui` or `sim_tb` first, then open GUI only when debugging waveforms.
