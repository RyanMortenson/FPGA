#!/usr/bin/env bash
# Source this from ~/.bashrc:
#   source /absolute/path/to/FPGA/resources/shell_helpers.sh

_fpga_shell_helpers_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

_ec_need_repo() {
    if [[ -z "${FPGA_REPO:-}" ]]; then
        FPGA_REPO="${_fpga_shell_helpers_root}"
    fi
    if [[ ! -d "${FPGA_REPO}" ]]; then
        echo "FPGA_REPO is not set to a valid repo path." >&2
        echo "Current value: ${FPGA_REPO:-<unset>}" >&2
        return 1
    fi
}


_ec_detect_make_cmd() {
    if [[ -n "${EC_MAKE_CMD:-}" ]]; then
        printf '%s\n' "${EC_MAKE_CMD}"
        return 0
    fi

    local candidate
    for candidate in make mingw32-make gmake; do
        if command -v "$candidate" >/dev/null 2>&1; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

_ec_require_make_cmd() {
    local make_cmd
    make_cmd="$(_ec_detect_make_cmd)" || {
        echo "No GNU make compatible command found. Install make (Arch Linux: `pacman -S make`) or mingw32-make (Windows/Git Bash)." >&2
        return 1
    }
    printf '%s\n' "$make_cmd"
}

_ec_make_var() {
    local moddir="$1"
    local var="$2"
    local make_cmd
    make_cmd="$(_ec_require_make_cmd)" || return 1
    "$make_cmd" -s -C "$moddir" --eval='print-%: ; @echo $($*)' "print-$var" 2>/dev/null
}

_ec_show_log_and_check() {
    local log="$1"
    [[ -f "$log" ]] || return 1
    cat "$log"
    if grep -q '^ERROR:' "$log"; then
        return 1
    fi
    return 0
}

_ec_is_windows_gitbash() {
    case "$(uname -s 2>/dev/null || true)" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
        *) return 1 ;;
    esac
}

_ec_kill_vivado_processes() {
    if _ec_is_windows_gitbash; then
        /c/Windows/System32/taskkill.exe /IM xsimk.exe /F >/dev/null 2>&1 || true
        /c/Windows/System32/taskkill.exe /IM xsim.exe /F >/dev/null 2>&1 || true
        /c/Windows/System32/taskkill.exe /IM xelab.exe /F >/dev/null 2>&1 || true
        /c/Windows/System32/taskkill.exe /IM xvlog.exe /F >/dev/null 2>&1 || true
        /c/Windows/System32/taskkill.exe /IM vivado.exe /F >/dev/null 2>&1 || true
    else
        command -v pkill >/dev/null 2>&1 && pkill -f xsim >/dev/null 2>&1 || true
        command -v pkill >/dev/null 2>&1 && pkill -f xelab >/dev/null 2>&1 || true
        command -v pkill >/dev/null 2>&1 && pkill -f xvlog >/dev/null 2>&1 || true
        command -v pkill >/dev/null 2>&1 && pkill -f vivado >/dev/null 2>&1 || true
    fi
}

_ec_remove_workdir() {
    local workdir="$1"
    if _ec_is_windows_gitbash; then
        local winpath
        winpath=$(cygpath -w "$workdir")
        /c/Windows/System32/cmd.exe //C "rmdir /S /Q \"$winpath\"" >/dev/null 2>&1 || true
    fi
    rm -rf "$workdir"
}

fpga() {
    cd "${_fpga_shell_helpers_root}"
}

viv() {
    . "${_fpga_shell_helpers_root}/resources/vivado_env.sh"
}


