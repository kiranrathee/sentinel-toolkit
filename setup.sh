#!/usr/bin/env bash
# ============================================================
# setup.sh — installs Sentinel Toolkit onto a Linux server.
#   1. Copies the project to /opt/sentinel-toolkit
#   2. Makes every module + sentinel.sh executable
#   3. Creates the log directory
#   4. Installs the schedule into root's own crontab
#      (via `crontab -l | ... | crontab -`, not /etc/cron.d —
#      this keeps everything self-contained under root's crontab)
# Run with: sudo ./setup.sh
# ============================================================
set -euo pipefail

INSTALL_DIR="/opt/sentinel-toolkit"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">> [1/4] Installing to $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -r "$SRC_DIR/modules" "$SRC_DIR/utils" "$SRC_DIR/server.conf" "$SRC_DIR/sentinel.sh" "$INSTALL_DIR/"

echo ">> [2/4] Setting execute permissions"
chmod +x "$INSTALL_DIR/sentinel.sh" "$INSTALL_DIR/modules/"*.sh

echo ">> [3/4] Creating log directory"
mkdir -p /var/log/sentinel

echo ">> [4/4] Installing cron schedule into root's crontab"
# Strip any previous sentinel entries, then append the fresh schedule.
( crontab -l 2>/dev/null | grep -v 'sentinel-toolkit' | grep -v '^MAILTO=""$' ; \
  sed "s#/opt/sentinel-toolkit#$INSTALL_DIR#g" "$SRC_DIR/cron/sentinel.cron" ) | crontab -

echo ">> Done. Sentinel Toolkit is deployed and scheduled."
echo ">> Try it now:   sudo $INSTALL_DIR/sentinel.sh all"
echo ">> Watch logs:   tail -f /var/log/sentinel/*.log"
echo ">> See schedule: sudo crontab -l"
