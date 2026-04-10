# FPGA Repo Workflow Guide

This guide is the practical "how to work in this repo without fighting the tools" document.

It is written for two environments:

- **Windows + Git Bash + Vivado**
- **Debian/Linux + Bash + Vivado**

The repo layout and HDL flow are the same on both systems. The main differences are:

- how Vivado gets onto `PATH`
- how cleanup behaves when a GUI simulator window is still open
- how you program the Basys 3 board

---

## 1. What this repo is trying to do

Each HDL module lives in its own folder with a **tiny Makefile**. That folder usually contains one of two simulation styles:

### Testbench-driven module

Contains:

- `tb.sv`
- one or more RTL `.sv` files
- `Makefile`

Use these commands:

- `ectb <module-path>` for terminal simulation
- `ectbgui <module-path>` for GUI simulation

### Tcl-driven module

Contains:

- `sim.tcl`
- one or more RTL `.sv` files
- `Makefile`

Use these commands:

- `ecsim <module-path>` for terminal simulation
- `ecsimgui <module-path>` for GUI simulation

### FPGA top-level build module

Contains:

- `basys3.xdc`
- top-level `.sv`
- `Makefile`

Use these commands:

- `ecbit <module-path>` to build the bitstream
- `ecmake <module-path> synth` for synthesis only
- `ecmake <module-path> implement` for implementation only

---

## 2. Recommended repo layout

At the repo root:

```text
FPGA/
  Makefile
  resources/
  lab_intro/
  lab_multiseg/
  lab_project/
  ...
```

Inside a module folder:

```text
some_module/
  Makefile
  some_module.sv
  tb.sv        # if testbench-driven
  sim.tcl      # if Tcl-driven
  basys3.xdc   # if top-level FPGA build
  work/        # generated scratch area
```

---

## 3. Minimal Makefile pattern for new modules

### Simple RTL module with `sim.tcl`

```make
REPO_PATH=../..
include $(REPO_PATH)/resources/common.mk

MODULE_NAME = my_module
SV_FILES = my_module.sv
```

### Module with dependencies

```make
REPO_PATH=../..
include $(REPO_PATH)/resources/common.mk

MODULE_NAME = my_module
SV_FILES = my_module.sv ../helper/helper.sv ../other/other.sv
```

### Top-level build

```make
REPO_PATH=../..
include $(REPO_PATH)/resources/common.mk

MODULE_NAME = my_top
SV_FILES = my_top.sv ../submodule/submodule.sv
```

Notes:

- `MODULE_NAME` must match the HDL top module name you want to elaborate or synthesize.
- `SV_FILES` is a space-separated list of RTL files relative to that module folder.
- For `ectb`, the helper automatically prepends `tb.sv`.
- For `ecsim`, the helper automatically uses `sim.tcl`.

---

## 4. One-time shell setup

### 4.1 Universal idea

You want your shell to know two things:

- where the repo root is
- how to put Vivado tools on `PATH`

AMD documents that Vivado can be launched from the command line with `vivado`, `vivado -mode tcl`, and `vivado -mode batch -source <script>`, and that `settings64.bat` or `settings64.sh` can be used to add Vivado tools to the current shell or command prompt. citeturn734574search0turn734574search1

### 4.2 Debian/Linux shell setup

Add this to `~/.bashrc` and adjust the path to match your install:

```bash
export FPGA_REPO="$HOME/FPGA"
export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
source "$FPGA_REPO/resources/shell_helpers.sh"
```

Or, if your install prefers the vendor script:

```bash
export FPGA_REPO="$HOME/FPGA"
export VIVADO_SETTINGS="/tools/Xilinx/Vivado/2025.2/settings64.sh"
source "$FPGA_REPO/resources/shell_helpers.sh"
```

Then reload:

```bash
source ~/.bashrc
```

### 4.3 Windows + Git Bash setup

Add this to `~/.bashrc` and adjust paths as needed:

