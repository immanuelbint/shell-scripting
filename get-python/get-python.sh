#!/bin/bash
# Python script installer
set -euo pipefail
IFS=$'\n\t'

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

REPO_URL="https://www.python.org/ftp/python"
INSTALL_DIR="/tmp/getpython"
VERSION="${VERSION:-}"
PYTHON_TARBALL_NAME="Python-${VERSION}.tgz"
PYTHON_TARBALL_PATH="${INSTALL_DIR}/${PYTHON_TARBALL_NAME}"
PYTHON_TARBALL_URL="${REPO_URL}/${VERSION}/${PYTHON_TARBALL_NAME}"

DEPENDENCY_PKGS=(curl tar wget openssl-devel bzip2-devel zlib-devel libffi-devel make gcc)
declare -A REQPKGS
REQPKGS["openssl-devel"]="libssl-dev"
REQPKGS["zlib-devel"]="zlib1g-dev"
REQPKGS["bzip2-devel"]="libbz2-dev"
REQPKGS["libffi-devel"]="libffi-dev"


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
  if [[ $OS_VER =~ (rhel|centos|rocky|almalinux) ]]; then
    PKG_MGR=$(command -v dnf || command -v yum)
    [[ -x $PKG_MGR ]] || fatal "command dnf/yum not found"
  else
    PKG_MGR=$(command -v apt || command -v apt-get)
    [[ -x $PKG_MGR ]] || fatal "command apt/apt-get not found"
  fi
}

# Install packages needed
function need_pkgs() {
    local missing=()
    if [[ $PKG_MGR =~ (yum|dnf) ]]; then
      for pkgs in "$@"; do 
          rpm -q "$pkgs" &>/dev/null || missing+=("$pkgs")
      done
    elif [[ $PKG_MGR =~ (apt|apt-get) ]]; then
      for pkgs in "$@"; do
        mapped_pkg="${REQPKGS[$pkgs]:-$pkgs}"
        dpkg -s "$mapped_pkg" &>/dev/null || missing+=("$mapped_pkg")
      done
    fi

    if ((${#missing[@]})); then
        "$PKG_MGR" -y install "${missing[@]}" &>/dev/null
    else
        log "INFO: All requested packages already present."
    fi
}

# If dir doesn't exist create it
function check_install_path() {
  if [[ ! -e ${INSTALL_DIR} ]]; then
    log "INFO: Install path doesn't exist, creating it on ${INSTALL_DIR}."
    mkdir -p "${INSTALL_DIR}"
  else
    log "INFO: Dir ${INSTALL_DIR} already exist, skip creating."
  fi
}

# Download from official repository
function download_tarball() {
  log "INFO: Downloading the Python ${VERSION} tarball."
  curl -o "$PYTHON_TARBALL_PATH" "$PYTHON_TARBALL_URL" || \
  wget -O "$PYTHON_TARBALL_PATH" "$PYTHON_TARBALL_URL" || \
  fatal "Failed to download Python ${VERSION}."
}

# skip if tarball exist, else download tarball
function fetch_and_extract_tarball() {
  if [[ -f "$PYTHON_TARBALL_PATH" ]]; then
    log "INFO: Python ${VERSION} tarball already exists. Skipping download."
  else
    download_tarball
  fi

  log "INFO: Extracting the Python ${VERSION} tarball."
  tar -xf "$PYTHON_TARBALL_PATH" --overwrite -C ${INSTALL_DIR} || \
  fatal "File doesn't exist, exiting the script"
}

# Install requested python
function install_python() {
  log "INFO: Compiling and install Python ${VERSION}."
  ${INSTALL_DIR}/Python-"${VERSION}"/configure --enable-optimizations
  make altinstall && log "Python ${VERSION} successfully installed."
}

function main() {
  log "INFO: Starting the script ..."
  detect_os_version
  check_pkg_manager

  log "INFO: Installing required packages."
  need_pkgs "${DEPENDENCY_PKGS[@]}"

  check_install_path
  fetch_and_extract_tarball
  install_python || fatal "Failed to install Python ${VERSION}."
}

# Validate the user input
if [[ -z "${VERSION:-}" ]]; then
  echo "ERROR: --version is required"
  echo "$HELP_TEXT"
  exit 1
fi

main
