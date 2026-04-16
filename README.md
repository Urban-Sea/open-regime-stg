# Open Regime STG — ⚠️ 意図的に脆弱なリポジトリ

> **警告** — このリポジトリは [`Urban-Sea/-`](https://github.com/Urban-Sea/-) (Open Regime の本番リポ、Private) を**意図的に脆弱化したミラー**です。
>
> 用途は **自己ペンテスト / SIEM・インシデント対応訓練 / 攻撃検知の研究** に限定されます。
> - ❌ 本番環境にデプロイしない
> - ❌ 実ユーザーのデータに接続しない
> - ❌ ネットワーク分離または明示的な許可なしに外部公開しない
>
> 上位の設計ドキュメント: 本番リポの `tasks/attack-lab/README.md`

---

## このリポの位置づけ

本番コードベースの完全コピーに **意図的なセキュリティ回帰 (脆弱性の復活)** を重ねた環境。各脆弱性は以下のいずれかに対応する:
- 過去の監査 (`tasks/done/security-audit-2026-02-28.md` / `security-audit-2026-03-01.md`) で修正された本物の findings を再導入
- Red Team 訓練のカバレッジを広げるために新規追加 (SQLi / SSRF / ディレクトリトラバーサル)

脆弱性は **unified-diff パッチ**として `patches/` 配下で管理する。目的:
1. いつでも `upstream` (本番) を取り込めて、かつ脆弱性セットを失わない
2. クリーンな clone から脆弱性セットを再構築できる
3. どのファイルが「汚染」されているかを各 patch を見れば監査できる

---

## デプロイ対象

| 項目 | 値 |
|---|---|
| VM | Oracle Cloud Ampere A1 1GB (`stg-vm`) |
| Public IP | `161.33.35.81` |
| ドメイン | `stg.open-regime.com` (Cloudflare DNS、**Proxy OFF**) |
| TLS | Let's Encrypt (`certbot certonly --standalone`) |
| デプロイディレクトリ | `/opt/open-regime/` |
| Compose ファイル | `docker-compose.stg.yml` |

デプロイの流れ: このリポの `main` に push → GitHub Actions (`.github/workflows/deploy-stg.yml`) → STG VM に SCP でイメージ転送 → `docker compose -f docker-compose.stg.yml up -d`

---

## ワークフロー

### 初回セットアップ

```bash
git clone git@github.com:Urban-Sea/open-regime-stg.git
cd open-regime-stg
git remote add upstream https://github.com/Urban-Sea/-.git
```

### 本番 (upstream) から同期 + 脆弱性 patch の再適用

```bash
./patches/sync-upstream.sh
# 1. git fetch upstream
# 2. git rebase upstream/main
# 3. ./patches/apply.sh (全 patch を再適用)
```

### 新しい脆弱性 patch を追加する

```bash
# 1. コードを編集して脆弱性を導入する
# 2. diff を patch として保存
git diff > patches/NN-ID-short-description.patch
# 3. working tree をリセットして patch が綺麗に当たるか検証
git checkout -- .
./patches/apply.sh
# 4. [INTENTIONAL-VULN] prefix で commit
git add patches/NN-ID-*.patch
git commit -m "[INTENTIONAL-VULN] <ID> <description>"
git push origin main
```

### Commit message 規約

アプリコードに触れる commit は必ず次のいずれかの prefix をつける:
- `[INTENTIONAL-VULN]` — 脆弱性 patch の追加・更新
- `stg:` — STG 専用インフラの変更 (`docker-compose.stg.yml`, nginx template, deploy workflow など)
- `sync:` — upstream (本番) からの取り込み

どの prefix もついていない commit は怪しい。push する前に見直すこと。

---

## 絶対にやらないこと

- ❌ このリポの `main` を本番リポの `main` に push しない
- ❌ `.env.stg` に本番の secret を混ぜない
- ❌ このリポを Public にしない (GitHub visibility は **Private** 固定)
- ❌ `open-regime.com` の A レコードを STG VM に向けない — 必ず `stg.open-regime.com`

---

## 関連リポ・ドキュメント

- 本番リポ (`upstream`): `git@github.com:Urban-Sea/-.git`
- 攻撃元リポ: `git@github.com:Urban-Sea/attack-vm.git`
- 攻撃ラボ設計書: 本番リポの `tasks/attack-lab/README.md`
- Phase 7 進捗表: 本番リポの `tasks/順番.md`
