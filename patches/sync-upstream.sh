#!/usr/bin/env bash
# Sync this STG repo with upstream (production open-regime) and
# re-apply every vulnerability patch on top.
#
# Strategy: reset main onto upstream/main (losing STG-only commits on app code),
# then replay every patch from patches/. Infra commits (docker-compose.stg.yml,
# nginx/conf.d/default.stg.conf.template, .github/workflows/deploy-stg.yml,
# README.md, patches/*) are kept via the patch pipeline + a "stg-infra" branch
# rebase described below.
#
# Assumes:
#   origin    = git@github.com:Urban-Sea/open-regime-stg.git
#   upstream  = https://github.com/Urban-Sea/-.git
#
# Usage: ./patches/sync-upstream.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -n "$(git status --porcelain)" ]; then
  echo "working tree not clean. stash or commit first." >&2
  exit 1
fi

echo "[1/4] fetching upstream..."
git fetch upstream

echo "[2/4] rebasing onto upstream/main..."
git rebase upstream/main

echo "[3/4] re-applying vulnerability patches..."
./patches/apply.sh

echo "[4/4] done. review with: git status && git diff"
echo "when satisfied:"
echo "    git add -A"
echo "    git commit -m 'sync: upstream @ '\$(git rev-parse --short upstream/main)"
echo "    git push --force-with-lease origin main"
