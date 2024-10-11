#!/usr/bin/env bash
# pbs = python build standalone

__pbs_is_windows() {
    [[ -n ${WINDIR} ]]
}

__pbs_provide_python() {
    # don't overwrite the `SCRIPT_DIR` in the parent script
    local SCRIPT_DIR

    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

    if __pbs_is_windows; then
        PATH="${SCRIPT_DIR}/Scripts:${SCRIPT_DIR}:${PATH}"
    else
        PATH="${SCRIPT_DIR}/bin:${PATH}"
    fi
    export PATH

    CPATH="${SCRIPT_DIR}/include:${CPATH}"
    export CPATH

    if __pbs_is_windows; then
        LD_LIBRARY_PATH="${SCRIPT_DIR}/DLLs:${LD_LIBRARY_PATH}"
    else
        LD_LIBRARY_PATH="${SCRIPT_DIR}/lib:${LD_LIBRARY_PATH}"
    fi
    export LD_LIBRARY_PATH
}

__pbs_provide_python
