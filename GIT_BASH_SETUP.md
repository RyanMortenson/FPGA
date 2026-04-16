# CachyOS Setup for ECEN 320-Style Flow

This repository is Linux-first and optimized for CachyOS.

## 1) Install dependencies

```bash
sudo pacman -S --needed git make python openocd
```

## 2) Configure `~/.bashrc`

```bash
export FPGA_REPO="$HOME/FPGA"
export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
# Optional alternative:
# export VIVADO_SETTINGS="/tools/Xilinx/Vivado/2025.2/settings64.sh"
source "$FPGA_REPO/resources/shell_helpers.sh"
```

## 3) Reload + validate

```bash
source ~/.bashrc
ecdoctor
```

## 4) Build flow examples

```bash
ecmods
ecmake demo/pong sim_nogui
ecmake demo/project_top synth
ecmake demo/project_top implement
ecmake demo/project_top download
```
