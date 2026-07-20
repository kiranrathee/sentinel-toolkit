#!/usr/bin/env bash
# ============================================================
# modules/backup.sh — compresses BACKUP_SRC into a timestamped
# archive under BACKUP_DEST, then prunes archives older than
# BACKUP_KEEP_DAYS.
# ============================================================
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$MODULE_DIR/server.conf"
MODULE_NAME="backup"
source "$MODULE_DIR/utils/common.sh"

log_info "Backup started for source: $BACKUP_SRC"
mkdir -p "$BACKUP_DEST"

stamp="$(date '+%Y%m%d-%H%M%S')"
archive="$BACKUP_DEST/sentinel-backup-${stamp}.tar.gz"

if tar -czf "$archive" -C / "${BACKUP_SRC#/}" 2>/dev/null; then
    size="$(du -h "$archive" | cut -f1)"
    log_ok "Archive created: $archive (size: $size)"
else
    log_error "Backup failed while archiving $BACKUP_SRC"
    exit 1
fi

removed=0
while IFS= read -r old_file; do
    rm -f "$old_file"
    removed=$((removed + 1))
done < <(find "$BACKUP_DEST" -name 'sentinel-backup-*.tar.gz' -mtime +"$BACKUP_KEEP_DAYS")

log_info "Retention cleanup removed $removed archive(s) older than ${BACKUP_KEEP_DAYS}d"
log_ok "Backup module finished"
