#!/bin/bash
# Python script installer
set -euo pipefail
IFS=$'\n\t'

REPO_URL="https://www.python.org/ftp/python"
DEFAULT_INSTALL_PATH="/tmp/getpython"
DEPENDENCY_PKGS=(curl tar wget openssl-devel bzip2-devel zlib-devel libffi-devel make gcc)

HELP_TEXT="
Usage: bash getpython.sh [--version VERSION]

Options:
  --version               Which python version you'd like to install (e.g. 3.6.5, 3.9.5, 3.11.0)
  --help, -h              Show this help message
"

## Getting the user input
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --help|-h)
    echo "$HELP_TEXT"
    exit 0
    ;;
    --version) VERSION="$2"; shift 2 ;;
    *) echo "Unknown option: $1" ;;
  esac
done

function log() {
  if [[ -n "${LOG:-}" ]]; then
    printf '%s\n' "$*" | tee -a "$LOG" >&2
  else
    printf '%s\n' "$*" >&2
  fi
}
function fatal() { log "ERROR: $*"; exit 1; }

# Check supported OS versions
function detect_os_version() {
OS_VER=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')

case "$OS_VER" in
  rhel|centos|rocky|almalinux|ubuntu|debian) ;;
  *) fatal "Unsupported distro: $OS_VER";;
esac
}

# Supported packaged manager
function check_pkg_manager() {
    PKG_MGR=$(command -v dnf || command -v yum)
    [[ -x $PKG_MGR ]] || fatal "command dnf/yum not found"
}

# Install packages needed
function need_pkgs() {
    local missing=()
    for pkgs in "$@"; do 
        rpm -q "$pkgs" &>/dev/null || missing+=("$pkgs")
    done

    if ((${#missing[@]})); then
        "$PKG_MGR" -y install "${missing[@]}"
    else
        log "All requested packages already present."
    fi
}

# If dir doesn't exist create it
function check_install_path() {
  if [[ ! -e ${DEFAULT_INSTALL_PATH} ]]; then
    log "INFO: Install path doesn't exist, creating it on ${DEFAULT_INSTALL_PATH}."
    mkdir -p "${DEFAULT_INSTALL_PATH}"
  else
    log "${DEFAULT_INSTALL_PATH} already exist, skip creating."
  fi
}

# Download from official repository
function download_tarball() {
  log "INFO: Downloading the Python ${VERSION} tarball."
  curl -o ${DEFAULT_INSTALL_PATH}/Python-"${VERSION}".tgz ${REPO_URL}/"${VERSION}"/Python-"${VERSION}".tgz || wget -O ${DEFAULT_INSTALL_PATH}/Python-"${VERSION}".tgz ${REPO_URL}/"${VERSION}"/Python-"${VERSION}".tgz
}

# skip if tarball exist, else download tarball
function check_tarball() {
  local tarball="${DEFAULT_INSTALL_PATH}/Python-${VERSION}.tgz"

  if [[ -f "$tarball" ]]; then
    log "INFO: Python ${VERSION} tarball already exists. Skipping download."
  else
    download_tarball
  fi
}

# Extract if file exist
function extract_tarball() {
  if [[ -e ${DEFAULT_INSTALL_PATH}/Python-"${VERSION}".tgz ]]; then
    log "INFO: Extracting the Python ${VERSION} tarball."
    tar -xf ${DEFAULT_INSTALL_PATH}/Python-"${VERSION}".tgz --overwrite -C ${DEFAULT_INSTALL_PATH}
  else
    fatal "File doesn't exist, exiting the script"
  fi
}

# Install requested python
function install_python() {
  log "INFO: Compiling and install Python ${VERSION}."
  ${DEFAULT_INSTALL_PATH}/Python-"${VERSION}"/configure --enable-optimizations
  make altinstall
}

# Main function
function main() {
  log "INFO: Starting the script ..."
  detect_os_version
  check_pkg_manager

  log "INFO: Installing required packages."
  need_pkgs "${DEPENDENCY_PKGS[@]}"

  check_install_path
  check_tarball
  extract_tarball
  install_python && log "Python ${VERSION} successfully installed." || fatal "Error installing Python ${VERSION}."
}

# Validate the user input
if [[ -z "${VERSION:-}" ]]; then
  echo "ERROR: --version is required"
  echo "$HELP_TEXT"
  exit 1
fi

main
