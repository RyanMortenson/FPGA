#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

status_ok() {
    printf '[ok] %s\n' "$1"
}

status_warn() {
    printf '[warn] %s\n' "$1"
}

status_fail() {
    printf '[fail] %s\n' "$1"
}

detect_make_cmd() {
    if [[ -n "${EC_MAKE_CMD:-}" ]]; then
        printf '%s\n' "${EC_MAKE_CMD}"
        return 0
    fi

    local candidate
    for candidate in make mingw32-make gmake; do
        if command -v "${candidate}" >/dev/null 2>&1; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done

    return 1
}

printf 'ECEN 320 doctor\n'
printf 'repo: %s\n\n' "${repo_root}"

for exe in git python3; do
    if command -v "${exe}" >/dev/null 2>&1; then
        status_ok "found ${exe}: $(command -v "${exe}")"
    else
        status_fail "missing required executable: ${exe}"
        exit 1
    fi
done

if make_cmd="$(detect_make_cmd)"; then
    status_ok "found make command: ${make_cmd} ($(command -v "${make_cmd}"))"
    "${make_cmd}" --version | head -n 1 || true
else
    status_fail 'missing GNU make compatible command (make, mingw32-make, or gmake)'
    exit 1
fi

echo
if . "${repo_root}/resources/vivado_env.sh" >/dev/null 2>&1 && \
   command -v vivado >/dev/null 2>&1 && \
   command -v xvlog >/dev/null 2>&1 && \
   command -v xelab >/dev/null 2>&1 && \
   command -v xsim >/dev/null 2>&1; then
    status_ok "Vivado source: ${FPGA_VIVADO_SETTINGS:-${VIVADO_ROOT:-on PATH}}"
    status_ok "vivado: $(command -v vivado)"
    status_ok "xvlog:  $(command -v xvlog)"
    status_ok "xelab:  $(command -v xelab)"
    status_ok "xsim:   $(command -v xsim)"
    vivado -version | head -n 1
else
    status_fail 'Vivado environment could not be initialized'
    printf 'hint: set VIVADO_ROOT and/or VIVADO_SETTINGS for your OS before running builds\n'
    exit 1
fi
