#!/usr/bin/env bash
# ============================================================
# uninstall.sh — removes the cron schedule and (optionally)
# the installed files. Logs and backups are left untouched
# unless you pass --purge.
# ============================================================
set -euo pipefail

INSTALL_DIR="/opt/sentinel-toolkit"

echo ">> Removing Sentinel entries from root's crontab"
( crontab -l 2>/dev/null | grep -v 'sentinel-toolkit' | grep -v '^MAILTO=""$' ) | crontab - || true

echo ">> Removing installed files at $INSTALL_DIR"
rm -rf "$INSTALL_DIR"

if [ "${1:-}" = "--purge" ]; then
    echo ">> --purge given: removing logs and backups too"
    rm -rf /var/log/sentinel /var/backups/sentinel
fi

echo ">> Sentinel Toolkit removed."
