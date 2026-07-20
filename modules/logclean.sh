#!/usr/bin/env bash
# ============================================================
# modules/logclean.sh — removes stale log files from
# LOGCLEAN_DIR that are older than LOGCLEAN_KEEP_DAYS, and
# reports how much space was reclaimed.
# ============================================================
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$MODULE_DIR/server.conf"
MODULE_NAME="logclean"
source "$MODULE_DIR/utils/common.sh"

log_info "Scanning $LOGCLEAN_DIR for '$LOGCLEAN_PATTERN' older than ${LOGCLEAN_KEEP_DAYS}d"

freed_kb=0
count=0
while IFS= read -r old_log; do
    size_kb="$(du -k "$old_log" 2>/dev/null | cut -f1)"
    freed_kb=$((freed_kb + size_kb))
    rm -f "$old_log"
    count=$((count + 1))
done < <(find "$LOGCLEAN_DIR" -type f -name "$LOGCLEAN_PATTERN" -mtime +"$LOGCLEAN_KEEP_DAYS" 2>/dev/null)

log_ok "Deleted $count file(s), freed approximately ${freed_kb} KB"
log_ok "Log cleanup module finished"
