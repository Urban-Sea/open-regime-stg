# Vulnerability patches

Unified-diff patches that re-introduce intentional security regressions on top of `upstream/main` (the production Open Regime repo).

## Numbering

| Range | Meaning |
|---|---|
| `01-09` | Critical (C) findings from audit 2026-02-28 / 2026-03-01 |
| `10-19` | High (H) findings |
| `20-29` | Medium (M) findings |
| `30-39` | Newly introduced (SQLi / SSRF / traversal) — no audit precedent |

Filename: `NN-<ID>-<kebab-case-description>.patch`

## Scripts

- `apply.sh` — apply every patch in numerical order
- `sync-upstream.sh` — fetch + rebase onto `upstream/main`, then re-apply all patches

## Recording a new patch

```bash
# 1. make sure working tree is clean
git status

# 2. edit the code to introduce the vulnerability

# 3. capture the diff (stage first so renames/adds are captured)
git diff --cached > patches/NN-ID-description.patch   # after git add
# or for unstaged changes:
git diff > patches/NN-ID-description.patch

# 4. reset the working tree and verify the patch reapplies cleanly
git reset --hard HEAD
./patches/apply.sh

# 5. commit
git add patches/NN-ID-description.patch
git commit -m "[INTENTIONAL-VULN] <ID> <description>"
```
