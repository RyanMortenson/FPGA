# Home Workflow (Cross-Platform)

This repo keeps class Makefiles intact while making the shell experience consistent across Arch Linux and Windows Git Bash.

## 1) One-time setup

Add to `~/.bashrc`:

```bash
export FPGA_REPO="/absolute/path/to/FPGA"
# Arch Linux example:
# export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
# Windows Git Bash example:
# export VIVADO_ROOT='/c/AMDDesignTools/2025.2/Vivado'
source "$FPGA_REPO/resources/shell_helpers.sh"
```

If needed (mostly Windows), pin make executable:

```bash
export EC_MAKE_CMD=mingw32-make
```

Reload:

```bash
source ~/.bashrc
```

## 2) Validate

```bash
ecdoctor
```

`ecdoctor` checks:
- `git`
- `python3`
- GNU make-compatible command (`make`, `mingw32-make`, or `gmake`)
- Vivado toolchain (`vivado`, `xvlog`, `xelab`, `xsim`)

## 3) Recommended daily flow

```bash
fpga
ecmods
ecmake demo/pong sim
ecmake common_modules/multi_segment/seven_segment4 sim_tb
ecmake graphics_project/project_top synth
ecmake graphics_project/project_top implement
ecbit graphics_project/project_top
ecclean graphics_project/project_top
```

If you are already in a module directory:

```bash
cd demo/pong
ecmake sim
```

## 4) Root-level equivalent

```bash
make mods
make doctor
make sim MOD=demo/pong
make sim_tb MOD=common_modules/multi_segment/seven_segment4
make synth MOD=graphics_project/project_top
make implement MOD=graphics_project/project_top
```

## 5) Version parity note

If you want behavior closest to a specific class lab image, match Vivado version when possible. Otherwise the helper flow remains the same.
