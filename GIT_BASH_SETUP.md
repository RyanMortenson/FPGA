# Windows Git Bash Setup for ECEN 320-Style Flow

## 1) Recommended path

Place repo at a stable path, for example:

`/c/Users/<you>/FPGA`

## 2) Configure `~/.bashrc`

```bash
export FPGA_REPO='/c/Users/<you>/FPGA'
export VIVADO_ROOT='/c/AMDDesignTools/2025.2/Vivado'
# If your environment doesn't expose `make`, uncomment:
# export EC_MAKE_CMD=mingw32-make
source "$FPGA_REPO/resources/shell_helpers.sh"
```

If auto-detection cannot locate Vivado, set one of:

```bash
export VIVADO_ROOT='/c/Xilinx/Vivado/2025.2'
```

or

```bash
export VIVADO_SETTINGS='/c/Xilinx/Vivado/2025.2/settings64.bat'
```

## 3) Reload + test

```bash
source ~/.bashrc
ecdoctor
```

## 4) Use helper commands

```bash
ecmods
ecmake lab_project/pong sim
ecmake lab_project/project_top synth
```

This is the smoothest route on Windows because the helper handles Vivado environment setup and make-command differences for you.
