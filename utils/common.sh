#!/usr/bin/env bash
# ============================================================
# utils/common.sh — shared helper functions used by every module.
# Provides: log_info / log_warn / log_error / log_ok
# Each writes a timestamped line to screen + to
# $LOG_DIR/<module>.log, and (optionally) mirrors WARN/ERROR
# lines to the system log via `logger`.
# ============================================================

mkdir -p "$LOG_DIR" 2>/dev/null

# Colors (auto-disabled if output isn't a real terminal)
if [ -t 1 ]; then
    C_GREEN="\033[0;32m"; C_YELLOW="\033[0;33m"; C_RED="\033[0;31m"; C_BLUE="\033[0;34m"; C_RESET="\033[0m"
else
    C_GREEN=""; C_YELLOW=""; C_RED=""; C_BLUE=""; C_RESET=""
fi

_write_log() {
    local level="$1" color="$2" message="$3"
    local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
    local plain_line="[$ts] [$MODULE_NAME] [$level] $message"

    echo -e "${color}${plain_line}${C_RESET}"
    echo "$plain_line" >> "$LOG_DIR/${MODULE_NAME}.log"

    if [ "$USE_SYSLOG" = true ] && [ "$level" != "INFO" ] && command -v logger >/dev/null 2>&1; then
        logger -t "sentinel-${MODULE_NAME}" "$message"
    fi
}

log_info()  { _write_log "INFO"  "$C_BLUE"   "$1"; }
log_ok()    { _write_log "OK"    "$C_GREEN"  "$1"; }
log_warn()  { _write_log "WARN"  "$C_YELLOW" "$1"; }
log_error() { _write_log "ERROR" "$C_RED"    "$1"; }
