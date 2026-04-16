# Home Workflow (CachyOS / Arch Linux)

This repo uses a Linux-native workflow centered on Bash + GNU Make.

## 1) One-time shell setup

Add to `~/.bashrc`:

```bash
export FPGA_REPO="/absolute/path/to/FPGA"
export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
# Optional alternative:
# export VIVADO_SETTINGS="/tools/Xilinx/Vivado/2025.2/settings64.sh"
source "$FPGA_REPO/resources/shell_helpers.sh"
```

Reload:

```bash
source ~/.bashrc
```

## 2) Validate environment

```bash
ecdoctor
```

`ecdoctor` checks:
- `git`
- `python3`
- `make`
- Vivado tools (`vivado`, `xvlog`, `xelab`, `xsim`)

## 3) Daily flow

```bash
fpga
ecmods
ecmake demo/pong sim
ecmake demo/project_top synth
ecmake demo/project_top implement
ecbit demo/project_top
ecclean demo/project_top
```

## 4) Root-level equivalents

```bash
make mods
make doctor
make sim MOD=demo/pong
make synth MOD=demo/project_top
make implement MOD=demo/project_top
make download MOD=demo/project_top
```