_ec_find_module_from_pwd() {
    local repo_root="${_fpga_shell_helpers_root}"
    local here="$(pwd -P)"
    local probe="$here"

    while [[ "$probe" == "$repo_root"/* || "$probe" == "$repo_root" ]]; do
        if [[ -f "$probe/Makefile" ]]; then
            local rel="${probe#"$repo_root"/}"
            if [[ "$probe" == "$repo_root" ]]; then
                return 1
            fi
            printf '%s\n' "$rel"
            return 0
        fi
        [[ "$probe" == "$repo_root" ]] && break
        probe="$(dirname "$probe")"
    done

    return 1
}

ecmods() {
    (cd "${_fpga_shell_helpers_root}" && "$(_ec_require_make_cmd)" mods)
}

ecmake() {
    local mod target

    if [[ $# -ge 2 ]] && [[ -f "${_fpga_shell_helpers_root}/$1/Makefile" ]]; then
        mod="$1"
        shift
    elif [[ $# -ge 1 ]]; then
        mod="$(_ec_find_module_from_pwd)" || {
            echo 'usage: ecmake <module-dir> <target> [extra make args...]' >&2
            echo 'or run inside a module directory: ecmake <target>' >&2
            echo 'example: ecmake graphics_project/project_top synth' >&2
            echo 'example: (inside demo/pong) ecmake sim' >&2
            return 1
        }
    else
        echo 'usage: ecmake <module-dir> <target> [extra make args...]' >&2
        echo 'or run inside a module directory: ecmake <target>' >&2
        return 1
    fi

    target="$1"
    shift
    (cd "${_fpga_shell_helpers_root}" && "$(_ec_require_make_cmd)" MOD="${mod}" "${target}" "$@")
}

ecdoctor() {
    "${_fpga_shell_helpers_root}/resources/doctor.sh"
}

ecclean() {
    _ec_need_repo || return 1

    local mod="$1"
    if [[ -z "$mod" ]]; then
        echo "usage: ecclean <module-path>" >&2
        return 1
    fi

    local module_dir="$FPGA_REPO/$mod"
    [[ -d "$module_dir" ]] || { echo "ecclean: module not found: $module_dir" >&2; return 1; }

    local workdir="$module_dir/work"
    if [[ ! -d "$workdir" ]]; then
        echo "ecclean: no work/ directory in $mod"
        return 0
    fi

    _ec_kill_vivado_processes
    _ec_remove_workdir "$workdir"

    if [[ -d "$workdir" ]]; then
        echo "ecclean: could not remove $workdir" >&2
        echo "Close any Vivado/xsim windows and any terminals sitting inside that folder, then try again." >&2
        return 1
    fi

    echo "ecclean: removed $workdir"
}

ectb() {
    _ec_need_repo || return 1

    local mod="$1"
    if [[ -z "$mod" ]]; then
        echo "usage: ectb <module-path>" >&2
        return 1
    fi

    local module_dir="$FPGA_REPO/$mod"
    [[ -d "$module_dir" ]] || { echo "ectb: module not found: $module_dir" >&2; return 1; }
    [[ -f "$module_dir/tb.sv" ]] || { echo "ectb: missing tb.sv in $module_dir" >&2; return 1; }

    local sv_files
    sv_files="$(_ec_make_var "$module_dir" SV_FILES)"
    [[ -n "$sv_files" ]] || { echo "ectb: SV_FILES not found in $module_dir/Makefile" >&2; return 1; }

    local -a sv_array sv_abs
    local f
    read -r -a sv_array <<< "$sv_files"
    for f in "${sv_array[@]}"; do
        sv_abs+=("$module_dir/$f")
    done

    mkdir -p "$module_dir/work" || return 1

    (
        cd "$module_dir/work" || exit 1
        . "$FPGA_REPO/resources/vivado_env.sh" || exit 1

        xvlog "$module_dir/tb.sv" "${sv_abs[@]}" -sv > xvlog_tb.log 2>&1 || true
        _ec_show_log_and_check xvlog_tb.log || { echo "ectb: compile failed" >&2; exit 1; }

        xvlog "$FPGA_REPO/resources/cells_sim.v" > xvlog_cells.log 2>&1 || true
        _ec_show_log_and_check xvlog_cells.log || { echo "ectb: cells compile failed" >&2; exit 1; }

        xelab tb -debug typical --timescale 1ns/1ps > xelab.log 2>&1
        _ec_show_log_and_check xelab.log || { echo "ectb: elaborate failed" >&2; exit 1; }

        xsim tb --runall
    )
}

ectbgui() {
    _ec_need_repo || return 1

    local mod="$1"
    if [[ -z "$mod" ]]; then
        echo "usage: ectbgui <module-path>" >&2
        return 1
    fi

    local module_dir="$FPGA_REPO/$mod"
    [[ -d "$module_dir" ]] || { echo "ectbgui: module not found: $module_dir" >&2; return 1; }
    [[ -f "$module_dir/tb.sv" ]] || { echo "ectbgui: missing tb.sv in $module_dir" >&2; return 1; }

    local sv_files
    sv_files="$(_ec_make_var "$module_dir" SV_FILES)"
    [[ -n "$sv_files" ]] || { echo "ectbgui: SV_FILES not found in $module_dir/Makefile" >&2; return 1; }

    local -a sv_array sv_abs
    local f
    read -r -a sv_array <<< "$sv_files"
    for f in "${sv_array[@]}"; do
        sv_abs+=("$module_dir/$f")
    done

    mkdir -p "$module_dir/work" || return 1

    (
        cd "$module_dir/work" || exit 1
        . "$FPGA_REPO/resources/vivado_env.sh" || exit 1

        xvlog "$module_dir/tb.sv" "${sv_abs[@]}" -sv > xvlog_tb.log 2>&1 || true
        _ec_show_log_and_check xvlog_tb.log || { echo "ectbgui: compile failed" >&2; exit 1; }

        xvlog "$FPGA_REPO/resources/cells_sim.v" > xvlog_cells.log 2>&1 || true
        _ec_show_log_and_check xvlog_cells.log || { echo "ectbgui: cells compile failed" >&2; exit 1; }

        xelab tb -debug typical --timescale 1ns/1ps > xelab.log 2>&1
        _ec_show_log_and_check xelab.log || { echo "ectbgui: elaborate failed" >&2; exit 1; }

        xsim tb -gui
    )
}

ecsim() {
    _ec_need_repo || return 1

    local mod="$1"
    if [[ -z "$mod" ]]; then
        echo "usage: ecsim <module-path>" >&2
        return 1
    fi

    local module_dir="$FPGA_REPO/$mod"
    [[ -d "$module_dir" ]] || { echo "ecsim: module not found: $module_dir" >&2; return 1; }
    [[ -f "$module_dir/sim.tcl" ]] || { echo "ecsim: missing sim.tcl in $module_dir" >&2; return 1; }

    local module_name sv_files sim_params
    module_name="$(_ec_make_var "$module_dir" MODULE_NAME)"
    sv_files="$(_ec_make_var "$module_dir" SV_FILES)"
    sim_params="$(_ec_make_var "$module_dir" SIM_PARAMS)"

    [[ -n "$module_name" ]] || { echo "ecsim: MODULE_NAME not found in $module_dir/Makefile" >&2; return 1; }
    [[ -n "$sv_files" ]] || { echo "ecsim: SV_FILES not found in $module_dir/Makefile" >&2; return 1; }

    local -a sv_array sv_abs param_array xelab_args
    local f p
    read -r -a sv_array <<< "$sv_files"
    read -r -a param_array <<< "$sim_params"

    for f in "${sv_array[@]}"; do
        sv_abs+=("$module_dir/$f")
    done
    for p in "${param_array[@]}"; do
        xelab_args+=(--generic_top "$p")
    done

    mkdir -p "$module_dir/work" || return 1

    (
        cd "$module_dir/work" || exit 1
        . "$FPGA_REPO/resources/vivado_env.sh" || exit 1

        xvlog "${sv_abs[@]}" -sv > xvlog_sim.log 2>&1 || true
        _ec_show_log_and_check xvlog_sim.log || { echo "ecsim: compile failed" >&2; exit 1; }

        xvlog "$FPGA_REPO/resources/cells_sim.v" > xvlog_cells.log 2>&1 || true
        _ec_show_log_and_check xvlog_cells.log || { echo "ecsim: cells compile failed" >&2; exit 1; }

        xelab "$module_name" -debug typical --timescale 1ns/1ps "${xelab_args[@]}" > xelab.log 2>&1
        _ec_show_log_and_check xelab.log || { echo "ecsim: elaborate failed" >&2; exit 1; }

        xsim "$module_name" -tclbatch ../sim.tcl
    )
}

ecsimgui() {
    _ec_need_repo || return 1

    local mod="$1"
    if [[ -z "$mod" ]]; then
        echo "usage: ecsimgui <module-path>" >&2
        return 1
    fi

    local module_dir="$FPGA_REPO/$mod"
    [[ -d "$module_dir" ]] || { echo "ecsimgui: module not found: $module_dir" >&2; return 1; }
    [[ -f "$module_dir/sim.tcl" ]] || { echo "ecsimgui: missing sim.tcl in $module_dir" >&2; return 1; }

    local module_name sv_files sim_params
    module_name="$(_ec_make_var "$module_dir" MODULE_NAME)"
    sv_files="$(_ec_make_var "$module_dir" SV_FILES)"
    sim_params="$(_ec_make_var "$module_dir" SIM_PARAMS)"

    [[ -n "$module_name" ]] || { echo "ecsimgui: MODULE_NAME not found in $module_dir/Makefile" >&2; return 1; }
    [[ -n "$sv_files" ]] || { echo "ecsimgui: SV_FILES not found in $module_dir/Makefile" >&2; return 1; }

    local -a sv_array sv_abs param_array xelab_args
    local f p
    read -r -a sv_array <<< "$sv_files"
    read -r -a param_array <<< "$sim_params"

    for f in "${sv_array[@]}"; do
        sv_abs+=("$module_dir/$f")
    done
    for p in "${param_array[@]}"; do
        xelab_args+=(--generic_top "$p")
    done

    mkdir -p "$module_dir/work" || return 1

    (
        cd "$module_dir/work" || exit 1
        . "$FPGA_REPO/resources/vivado_env.sh" || exit 1

        xvlog "${sv_abs[@]}" -sv > xvlog_sim.log 2>&1 || true
        _ec_show_log_and_check xvlog_sim.log || { echo "ecsimgui: compile failed" >&2; exit 1; }

        xvlog "$FPGA_REPO/resources/cells_sim.v" > xvlog_cells.log 2>&1 || true
        _ec_show_log_and_check xvlog_cells.log || { echo "ecsimgui: cells compile failed" >&2; exit 1; }

        xelab "$module_name" -debug typical --timescale 1ns/1ps "${xelab_args[@]}" > xelab.log 2>&1
        _ec_show_log_and_check xelab.log || { echo "ecsimgui: elaborate failed" >&2; exit 1; }

        xsim "$module_name" -gui -tclbatch ../sim.tcl
    )
}

ecbit() {
    _ec_need_repo || return 1

    local mod="$1"
    if [[ -z "$mod" ]]; then
        echo "usage: ecbit <top-module-path>" >&2
        return 1
    fi

    local module_dir="$FPGA_REPO/$mod"
    [[ -d "$module_dir" ]] || { echo "ecbit: module not found: $module_dir" >&2; return 1; }
    [[ -f "$module_dir/Makefile" ]] || { echo "ecbit: missing Makefile in $module_dir" >&2; return 1; }
    [[ -f "$module_dir/basys3.xdc" ]] || { echo "ecbit: missing basys3.xdc in $module_dir" >&2; return 1; }

    echo "[ecbit] synth: $mod"
    ecmake "$mod" synth || return 1

    echo "[ecbit] implement: $mod"
    ecmake "$mod" implement || return 1

    local bit="$module_dir/work/design.bit"
    if [[ -f "$bit" ]]; then
        echo "[ecbit] bitstream ready: $bit"
    else
        echo "ecbit: implement finished but design.bit was not found at $bit" >&2
        return 1
    fi
}

# Backward-compatible alias
ecen320() {
    fpga
}
