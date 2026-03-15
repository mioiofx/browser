#!/usr/bin/env bash
# setup_cron.sh — install (or remove) the daily check_reviews cron job.
# Usage:
#   ./setup_cron.sh install    # add cron entry (default)
#   ./setup_cron.sh remove     # remove cron entry
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/check_reviews.sh"
LOG_FILE="$SCRIPT_DIR/cron_check_reviews.log"
CRON_TAG="# decision-logger-check-reviews"

ACTION="${1:-install}"

if [[ "$ACTION" == "remove" ]]; then
  crontab -l 2>/dev/null | grep -v "$CRON_TAG" | crontab -
  echo "Cron job removed."
  exit 0
fi

if [[ "$ACTION" != "install" ]]; then
  echo "Usage: $0 [install|remove]" >&2
  exit 1
fi

# Ensure the check script is executable
chmod +x "$CHECK_SCRIPT"

# Build the cron line: run daily at 08:00
CRON_LINE="0 8 * * * $CHECK_SCRIPT >> $LOG_FILE 2>&1 $CRON_TAG"

# Add only if not already present
EXISTING="$(crontab -l 2>/dev/null || true)"
if echo "$EXISTING" | grep -qF "$CRON_TAG"; then
  echo "Cron job already installed. No changes made."
else
  (echo "$EXISTING"; echo "$CRON_LINE") | crontab -
  echo "Cron job installed:"
  echo "  $CRON_LINE"
  echo ""
  echo "Logs will be written to: $LOG_FILE"
fi
