# plasma-workspace

PLASMA計測・チューニング環境の一括セットアップリポジトリ。
このリポジトリをcloneするだけで全環境が整う。

## 初回セットアップ

```bash
# 1. このリポジトリをclone（submoduleも含めて取得）
git clone --recurse-submodules git@github.com:t21cs019/plasma-workspace.git
cd plasma-workspace

# 2. パス・バージョン設定を編集
vi setup/config.sh

# 3. 一括セットアップ
bash setup/install.sh

# 4. 確認
bash setup/check.sh
```

## submoduleの更新

```bash
git submodule update --remote
```
