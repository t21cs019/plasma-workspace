# plasma-workspace

PLASMA 計測・チューニングの **ネイティブ環境ビルド専用**リポジトリ。
OpenBLAS / PLASMA / NoFlush（Tune_SSRFB）をすべて `~/Library` 配下にソースから
ビルドする（**sudo 不要**）。マシンごとに1回だけ実行する。

Python の計測・チューニングコードは別リポジトリ
[`plasma-perf`](https://github.com/t21cs019/plasma-perf) が持つ。両者は
**submodule ではなく、隣り合わせに clone** して使う（`plasma-perf` の
`run_campaign.sh` が `../plasma-workspace/setup/config.sh` を自動で読み込む）。

```
~/Workspace/
├── plasma-workspace/   ← このリポジトリ（ネイティブライブラリのビルド）
└── plasma-perf/        ← 計測・チューニング・可視化（Python）
```

## セットアップ（マシンごとに1回）

```bash
# 1. このリポジトリを clone
git clone https://github.com/t21cs019/plasma-workspace.git
cd plasma-workspace

# 2. 必要ならパス・バージョンを編集（既定は ~/Library, OpenBLAS 0.3.28）
vi setup/config.sh

# 3. ネイティブ環境を一括ビルド（OpenBLAS → PLASMA → NoFlush）
bash setup/install.sh

# 4. 確認
bash setup/check.sh
```

ビルド後、`plasmatest`（tileqr 用）と `NoFlush`（ssrfb 用）が `~/Library` 配下に
入り、`setup/config.sh` が `PLASMA_TEST` / `NOFLUSH_PATH` として export する。

> 共有サーバで sudo が使えない場合でも、すべて `~/Library` 配下にビルドするため
> 追加の権限は不要。ただしビルドツール（gcc/gfortran/make/cmake/git/wget/python3）は
> あらかじめ用意すること（`module load` 等）。`python3` は PLASMA のビルドに必要。

## 計測・チューニング（plasma-perf を隣に clone）

```bash
cd ..
git clone https://github.com/t21cs019/plasma-perf.git
cd plasma-perf

# 計測だけなら追加インストール不要（標準ライブラリで動く）
# チューニング/可視化を使う場合のみ:
python3 -m pip install -e ".[tuning,viz]"

# 計測（tmux ラッパー経由。config.sh は自動で読まれる）
scripts/run_campaign.sh -- python -m plasma_perf bench tileqr --size 4096 --trials 5
scripts/run_campaign.sh -- python -m plasma_perf bench ssrfb --trials 5
```

詳細は plasma-perf の README を参照。

## 含まれるもの

```
setup/
  config.sh              共通設定（インストール先・URL・PLASMA_TEST/NOFLUSH_PATH）
  install.sh             OpenBLAS → PLASMA → NoFlush を一括ビルド
  install_openblas.sh    OpenBLAS をソースからビルド
  install_plasma.sh      PLASMA を clone してビルド（LD_LIBRARY_PATH も ~/.bashrc に追記）
  install_noflush.sh     Tune_SSRFB の NoFlush をビルド
  check.sh               ビルド結果の確認
```
