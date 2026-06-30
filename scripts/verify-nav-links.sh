#!/bin/sh
set -eu

OUT_DIR="${1:-out}"
NAV_SOURCE="${2:-source/index.html.md.erb}"

if [ ! -d "$OUT_DIR" ]; then
  echo "Artifact directory not found: $OUT_DIR" >&2
  exit 1
fi

if [ ! -f "$NAV_SOURCE" ]; then
  echo "Navigation source file not found: $NAV_SOURCE" >&2
  exit 1
fi

# Extract relative markdown links from nav source, skip external/anchor/mail links.
links=$(sed -n 's/.*](\([^)]*\)).*/\1/p' "$NAV_SOURCE" | grep -vE '^(https?://|mailto:|#)' || true)

missing_file=$(mktemp)
trap 'rm -f "$missing_file"' EXIT INT TERM

printf '%s\n' "$links" | while IFS= read -r href || [ -n "$href" ]; do
  [ -z "$href" ] && continue

  normalized=$(printf '%s' "$href" | sed 's#^/##')
  case "$normalized" in
    *.html) ;;
    *)
      continue
      ;;
  esac

  if [ ! -f "$OUT_DIR/$normalized" ]; then
    echo "Navigation link target missing in artifact: $normalized" | tee -a "$missing_file"
  fi
done

if [ -s "$missing_file" ]; then
  echo "Navigation-to-output verification failed"
  exit 1
fi

echo "Navigation-to-output verification passed"
