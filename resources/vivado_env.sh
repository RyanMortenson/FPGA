#!/usr/bin/env bash

if command -v vivado >/dev/null 2>&1 && \
   command -v xvlog  >/dev/null 2>&1 && \
   command -v xelab  >/dev/null 2>&1 && \
   command -v xsim   >/dev/null 2>&1; then
    export FPGA_VIVADO_READY=1
    export FPGA_VIVADO_SETTINGS="${FPGA_VIVADO_SETTINGS:-${VIVADO_ROOT:-on PATH}}"
    return 0 2>/dev/null || exit 0
fi

export VIVADO_ROOT="${VIVADO_ROOT:-/c/AMDDesignTools/2025.2/Vivado}"

if [[ ! -d "$VIVADO_ROOT/bin" ]]; then
    echo "FPGA error: Vivado bin directory not found under: $VIVADO_ROOT" >&2
    return 1 2>/dev/null || exit 1
fi

case ":$PATH:" in
    *:/c/Windows/System32:*) ;;
    *) export PATH="/c/Windows/System32:$PATH" ;;
esac

export PATH="$VIVADO_ROOT/bin:$PATH"
export XILINX_VIVADO="$VIVADO_ROOT"
export FPGA_VIVADO_SETTINGS="$VIVADO_ROOT"

if ! command -v vivado >/dev/null 2>&1 || \
   ! command -v xvlog  >/dev/null 2>&1 || \
   ! command -v xelab  >/dev/null 2>&1 || \
   ! command -v xsim   >/dev/null 2>&1; then
    echo "FPGA error: Vivado tools not on PATH after adding $VIVADO_ROOT/bin" >&2
    return 1 2>/dev/null || exit 1
fi

export FPGA_VIVADO_READY=1
return 0 2>/dev/null || exit 0