# Git Bash setup for ECEN 320 workflow on Windows

1. Put the repo at a stable path, for example:
   /c/Users/Ryan Mortenson/FPGA

2. Add these lines to ~/.bashrc:

```bash
export FPGA_REPO='/c/Users/Ryan Mortenson/FPGA'
export VIVADO_VERSION=2025.2
source "$FPGA_REPO/resources/shell_helpers.sh"
```

3. If auto-detect misses your install, add one of these instead:

```bash
export VIVADO_ROOT=/c/Xilinx/Vivado/2025.2
```

or

```bash
export VIVADO_SETTINGS=/c/Xilinx/Vivado/2025.2/settings64.bat
```

4. Reload the shell:

```bash
source ~/.bashrc
```

5. Verify:

```bash
ecdoctor
```
