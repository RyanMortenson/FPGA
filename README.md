# FPGA Workflow Guide (Windows + Debian/Linux)

> [!TIP]
> **Quick start (copy + clone):** Open a terminal, pick where you want the project, then run:
>
> ```bash
> cd <your-local-parent-folder>
> git clone https://github.com/<owner>/FPGA.git
> cd FPGA
> ```
>
> To quickly copy snippets from this README, click the copy button on any code block and paste into your terminal.

This repository is designed to be a **reusable FPGA project template**: you can copy the workflow to new labs/projects, keep your modules organized, and run simulation/synthesis/implementation/download from the command line.

The same HDL + Makefile pattern works on both operating systems:

- **Windows**: Git Bash + Vivado + GNU make (or `mingw32-make`)
- **Debian/Linux (Ubuntu included)**: Bash + Vivado + GNU make

---

## 1) One-time setup

### Debian/Linux

1. Install `git`, `make`, `python3`, and Vivado.
2. Add the following to `~/.bashrc` (adjust paths):

```bash
export FPGA_REPO="$HOME/FPGA"
export VIVADO_ROOT="/tools/Xilinx/Vivado/2025.2"
source "$FPGA_REPO/resources/shell_helpers.sh"
```

3. Reload shell and verify:

```bash
source ~/.bashrc
ecdoctor
```

### Windows (Git Bash)

1. Install Git for Windows, Python, and Vivado.
2. Add the following to `~/.bashrc` (adjust paths):

```bash
export FPGA_REPO='/c/Users/<you>/FPGA'
export VIVADO_ROOT='/c/AMDDesignTools/2025.2/Vivado'
source "$FPGA_REPO/resources/shell_helpers.sh"
```

3. If your GNU make executable is not named `make`, set:

```bash
export EC_MAKE_CMD=mingw32-make
```

4. Reload shell and verify:

```bash
source ~/.bashrc
ecdoctor
```

---

## 2) Mental model of the workflow

Think of each design block as a **module directory** with its own `Makefile`. That module `Makefile` declares:

- what top module to build (`MODULE_NAME`), and
- what source files belong to that design (`SV_FILES`).

The module `Makefile` then includes `resources/common.mk`, which provides standardized targets:

- Simulation: `sim`, `sim_nogui`, `sim_tb`, `sim_tb_gui`
- Synthesis/implementation: `synth`, `implement`
- Utilities: `download`, `clean`, checkpoint-open targets

At repo root, the top-level `Makefile` can run those same targets in any module via `MOD=<path>`.

---

## 3) Create a new project/module from scratch

Use this structure as your default template:

```text
<your_project>/
  Makefile                 # optional project-level driver
  <your_module>/
    Makefile               # required
    <your_module>.sv       # top or core RTL
    tb.sv                  # for sim_tb flow (optional)
    sim.tcl                # for sim flow (optional)
    basys3.xdc             # for synth/implement/download (optional)
```

### Step A: Create module directory

```bash
mkdir -p <your_project>/<your_module>
cd <your_project>/<your_module>
```

### Step B: Add module Makefile

Set `REPO_PATH` to the relative path from your module back to repo root.

- If module path is `lab_name/block_name`, use `REPO_PATH=../..`
- If module path is deeper, adjust accordingly.

Example:

```make
REPO_PATH=../..
include $(REPO_PATH)/resources/common.mk

MODULE_NAME = my_top
SV_FILES = my_top.sv helper.sv
```

### Step C: Add RTL files

Create `my_top.sv` and any supporting modules listed in `SV_FILES`.

### Step D: Pick simulation style

You can use either simulation mode:

1. **`sim_tb` flow** (self-running testbench)
   - Needs `tb.sv`
   - Run: `make sim_tb` (or `ecmake <module> sim_tb`)

2. **`sim` flow** (Vivado Tcl-driven)
   - Needs `sim.tcl`
   - Run: `make sim` (GUI by default) or `make sim_nogui`

### Step E: Add FPGA build collateral (optional)

To build a bitstream, add:

- `basys3.xdc` constraints file
- A synthesizable top module name in `MODULE_NAME`
- All synthesizable dependencies in `SV_FILES`

Then run `synth`, `implement`, and `download`.

---

## 4) Running commands: root vs inside module

### From repo root (portable and explicit)

```bash
make mods
make sim MOD=<your_project>/<your_module>
make sim_tb MOD=<your_project>/<your_module>
make synth MOD=<your_project>/<your_module>
make implement MOD=<your_project>/<your_module>
make download MOD=<your_project>/<your_module>
make clean MOD=<your_project>/<your_module>
```

### From inside a module directory

```bash
cd <your_project>/<your_module>
make sim
make sim_nogui
make sim_tb
make sim_tb_gui
make synth
make implement
make download
make clean
```

### Shell helper commands (recommended)

