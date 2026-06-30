#!/bin/sh
set -eu

OUT_DIR="${1:-out}"

if [ ! -d "$OUT_DIR" ]; then
  echo "Artifact directory not found: $OUT_DIR" >&2
  exit 1
fi

# Validate only local artifact links (relative and root-relative).
# External/canonical links are checked separately by source-level link checks.
missing_file=$(mktemp)
html_list_file=$(mktemp)
trap 'rm -f "$missing_file" "$html_list_file"' EXIT INT TERM

find "$OUT_DIR" -type f -name '*.html' | sort > "$html_list_file"

while IFS= read -r html_file; do
  link_list_file=$(mktemp)
  grep -Eo '(href|src)="[^"]+"' "$html_file" | sed -E 's/^[^=]+="([^"]+)"/\1/' > "$link_list_file" || true

  while IFS= read -r raw_url; do
    url="$raw_url"

    # Skip anchors and non-file schemes.
    [ -z "$url" ] && continue
    case "$url" in
      \#*|mailto:*|tel:*|javascript:*|data:*|http://*|https://*|//*)
        continue
        ;;
    esac

    # Remove query string and fragment before filesystem checks.
    url="${url%%\#*}"
    url="${url%%\?*}"
    [ -z "$url" ] && continue

    case "$url" in
      /*)
        candidate="$OUT_DIR$url"
        ;;
      *)
        candidate="$(dirname "$html_file")/$url"
        ;;
    esac

    case "$candidate" in
      */)
        candidate="${candidate}index.html"
        ;;
      *)
        if [ -d "$candidate" ]; then
          candidate="${candidate}/index.html"
        fi
        ;;
    esac

    if [ ! -e "$candidate" ]; then
      echo "Missing built link target: $url (from $html_file)" | tee -a "$missing_file"
    fi
  done < "$link_list_file"

  rm -f "$link_list_file"
done < "$html_list_file"

if [ -s "$missing_file" ]; then
  echo "Built-site local link verification failed"
  exit 1
fi

echo "Built-site local link verification passed"
