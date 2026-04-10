# FPGA Workflow Guide (Windows + Debian/Linux)

This repository supports **the same lab flow on both operating systems**:

- **Windows**: Git Bash + Vivado + GNU make (or `mingw32-make`)
- **Debian/Linux (Ubuntu included)**: Bash + Vivado + GNU make

The HDL files and Makefiles are shared across OSes. The main differences are:

1. How Vivado is added to your shell PATH.
2. Which `make` command is available (`make` vs `mingw32-make` fallback).
3. File cleanup behavior when Vivado/xsim GUI windows are still open.

---

## 1) Quick start by operating system

## Debian/Linux (class-style Ubuntu workflow)

1. Install required tools (`git`, `make`, `python3`, Vivado).
2. Add this to `~/.bashrc` (adjust paths):

```bash
export FPGA_REPO="$HOME/FPGA"
export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
source "$FPGA_REPO/resources/shell_helpers.sh"
```

3. Reload shell:

```bash
source ~/.bashrc
```

4. Verify toolchain:

```bash
ecdoctor
```

---

## Windows (Git Bash + Vivado)

1. Install Git for Windows, Python, and Vivado.
2. In Git Bash, add this to `~/.bashrc` (adjust paths):

```bash
export FPGA_REPO='/c/Users/<you>/FPGA'
export VIVADO_ROOT='/c/AMDDesignTools/2025.2/Vivado'
source "$FPGA_REPO/resources/shell_helpers.sh"
```

3. Optional: if your environment uses a different GNU make executable, pin it:

```bash
export EC_MAKE_CMD=mingw32-make
```

4. Reload shell:

```bash
source ~/.bashrc
```

5. Verify toolchain:

```bash
ecdoctor
```

---

## 2) Why this works on both OSes

`resources/shell_helpers.sh` now auto-detects a GNU make-compatible command in this order:

1. `EC_MAKE_CMD` (if you set it)
2. `make`
3. `mingw32-make`
4. `gmake`

That means the same helper commands (`ecmake`, `ecmods`, `ectb`, `ecsim`, `ecbit`) behave consistently even when Windows shells expose make differently than Debian/Ubuntu shells.

---

## 3) Daily commands (recommended)

Use helper commands from any directory:

```bash
fpga                               # jump to repo root
ecmods                             # list modules with Makefiles
ecmake lab_project/pong sim
ecmake lab_multiseg/seven_segment4 sim_tb
ecmake lab_project/project_top synth
ecmake lab_project/project_top implement
ecbit lab_project/project_top      # synth + implement convenience flow
ecclean lab_project/project_top    # robust cleanup (kills lingering tools first)
```

If you are already inside a module directory, `ecmake` can infer `MOD`:

```bash
cd lab_project/pong
ecmake sim

cd ../project_top
ecmake synth
ecmake implement
```

You can still use direct make in a module folder, but the helper workflow is smoother cross-platform.

---

## 4) Root Makefile workflow

From repo root:

```bash
make mods
make doctor
make sim MOD=lab_project/pong
make sim_tb MOD=lab_multiseg/seven_segment4
make synth MOD=lab_project/project_top
make implement MOD=lab_project/project_top
make clean MOD=lab_project/project_top
```

From inside a module directory, use the module targets directly (no `MOD=` needed):

```bash
cd lab_project/pong
make sim

cd ../../lab_multiseg/seven_segment4
make sim_tb

cd ../../lab_project/project_top
make synth
make implement
make clean
```

If your shell does not provide `make`, either install it or use:

```bash
EC_MAKE_CMD=mingw32-make ecdoctor
EC_MAKE_CMD=mingw32-make ecmake lab_project/pong sim
```

---

## 5) Module expectations

Typical module directories contain one of these patterns:

- **Testbench-driven simulation**: `tb.sv` + RTL + `Makefile` (use `sim_tb`)
- **Tcl-driven simulation**: `sim.tcl` + RTL + `Makefile` (use `sim`)
- **FPGA top-level build**: `basys3.xdc` + top module + `Makefile` (use `synth`/`implement`)

Minimal module Makefile pattern:

```make
REPO_PATH=../..
include $(REPO_PATH)/resources/common.mk

MODULE_NAME = my_module
SV_FILES = my_module.sv
```

---

## 6) Common failure modes + fixes

- **`Vivado environment could not be initialized`**
  - Set `VIVADO_ROOT` (or `VIVADO_SETTINGS`) correctly for your machine, then rerun `ecdoctor`.
- **`No GNU make compatible command found`**
  - Install GNU make or set `EC_MAKE_CMD` to the correct executable (often `mingw32-make` on Windows).
- **`clean` fails on Windows**
  - Close xsim/Vivado GUI windows and rerun `ecclean <module>`. The helper already attempts process cleanup first.

---

## 7) Practical recommendation for class parity

For an Ubuntu-based class environment (like ECEN 320 lab machines), the closest local behavior comes from:

- Running in Debian/Ubuntu Bash,
- Using a matching Vivado version when possible,
- Using the helper commands (`ecdoctor`, `ecmake`, `ecbit`) so environment setup is repeatable.

