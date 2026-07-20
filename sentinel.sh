#!/usr/bin/env bash
# ============================================================
# sentinel.sh — single entry point to run any/all modules by
# hand. Cron calls the modules directly (see cron/sentinel.cron)
# but a human uses this for manual runs, demos, and status checks.
#
# Usage:
#   ./sentinel.sh backup
#   ./sentinel.sh logclean
#   ./sentinel.sh service
#   ./sentinel.sh disk
#   ./sentinel.sh all        # run every module once, in order
#   ./sentinel.sh status     # tail the last few lines of every log
# ============================================================
set -euo pipefail

HOME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOME_DIR/server.conf"

usage() {
    echo "Usage: $0 {backup|logclean|service|disk|all|status}"
    exit 1
}

[ $# -eq 1 ] || usage

case "$1" in
    backup)   "$HOME_DIR/modules/backup.sh" ;;
    logclean) "$HOME_DIR/modules/logclean.sh" ;;
    service)  "$HOME_DIR/modules/servicecheck.sh" ;;
    disk)     "$HOME_DIR/modules/diskalert.sh" ;;
    all)
        "$HOME_DIR/modules/backup.sh"
        "$HOME_DIR/modules/logclean.sh"
        "$HOME_DIR/modules/servicecheck.sh"
        "$HOME_DIR/modules/diskalert.sh"
        ;;
    status)
        for f in "$LOG_DIR"/*.log; do
            [ -e "$f" ] || continue
            echo "----- $f -----"
            tail -n 5 "$f"
            echo
        done
        ;;
    *) usage ;;
esac
