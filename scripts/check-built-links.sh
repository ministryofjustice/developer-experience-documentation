#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-out}"

if [[ ! -d "$OUT_DIR" ]]; then
  echo "Artifact directory not found: $OUT_DIR" >&2
  exit 1
fi

if command -v lychee >/dev/null 2>&1; then
  # Check generated html files for broken links in deployable output.
  lychee --verbose --no-progress "$OUT_DIR/**/*.html" --accept 200,301,302,401,403,429
else
  echo "lychee not installed; skipping built-site link check"
  echo "Install lychee to enable this check locally."
fi
