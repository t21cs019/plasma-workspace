#!/usr/bin/env bash
# =============================================================================
# install_python_deps.sh — uv をインストールし、pyproject.toml から環境を構築
# 管理者権限不要。
# uv sync により uv.lock の内容を使って全マシンで同一環境を再現する。
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

echo "======================================================"
echo " Python 環境のセットアップ（uv 使用）"
echo " 仮想環境: ${PLASMA_BENCH_VENV}"
echo "======================================================"

# --- 1. uv のインストール -----------------------------------------------------
if command -v uv &>/dev/null; then
    echo "[1/2] uv はすでにインストール済みです: $(uv --version)"
else
    echo "[1/2] uv をインストールしています..."
    if command -v curl &>/dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    elif command -v wget &>/dev/null; then
        wget -qO- https://astral.sh/uv/install.sh | sh
    else
        echo "[ERROR] curl も wget も見つかりません。どちらかをインストールしてください。"
        exit 1
    fi

    export PATH="${UV_INSTALL_DIR}:${PATH}"

    if ! command -v uv &>/dev/null; then
        echo "[ERROR] uv のインストールに失敗しました。"
        echo "        curl が使えるか確認してください。"
        exit 1
    fi
    echo "       インストール完了: $(uv --version)"
fi

# --- uv の PATH を ~/.bashrc に永続化 -----------------------------------------
BASHRC="${HOME}/.bashrc"
UV_PATH_LINE='export PATH="${HOME}/.local/bin:${PATH}"'

if ! grep -qF "${UV_PATH_LINE}" "${BASHRC}" 2>/dev/null; then
    echo "${UV_PATH_LINE}" >> "${BASHRC}"
    echo "       PATH を ~/.bashrc に追記しました。"
fi

# --- 2. uv sync で依存パッケージを一括インストール ----------------------------
echo "[2/2] pyproject.toml から依存パッケージをインストールしています..."
cd "${REPO_ROOT}/plasma-bench"
uv sync

echo ""
echo "[完了] Python 環境のセットアップが完了しました。"
echo ""
echo "動作確認:"
echo "  ${PLASMA_BENCH_VENV}/bin/python --version"
echo "  ${PLASMA_BENCH_VENV}/bin/python -c \"import optuna; print('optuna OK')\""