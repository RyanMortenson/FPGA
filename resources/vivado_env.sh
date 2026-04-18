#!/usr/bin/env bash

_vivado_env_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_vivado_env_add_compat_ncurses() {
    local compat_dir
    local compat_ncurses
    local compat_tinfo
    local source_ncurses=""
    local source_tinfo=""

    if command -v ldconfig >/dev/null 2>&1; then
        source_ncurses="$(ldconfig -p 2>/dev/null | awk '/libncurses\.so\.6 / {print $NF; exit}')"
        source_tinfo="$(ldconfig -p 2>/dev/null | awk '/libtinfo\.so\.6 / {print $NF; exit}')"
    fi

    if [[ -z "${source_ncurses}" ]]; then
        for candidate in /usr/lib64/libncurses.so.6 /usr/lib/libncurses.so.6 /lib64/libncurses.so.6 /lib/libncurses.so.6; do
            if [[ -e "${candidate}" ]]; then
                source_ncurses="${candidate}"
                break
            fi
        done
    fi

    if [[ -z "${source_tinfo}" ]]; then
        for candidate in /usr/lib64/libtinfo.so.6 /usr/lib/libtinfo.so.6 /lib64/libtinfo.so.6 /lib/libtinfo.so.6; do
            if [[ -e "${candidate}" ]]; then
                source_tinfo="${candidate}"
                break
            fi
        done
    fi

    if [[ -z "${source_ncurses}" ]]; then
        return 0
    fi

    compat_dir="${_vivado_env_script_dir}/.vivado_compat_libs"
    mkdir -p "${compat_dir}"

    compat_ncurses="${compat_dir}/libncurses.so.5"
    if [[ ! -e "${compat_ncurses}" ]]; then
        ln -sf "${source_ncurses}" "${compat_ncurses}"
    fi

    if [[ -n "${source_tinfo}" ]]; then
        compat_tinfo="${compat_dir}/libtinfo.so.5"
        if [[ ! -e "${compat_tinfo}" ]]; then
            ln -sf "${source_tinfo}" "${compat_tinfo}"
        fi
    fi

    case ":${LD_LIBRARY_PATH:-}:" in
        *:"${compat_dir}":*)
            ;;
        *)
            export LD_LIBRARY_PATH="${compat_dir}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
            ;;
    esac
}

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

_vivado_env_add_compat_ncurses

export FPGA_VIVADO_READY=1
return 0 2>/dev/null || exit 0