After sourcing `resources/shell_helpers.sh`:

```bash
fpga                              # jump to repo root
ecmods                            # list available module directories
ecmake <module> sim               # run GUI sim.tcl flow
ecmake <module> sim_nogui         # run sim.tcl flow without GUI
ecmake <module> sim_tb            # run tb.sv flow
ecmake <module> synth
ecmake <module> implement
ecmake <module> download
ecbit <module>                    # synth + implement convenience
ecclean <module>                  # robust cleanup if tools are still open
```

If you are already inside a module directory, `ecmake` can infer the module path:

```bash
ecmake sim
ecmake implement
```

---

## 5) GUI vs non-GUI usage

For simulation:

- `make sim` launches xsim with GUI (when using `sim.tcl` flow)
- `make sim_nogui` runs same flow without GUI
- `make sim_tb` runs testbench flow non-GUI (`--runall`)
- `make sim_tb_gui` is available if you want waveform/debug GUI in tb flow

Practical pattern:

1. Use non-GUI (`sim_nogui` / `sim_tb`) in tight edit-test loops.
2. Open GUI only when debugging waveform/timing behavior.

---

## 6) How to include other modules/files correctly

When your top module instantiates helper modules, **every required `.sv` file must be in `SV_FILES`**.

Example:

```make
MODULE_NAME = uart_top
SV_FILES = uart_top.sv uart_rx.sv baud_gen.sv fifo.sv
```

If files are in sibling/shared directories, use relative paths from the module directory:

```make
SV_FILES = uart_top.sv ../shared/uart_rx.sv ../shared/baud_gen.sv
```

Tips:

- Keep `MODULE_NAME` equal to the synthesizable top entity for synth/implement.
- Put testbench-only files in `tb.sv` flow instead of polluting synthesizable file lists.
- Maintain predictable file ordering when package/include dependencies exist.

---

## 7) Building a top file for FPGA

A practical top file checklist:

1. Define the board-facing ports (`clk`, switches/buttons, LEDs, seven-seg, VGA, etc.).
2. Instantiate your internal modules.
3. Hook all ports/signals cleanly.
4. Ensure every instantiated module source is present in `SV_FILES`.
5. Add matching pin + IO standard constraints in `basys3.xdc`.

Then run:

```bash
make synth MOD=<your_project>/<top_module_dir>
make implement MOD=<your_project>/<top_module_dir>
```

Artifacts are produced under `<module>/work/`.

---

## 8) Downloading bitstream to hardware

After successful implementation:

```bash
make download MOD=<your_project>/<top_module_dir>
```

This flow uses the generated `design.bit` and the repository download helper.

Hardware checklist:

- Board connected and powered.
- Cable/driver visible to your OS.
- No conflicting programming session already open.

If download fails, rebuild from clean state:

```bash
make clean MOD=<your_project>/<top_module_dir>
make synth MOD=<your_project>/<top_module_dir>
make implement MOD=<your_project>/<top_module_dir>
make download MOD=<your_project>/<top_module_dir>
```

---

## 9) Suggested end-to-end workflow for new designs

1. Create module directory + module `Makefile`.
2. Add RTL and run fast simulation (`sim_tb` or `sim_nogui`).
3. Iterate until functionally correct.
4. Add/verify `basys3.xdc` and top-level module wiring.
5. Run `synth`, then `implement`.
6. Run `download` and hardware test.
7. Use `clean` / `ecclean` when switching branches or after tool crashes.

---

## 10) Common failure modes and fixes

- **Vivado environment not initialized**
  - Fix `VIVADO_ROOT` or `VIVADO_SETTINGS`; rerun `ecdoctor`.

- **No GNU make-compatible command found**
  - Install `make`, or set `EC_MAKE_CMD` (often `mingw32-make` on Windows).

- **Simulation target mismatch**
  - `sim` requires `sim.tcl`; `sim_tb` requires `tb.sv`.

- **Module instantiation errors in compile/elab**
  - Missing source files in `SV_FILES`, wrong relative paths, or wrong compile order.

- **`clean` fails with locked files (especially Windows)**
  - Close Vivado/xsim windows and run `ecclean <module>`.

---

## 11) Quick command reference

```bash
# Environment + discovery
ecdoctor
ecmods

# Run module targets from root
make sim MOD=<module>
make sim_tb MOD=<module>
make synth MOD=<module>
make implement MOD=<module>
make download MOD=<module>
make clean MOD=<module>

# Helper equivalents
ecmake <module> sim
ecmake <module> sim_nogui
ecmake <module> sim_tb
ecmake <module> synth
ecmake <module> implement
ecmake <module> download
ecbit <module>
ecclean <module>
```

If you keep each module self-contained and keep `SV_FILES`, `MODULE_NAME`, and constraints accurate, this template scales cleanly from tiny exercises to full FPGA projects.
