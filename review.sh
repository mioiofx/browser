#!/usr/bin/env bash
# review.sh — surface decisions flagged as REVIEW_DUE.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV="$SCRIPT_DIR/decisions.csv"

if [[ ! -f "$CSV" ]]; then
  echo "No decisions.csv found at $CSV" >&2
  exit 1
fi

python3 - "$CSV" <<'PYEOF'
import csv, sys

csv_path = sys.argv[1]
SEP = "-" * 70

with open(csv_path, newline="", encoding="utf-8") as fh:
    rows = [r for r in csv.DictReader(fh) if r["status"] == "REVIEW_DUE"]

print(SEP)
if not rows:
    print("  No decisions are currently flagged for review.")
else:
    for i, row in enumerate(rows, 1):
        print(f"  #{i:<3}  Logged:    {row['date']}")
        print(f"        Review due: {row['review_date']}")
        print(f"        Decision:   {row['decision']}")
        print(f"        Reasoning:  {row['reasoning']}")
        print(f"        Expected:   {row['expected_outcome']}")
        print(f"        Status:     {row['status']}")
        print(SEP)
    print(f"  {len(rows)} decision(s) awaiting review.")
print(SEP)
PYEOF
