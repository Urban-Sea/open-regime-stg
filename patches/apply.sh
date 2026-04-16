#!/usr/bin/env bash
# Apply every vulnerability patch under patches/ in numerical order.
# Aborts on the first failure and leaves the tree dirty for inspection.
set -euo pipefail

cd "$(dirname "$0")/.."

shopt -s nullglob
patches=(patches/[0-9][0-9]-*.patch)

if [ ${#patches[@]} -eq 0 ]; then
  echo "no patches found under patches/"
  exit 0
fi

echo "applying ${#patches[@]} patch(es)..."
for p in "${patches[@]}"; do
  echo "  -> $p"
  git apply --whitespace=nowarn "$p"
done
echo "all patches applied. working tree is now vulnerable."
