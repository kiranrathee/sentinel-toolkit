#!/usr/bin/env bash
# ============================================================
# modules/servicecheck.sh — watchdog for the services listed
# in WATCH_SERVICES. Restarts a dead service automatically
# when AUTO_RESTART=true and logs the outcome either way.
# ============================================================
set -uo pipefail   # no -e: one bad service shouldn't stop the whole loop

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$MODULE_DIR/server.conf"
MODULE_NAME="servicecheck"
source "$MODULE_DIR/utils/common.sh"

log_info "Watchdog sweep over: ${WATCH_SERVICES[*]}"

for svc in "${WATCH_SERVICES[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        log_ok "$svc is UP"
        continue
    fi

    log_warn "$svc is DOWN"
    if [ "$AUTO_RESTART" = true ]; then
        if systemctl restart "$svc" 2>/dev/null; then
            log_ok "$svc restarted successfully"
        else
            log_error "$svc restart attempt failed — needs manual attention"
        fi
    fi
done

log_info "Watchdog sweep finished"
