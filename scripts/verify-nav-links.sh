#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-out}"
NAV_SOURCE="${2:-source/index.html.md.erb}"

if [[ ! -d "$OUT_DIR" ]]; then
  echo "Artifact directory not found: $OUT_DIR" >&2
  exit 1
fi

if [[ ! -f "$NAV_SOURCE" ]]; then
  echo "Navigation source file not found: $NAV_SOURCE" >&2
  exit 1
fi

# Extract relative markdown links from nav source, skip external/anchor/mail links.
links=$(sed -n 's/.*](\([^)]*\)).*/\1/p' "$NAV_SOURCE" | grep -vE '^(https?://|mailto:|#)' || true)

missing=0
while IFS= read -r href || [[ -n "$href" ]]; do
  [[ -z "$href" ]] && continue

  normalized="${href#/}"
  if [[ "$normalized" != *.html ]]; then
    continue
  fi

  if [[ ! -f "$OUT_DIR/$normalized" ]]; then
    echo "Navigation link target missing in artifact: $normalized"
    missing=1
  fi
done <<< "$links"

if [[ "$missing" -ne 0 ]]; then
  echo "Navigation-to-output verification failed"
  exit 1
fi

echo "Navigation-to-output verification passed"
