# Open Regime STG — ⚠️ INTENTIONALLY VULNERABLE

> **WARNING** — This repository is an **intentionally vulnerable mirror** of [`Urban-Sea/-`](https://github.com/Urban-Sea/-) (the private production repo of Open Regime).
>
> It exists for **self-penetration testing, SIEM / IR training, and attack-detection research only**.
> - **DO NOT** deploy this code to production.
> - **DO NOT** connect it to real user data.
> - **DO NOT** run this anywhere reachable without network isolation or explicit authorization.
>
> The parent design document lives at `tasks/attack-lab/README.md` in the production repo.

---

## What this repo is

A full copy of the production codebase with **intentional security regressions** re-introduced. Each regression maps to a past real finding from `tasks/done/security-audit-2026-02-28.md` / `security-audit-2026-03-01.md` or is newly added for red-team drill coverage (SQLi / SSRF / directory traversal).

Regressions are managed as **unified-diff patches** under `patches/` so we can:
1. Sync `upstream` (production) at any time without losing the vulnerabilities.
2. Reconstruct the vulnerability set on a fresh clone.
3. Audit exactly what is poisoned by reading each patch.

---

## Deployment target

| Item | Value |
|---|---|
| VM | Oracle Cloud Ampere A1 1GB (`stg-vm`) |
| Public IP | `161.33.35.81` |
| Domain | `stg.open-regime.com` (Cloudflare DNS, **Proxy OFF**) |
| TLS | Let's Encrypt (`certbot certonly --standalone`) |
| Deploy dir | `/opt/open-regime-stg/` |
| Compose file | `docker-compose.stg.yml` |

Deploy flow: push to `main` on this repo → GitHub Actions (`.github/workflows/deploy-stg.yml`) → SCP images to STG VM → `docker compose -f docker-compose.stg.yml up -d`.

---

## Workflow

### One-time setup

```bash
git clone git@github.com:Urban-Sea/open-regime-stg.git
cd open-regime-stg
git remote add upstream https://github.com/Urban-Sea/-.git
```

### Sync from production + re-apply vulnerabilities

```bash
./patches/sync-upstream.sh
# 1. git fetch upstream
# 2. git rebase upstream/main
# 3. ./patches/apply.sh (re-applies all vulnerability patches on top)
```

### Add a new vulnerability patch

```bash
# 1. Edit the code to introduce the vulnerability
# 2. Save the diff as a patch
git diff > patches/13-NEW-short-description.patch
# 3. Reset working tree and verify the patch applies cleanly
git checkout -- .
./patches/apply.sh
# 4. Commit with [INTENTIONAL-VULN] prefix
git add patches/13-*.patch
git commit -m "[INTENTIONAL-VULN] add <description>"
git push origin main
```

### Commit message convention

All commits that affect live application code MUST be prefixed:
- `[INTENTIONAL-VULN]` — introduces / updates a vulnerability patch
- `stg:` — STG-only infrastructure (`docker-compose.stg.yml`, nginx template, deploy workflow)
- `sync:` — merge from upstream production

Any commit without one of these prefixes is a smell — review before pushing.

---

## Never do

- ❌ Push this repo's `main` to the production repo's `main`
- ❌ Mix production secrets into `.env.stg`
- ❌ Open this repo publicly (keep GitHub visibility = **Private**)
- ❌ Point `open-regime.com` A record at the STG VM — always `stg.open-regime.com`

---

## See also

- Production repo (`upstream`): `git@github.com:Urban-Sea/-.git`
- Attack ops repo: `git@github.com:Urban-Sea/attack-vm.git`
- Attack lab design: `tasks/attack-lab/README.md` (production repo)
- Phase 7 progress: `tasks/順番.md` (production repo)
