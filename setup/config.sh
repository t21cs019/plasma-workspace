#!/usr/bin/env bash
# =============================================================================
# config.sh — plasma-bench 共通設定
# すべてのスクリプトはこのファイルを source して使う
# =============================================================================

# --- インストール先 -----------------------------------------------------------
export PLASMA_BENCH_LIBS="${HOME}/Library"
export OPENBLAS_INSTALL="${PLASMA_BENCH_LIBS}/openblas"
export PLASMA_INSTALL="${PLASMA_BENCH_LIBS}/plasma"

# --- 実行バイナリ -------------------------------------------------------------
export PLASMA_TEST="${PLASMA_INSTALL}/bin/plasmatest"

# NoFlushは手動インストールが必要（README.md参照）
# インストール後に以下のパスを設定してください
export NOFLUSH_PATH="${PLASMA_BENCH_LIBS}/Tune_SSRFB/NoFlush"

# --- ビルド設定 ---------------------------------------------------------------
export NUM_MAKE_JOBS=$(nproc)   # 並列ビルド数（自動検出）

# --- ソースのダウンロードURL --------------------------------------------------
OPENBLAS_VERSION="0.3.28"
export OPENBLAS_URL="https://github.com/OpenMathLib/OpenBLAS/releases/download/v${OPENBLAS_VERSION}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz"

export PLASMA_GIT_URL="https://github.com/icl-utk-edu/plasma.git"

# --- Python / uv 環境 ---------------------------------------------------------
# uv のインストール先（管理者権限不要）
export UV_INSTALL_DIR="${HOME}/.local/bin"
export PATH="${UV_INSTALL_DIR}:${PATH}"

# 仮想環境はリポジトリ直下の .venv（uv のデフォルト）
# pyproject.toml と uv.lock でバージョンを固定・再現する
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PLASMA_BENCH_VENV="${REPO_ROOT}/plasma-bench/.venv"