```bash
export PATH="/c/Windows/System32:/c/msys64/usr/bin:$PATH"
export FPGA_REPO="$HOME/FPGA"
export VIVADO_ROOT='/c/AMDDesignTools/2025.2/Vivado'
source "$FPGA_REPO/resources/shell_helpers.sh"
viv >/dev/null 2>&1 || true
```

Then reload:

```bash
source ~/.bashrc
```

### 4.4 Smoke test

Run:

```bash
ecdoctor
```

If that was a typo and the helper is named correctly in your repo, use:

```bash
ecdoctor
```

You should see:

- git found
- make found
- python3 found
- vivado found
- xvlog found
- xelab found
- xsim found

---

## 5. Daily command cheat sheet

### Jump to repo root

```bash
ecen320
```

### List buildable modules

```bash
ecmods
```

### Run a testbench module in terminal

```bash
ectb lab_multiseg/seven_segment4
```

### Run a testbench module in GUI

```bash
ectbgui lab_multiseg/seven_segment4
```

### Run a Tcl-driven sim in terminal

```bash
ecsim lab_project/pong
```

### Run a Tcl-driven sim in GUI

```bash
ecsimgui lab_project/pong
```

### Build a bitstream

```bash
ecbit lab_project/project_top
```

### Run an existing make target directly

```bash
ecmake lab_project/project_top synth
ecmake lab_project/project_top implement
```

### Clean one module's work area

```bash
ecclean lab_project/pong
```

---

## 6. What each helper does

### `viv`

Loads the Vivado environment into the current shell.

Use this when you want direct access to:

- `vivado`
- `xvlog`
- `xelab`
- `xsim`

### `ectb <module>`

For a module with `tb.sv`:

1. creates `work/`
2. loads Vivado tools
3. compiles `tb.sv`
4. compiles the module's `SV_FILES`
5. compiles `resources/cells_sim.v`
6. elaborates top `tb`
7. runs `xsim tb --runall`

### `ectbgui <module>`

Same as `ectb`, but opens the simulator GUI with:

```bash
xsim tb -gui
```

### `ecsim <module>`

For a module with `sim.tcl`:

1. creates `work/`
2. loads Vivado tools
3. compiles the module's `SV_FILES`
4. compiles `resources/cells_sim.v`
5. elaborates `MODULE_NAME`
6. runs `xsim <module_name> -tclbatch ../sim.tcl`

### `ecsimgui <module>`

Same as `ecsim`, but opens the GUI and runs the Tcl file:

```bash
xsim <module_name> -gui -tclbatch ../sim.tcl
```

### `ecclean <module>`

Removes the `work/` directory for one module.

On Windows/Git Bash it also tries to kill stale Vivado/xsim processes first, because Windows can keep simulator files locked.

### `ecbit <module>`

Runs:

1. `synth`
2. `implement`

Then prints the bitstream path if `work/design.bit` exists.

---

## 7. GUI simulation and waveforms

### 7.1 `sim.tcl` modules

Use:

```bash
ecsimgui lab_project/pong
```

If the GUI opens but the wave window is empty, your `sim.tcl` may not be adding signals. In the xsim Tcl console, try:

```tcl
log_wave -recursive *
add_wave -recursive *
run all
```

### 7.2 `tb.sv` modules

Use:

```bash
ectbgui lab_multiseg/seven_segment4
```

If the wave window is empty, use the same Tcl commands in the xsim console:

```tcl
log_wave -recursive *
add_wave -recursive *
run all
```

### 7.3 Close GUI before cleaning

Before cleaning a module after GUI simulation:

- close the xsim/Vivado GUI window
- then run `ecclean <module>`

Windows may refuse to delete `work/` if the GUI still has files open.

---

## 8. Building and programming the Basys 3

The Basys 3 reference manual says the board can be programmed over the onboard USB-JTAG interface and that JTAG programming can be done using Vivado Hardware Manager. citeturn976514search23turn976514search25

### 8.1 Build the bitstream

