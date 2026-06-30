#!/bin/sh
set -eu

OUT_DIR="${1:-out}"
ROUTES_FILE="${2:-config/critical-routes.txt}"

if [ ! -d "$OUT_DIR" ]; then
  echo "Artifact directory not found: $OUT_DIR" >&2
  exit 1
fi

if [ ! -f "$ROUTES_FILE" ]; then
  echo "Critical routes file not found: $ROUTES_FILE" >&2
  exit 1
fi

missing=0
while IFS= read -r route || [ -n "$route" ]; do
  # Skip blank lines and comments.
  case "$route" in
    ""|\#*)
      continue
      ;;
  esac

  target="$OUT_DIR/$route"
  if [ ! -f "$target" ]; then
    echo "Missing route in artifact: $route"
    missing=1
  fi
done < "$ROUTES_FILE"

if [ "$missing" -ne 0 ]; then
  echo "Critical route verification failed"
  exit 1
fi

echo "Critical route verification passed"
