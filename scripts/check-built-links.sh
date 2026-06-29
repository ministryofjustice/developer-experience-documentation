#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-out}"

if [[ ! -d "$OUT_DIR" ]]; then
  echo "Artifact directory not found: $OUT_DIR" >&2
  exit 1
fi

# Validate only local artifact links (relative and root-relative).
# External/canonical links are checked separately by source-level link checks.
missing=0

while IFS= read -r html_file; do
  while IFS= read -r raw_url; do
    url="$raw_url"

    # Skip anchors and non-file schemes.
    [[ -z "$url" || "$url" == \#* ]] && continue
    [[ "$url" =~ ^(mailto:|tel:|javascript:|data:|https?://|//) ]] && continue

    # Remove query string and fragment before filesystem checks.
    url="${url%%\#*}"
    url="${url%%\?*}"
    [[ -z "$url" ]] && continue

    if [[ "$url" == /* ]]; then
      candidate="$OUT_DIR$url"
    else
      candidate="$(dirname "$html_file")/$url"
    fi

    if [[ "$candidate" == */ ]]; then
      candidate="${candidate}index.html"
    elif [[ ! -e "$candidate" && -d "$candidate" ]]; then
      candidate="${candidate}/index.html"
    fi

    if [[ ! -e "$candidate" ]]; then
      echo "Missing built link target: $url (from $html_file)"
      missing=1
    fi
  done < <(grep -Eo '(href|src)="[^"]+"' "$html_file" | sed -E 's/^[^=]+="([^"]+)"/\1/' || true)
done < <(find "$OUT_DIR" -type f -name '*.html' | sort)

if [[ "$missing" -ne 0 ]]; then
  echo "Built-site local link verification failed"
  exit 1
fi

echo "Built-site local link verification passed"
