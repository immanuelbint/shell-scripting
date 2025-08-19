#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

TARGET=${1:-"."}
CLEAN=0
ISSUE=0

## Setup logging
function log() {
  if [[ -n "${LOG:-}" ]]; then
    printf '%s\n' "$*" | tee -a "$LOG" >&2
  else
    printf '%s\n' "$*" >&2
  fi
}
function fatal() { log "ERROR: $*"; exit 1; }

## Scanning if there's still secrets intact on yaml files
function grep_keyword() {
    local file="$1"
    set +e
    grep -q -E '(aws_|slack_|github_|token|password|secret)' "$file"
    local status=$?

    if [[ $status == 0 ]]; then
        ((ISSUE++))
        log "WARN: Found secrets in $file, avoid hardcoding sensitive data"
    elif [[ $status == 1 ]]; then
        ((CLEAN++))
        log "INFO: File $file is clean"
    else
        fatal "Failed to scan file, check either file permission or checksum if its corrupted"
    fi
}

## Check if yaml file exist before scan
function scan_files() {
    local count="$1"
    if [[ "${count}" == 0 ]]; then
        log "INFO: No YAML/CI files found, skipping scan."
        return 1
    else
        return 0
    fi
}

## Loop through files on current workdir
function scan_path() {
    local TARGET="$1"
    local FILES
    FILES=$(find "$TARGET" -type f \( -name "*.yml" -o -name "*.yaml" -o -name "Jenkinsfile" \))

    local COUNT
    COUNT=$(find "$TARGET" -type f \( -name "*.yml" -o -name "*.yaml" -o -name "Jenkinsfile" \) | wc -l)
    scan_files "$COUNT"
    log "INFO: Found $COUNT file(s) to be scanned."

    for FILE in $FILES; do
        log "INFO: Scanning file $FILE"
        grep_keyword "$FILE"
    done
}

## Main function
function main() {
    log "Starting the scanner ..."
    log "INFO: Scanning directory $TARGET"
    
    scan_path "$TARGET"

    log "INFO: Scan finished."
    log "INFO: $CLEAN file(s) clean."
    log "WARN: $ISSUE file(s) with issues."
}

main