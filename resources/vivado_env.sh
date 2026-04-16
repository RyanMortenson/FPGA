#!/usr/bin/env bash

if command -v vivado >/dev/null 2>&1 && \
   command -v xvlog  >/dev/null 2>&1 && \
   command -v xelab  >/dev/null 2>&1 && \
   command -v xsim   >/dev/null 2>&1; then
    export FPGA_VIVADO_READY=1
    export FPGA_VIVADO_SETTINGS="${FPGA_VIVADO_SETTINGS:-${VIVADO_SETTINGS:-${VIVADO_ROOT:-on PATH}}}"
    return 0 2>/dev/null || exit 0
fi

if [[ -n "${VIVADO_SETTINGS:-}" ]]; then
    if [[ ! -f "${VIVADO_SETTINGS}" ]]; then
        echo "FPGA error: VIVADO_SETTINGS was set but file was not found: ${VIVADO_SETTINGS}" >&2
        return 1 2>/dev/null || exit 1
    fi

    # shellcheck source=/dev/null
    . "${VIVADO_SETTINGS}"
    export FPGA_VIVADO_SETTINGS="${VIVADO_SETTINGS}"
else
    export VIVADO_ROOT="${VIVADO_ROOT:-/tools/Xilinx/Vivado/2025.2}"

    if [[ -f "${VIVADO_ROOT}/settings64.sh" ]]; then
        # shellcheck source=/dev/null
        . "${VIVADO_ROOT}/settings64.sh"
        export FPGA_VIVADO_SETTINGS="${VIVADO_ROOT}/settings64.sh"
    elif [[ -d "${VIVADO_ROOT}/bin" ]]; then
        export PATH="${VIVADO_ROOT}/bin:${PATH}"
        export XILINX_VIVADO="${VIVADO_ROOT}"
        export FPGA_VIVADO_SETTINGS="${VIVADO_ROOT}"
    else
        echo "FPGA error: Vivado installation not found at ${VIVADO_ROOT}" >&2
        echo "Set VIVADO_ROOT or VIVADO_SETTINGS (settings64.sh), then retry." >&2
        return 1 2>/dev/null || exit 1
    fi
fi

if ! command -v vivado >/dev/null 2>&1 || \
   ! command -v xvlog  >/dev/null 2>&1 || \
   ! command -v xelab  >/dev/null 2>&1 || \
   ! command -v xsim   >/dev/null 2>&1; then
    echo "FPGA error: Vivado tools are not available after environment initialization" >&2
    return 1 2>/dev/null || exit 1
fi

export FPGA_VIVADO_READY=1
return 0 2>/dev/null || exit 0