```bash
ecbit lab_project/project_top
```

If successful, the bitstream should be here:

```text
lab_project/project_top/work/design.bit
```

### 8.2 Program from Vivado Hardware Manager

This is the least fragile option on every platform:

1. power on the Basys 3
2. connect the USB-JTAG port
3. open Vivado
4. open **Hardware Manager**
5. open target / auto connect
6. program device with `design.bit`

### 8.3 Program from command line on Linux

This repo also has a `download` make target that uses `resources/openocd.py`.

On Debian, `openocd` is available as a package in current Debian releases. citeturn252407search0turn252407search2

Typical install:

```bash
sudo apt update
sudo apt install openocd
```

Then, from a top-level build module:

```bash
make download
```

Or from the repo root:

```bash
make download MOD=lab_project/project_top
```

If programming fails on Linux, the usual causes are:

- missing permissions / udev rules
- the board not being detected over USB
- another tool already holding the cable

If you just want to keep moving, use Vivado Hardware Manager first and come back to command-line download later.

---

## 9. Recommended day-to-day workflows

### 9.1 Fast HDL iteration for a testbench module

```bash
ecen320
ectb lab_multiseg/seven_segment4
ectbgui lab_multiseg/seven_segment4
```

### 9.2 Fast HDL iteration for a Tcl-driven module

```bash
ecen320
ecsim lab_project/pong
ecsimgui lab_project/pong
```

### 9.3 Build and test on the board

```bash
ecen320
ecbit lab_project/project_top
```

Then program `work/design.bit` using Hardware Manager.

---

## 10. Common problems and the fast fix

### Vivado tools not found

Run:

```bash
viv
ecdoctor
```

If still broken, check `VIVADO_ROOT` or `VIVADO_SETTINGS` in `~/.bashrc`.

### GUI simulation fails because files are busy

Use:

```bash
ecclean <module>
```

Then rerun the GUI helper.

### `ecsimgui` fails on a path with spaces

Use relative Tcl paths inside helpers and keep the repo path as short as practical. AMD also warns that Windows path length and path complexity can affect Vivado flows. citeturn734574search0

### Not sure whether to use `ectb` or `ecsim`

Look inside the module folder:

- has `tb.sv` → use `ectb` / `ectbgui`
- has `sim.tcl` → use `ecsim` / `ecsimgui`

### `make clean` fails on Windows

That usually means a simulator window or terminal still has the folder open. `ecclean <module>` is the preferred cleanup command on Windows.

---

## 11. Suggested onboarding checklist for a new machine

### Universal checklist

1. clone the repo
2. install Vivado
3. set `FPGA_REPO`
4. set `VIVADO_ROOT` or `VIVADO_SETTINGS`
5. source `resources/shell_helpers.sh` from `~/.bashrc`
6. reload shell
7. run `ecdoctor`
8. run one terminal sim
9. run one GUI sim
10. build one bitstream
11. program the Basys 3

### Good first commands

```bash
ecdoctor
ectb lab_multiseg/seven_segment4
ectbgui lab_multiseg/seven_segment4
ecsim lab_project/pong
ecsimgui lab_project/pong
ecbit lab_project/project_top
```

---

## 12. If you want to keep the repo shareable with a friend

Recommended commit targets:

- `resources/shell_helpers.sh`
- `resources/vivado_env.sh`
- `resources/doctor.sh`
- `resources/common.mk`
- this markdown guide

Do **not** commit generated files like:

- `work/`
- `.Xil/`
- `xsim.dir/`
- `*.jou`
- `*.log`
- `*.wdb`
- generated bitstreams unless you intentionally want them in git

---

## 13. Bottom line

Use these as your real mental model:

- `ectb` = testbench sim
- `ectbgui` = testbench sim with GUI
- `ecsim` = Tcl-driven sim
- `ecsimgui` = Tcl-driven sim with GUI
- `ecbit` = build a bitstream
- `ecclean` = nuke one module's scratch area cleanly

That is the workflow.
