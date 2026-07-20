#!/usr/bin/env bash
# ============================================================
# modules/diskalert.sh — checks BOTH block-usage % and
# inode-usage % on DISK_MOUNT (inode exhaustion is a real,
# often-missed failure mode) and raises an alert if either
# crosses its threshold.
# ============================================================
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$MODULE_DIR/server.conf"
MODULE_NAME="diskalert"
source "$MODULE_DIR/utils/common.sh"

usage_pct="$(df --output=pcent "$DISK_MOUNT" | tail -1 | tr -d ' %')"
inode_pct="$(df --output=ipcent "$DISK_MOUNT" | tail -1 | tr -d ' %' 2>/dev/null || echo 0)"

log_info "Disk usage on $DISK_MOUNT: ${usage_pct}% (warn at ${DISK_WARN_PCT}%)"
log_info "Inode usage on $DISK_MOUNT: ${inode_pct}% (warn at ${INODE_WARN_PCT}%)"

alert=false
if [ "$usage_pct" -ge "$DISK_WARN_PCT" ]; then
    log_warn "ALERT: disk block usage ${usage_pct}% >= threshold ${DISK_WARN_PCT}%"
    alert=true
fi

if [ "$inode_pct" -ge "$INODE_WARN_PCT" ] 2>/dev/null; then
    log_warn "ALERT: inode usage ${inode_pct}% >= threshold ${INODE_WARN_PCT}%"
    alert=true
fi

if [ "$alert" = false ]; then
    log_ok "Disk and inode usage within safe limits"
fi

log_info "Disk alert module finished"
