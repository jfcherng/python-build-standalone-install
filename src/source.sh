#!/usr/bin/env bash

_provide_python() {
    # don't overwrite the `SCRIPT_DIR` in the parent script
    local SCRIPT_DIR

    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

    PATH="${SCRIPT_DIR}/bin:${PATH}"
    export PATH

    CPATH="${SCRIPT_DIR}/include:${CPATH}"
    export CPATH

    LD_LIBRARY_PATH="${SCRIPT_DIR}/lib:${LD_LIBRARY_PATH}"
    export LD_LIBRARY_PATH
}

_provide_python
