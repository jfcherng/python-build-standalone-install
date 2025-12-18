#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR_REAL="$(readlink -f "${SCRIPT_DIR}")"
SCRIPT_TMP="${SCRIPT_DIR}/.tmp"

URL_PYTHON_TARBALL_DEFAULT="https://github.com/indygreg/python-build-standalone/releases/download/20251217/cpython-3.14.2+20251217-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz"
URL_PYTHON_TARBALL=${URL_PYTHON_TARBALL:-"${URL_PYTHON_TARBALL_DEFAULT}"}
URL_PYTHON_TARBALL_SHA256="$(dirname "$URL_PYTHON_TARBALL")/SHA256SUMS"

# the Python tarball name like "cpython-3.12.3+20240415-x86_64-unknown-linux-gnu-install_only.tar.gz"
PYTHON_TARBALL_NAME=$(basename "${URL_PYTHON_TARBALL}")
# the Python version number like "3.12.4", "3.12" and "3"
PYTHON_VERSION_3=$(sed -n -E 's@^cpython-([0-9]+\.[0-9]+\.[0-9]+).*@\1@p' <<<"${PYTHON_TARBALL_NAME}")
PYTHON_VERSION_2=$(sed -n -E 's@^([0-9]+\.[0-9]+).*@\1@p' <<<"${PYTHON_VERSION_3}")
PYTHON_VERSION_1=$(sed -n -E 's@^([0-9]+).*@\1@p' <<<"${PYTHON_VERSION_2}")
# where to install Python to
PYTHON_INSTALL_DIR_DEFAULT="${HOME}/opt/python-${PYTHON_VERSION_2}"
PYTHON_INSTALL_DIR=${PYTHON_INSTALL_DIR:-"${PYTHON_INSTALL_DIR_DEFAULT}"}

# -------------------- #
# function definitions #
# -------------------- #

##
## @brief      Echo to stderr.
##
echo_() {
    echo "$@" >&2
}

is_windows() {
    [[ -n ${WINDIR} ]]
}

# ----- #
# works #
# ----- #

if is_windows; then
    PYTHON_EXE="${PYTHON_INSTALL_DIR}/python.exe"
    PYTHON_SITE_PACKAGES_DIR="${PYTHON_INSTALL_DIR}/Lib/site-packages"
else
    PYTHON_EXE="${PYTHON_INSTALL_DIR}/bin/python"
    PYTHON_SITE_PACKAGES_DIR="${PYTHON_INSTALL_DIR}/lib/python${PYTHON_VERSION_2}/site-packages"
fi

echo_ "[INFO] Requested Python download URL: ${URL_PYTHON_TARBALL}"
echo_ "[INFO] Installing Python ${PYTHON_VERSION_2}: ${PYTHON_INSTALL_DIR}"

mkdir -p "${SCRIPT_TMP}" "${PYTHON_INSTALL_DIR}"

{
    pushd "${SCRIPT_TMP}" || exit 1

    # fetch SHA256SUMS file
    echo_ "[INFO] Fetching SHA256SUMS file..."
    checksum_golden=$(curl -sL "${URL_PYTHON_TARBALL_SHA256}")
    if [[ -z ${checksum_golden} ]]; then
        echo_ "[ERROR] Failed to retrieve SHA256SUMS file: ${URL_PYTHON_TARBALL_SHA256}"
        exit 1
    fi

    # download tarball
    echo_ "[INFO] Downloading Python tarball..."
    if [[ ! -f ${PYTHON_TARBALL_NAME} ]]; then
        curl -sL --output "${PYTHON_TARBALL_NAME}" "${URL_PYTHON_TARBALL}"
    fi

    # verify SHA256 checksum
    checksum_actual=$(sha256sum "${PYTHON_TARBALL_NAME}" | awk '{print $1}')
    echo_ "[INFO] Verifying SHA256 checksum of the downloaded tarball..."
    echo_ "[INFO] Downloaded tarball checksum: ${checksum_actual}"
    if [[ ! ${checksum_golden} =~ ${checksum_actual} ]]; then
        echo_ "[ERROR] SHA256 checksum mismatch. Probably the download is corrupted."
        rm -f "${PYTHON_TARBALL_NAME}" # incomplete download
        exit 1
    fi

    # remove old pip (the downloaded tarball has pip installed)
    PIP_DIR="${PYTHON_SITE_PACKAGES_DIR}/pip"
    if [[ -d ${PIP_DIR} ]]; then
        echo_ "[INFO] Removing old pip installation: ${PIP_DIR}"
        rm -rf -- "${PIP_DIR}" "${PIP_DIR}-"*.dist-info/
    fi

    # decompress `PYTHON_TARBALL`
    echo_ "[INFO] Decompressing the tarball to \"${PYTHON_INSTALL_DIR}\""
    tar -C "${PYTHON_INSTALL_DIR}" -axf "${PYTHON_TARBALL_NAME}" --strip-components=1

    if [[ ! -f ${PYTHON_EXE} ]]; then
        echo_ "[ERROR] Python executable is not found."
        exit 1
    fi
    echo_ "[INFO] Installed: $("${PYTHON_EXE}" -VV)"

    # this should make packaged PyInstaller APP smaller
    # @see https://github.com/indygreg/python-build-standalone/issues/275
    if ! is_windows; then
        echo_ "[INFO] Stripping Python shared libraries..."
        strip --preserve-dates "${PYTHON_INSTALL_DIR}/lib/libpython${PYTHON_VERSION_2}.so"
    fi

    # set environment variables
    cp -f "${SCRIPT_DIR_REAL}/source.bash" "${PYTHON_INSTALL_DIR}/source.bash"
    . "${PYTHON_INSTALL_DIR}/source.bash"

    # install some basic Python packages (use the latest `pip` to install)
    "${PYTHON_EXE}" -m pip install --upgrade pip
    "${PYTHON_EXE}" -m pip install --upgrade -r "${SCRIPT_DIR_REAL}/requirements.txt"

    # fixes SSL cert file location
    # @see https://github.com/indygreg/python-build-standalone/issues/259#issuecomment-2134009017
    cp -f "${SCRIPT_DIR_REAL}/sitecustomize.py" "${PYTHON_SITE_PACKAGES_DIR}/sitecustomize.py"

    if ! "${PYTHON_EXE}" "${SCRIPT_DIR_REAL}/test_ssl.py"; then
        echo_ "[ERROR] SSL certificate verification failed."
        exit 1
    fi

    echo_ -n "[INFO] Installation completed successfully. Please add the following line to your shell profile: "
    echo_ ". \"${PYTHON_INSTALL_DIR}/source.bash\""

    popd || exit 1
}

echo_ "[INFO] Clean up temporary files..."
rm -rf "${SCRIPT_TMP}"
