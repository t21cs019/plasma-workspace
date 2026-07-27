#!/usr/bin/env bash
# =============================================================================
# bootstrap_home.sh — 家庭マシン専用の初期セットアップ（sudo 使用）
#
# ビルドに必要な apt パッケージを一括導入し、Tailscale を入れる。
# この後に setup/install.sh で OpenBLAS / PLASMA / NoFlush をビルドする。
#
# ⚠️ 家庭マシン専用。研究室・大学の共有サーバでは実行しないこと。
#    （sudo でシステムに変更を加える。共有サーバでは apt / tailscale を使わない）
#
# 使い方:
#   bash setup/bootstrap_home.sh
#   ASSUME_YES=1 bash setup/bootstrap_home.sh          # 確認プロンプトを省略
#   INSTALL_TAILSCALE=0 bash setup/bootstrap_home.sh   # Tailscale を入れない
# =============================================================================
set -euo pipefail

INSTALL_TAILSCALE="${INSTALL_TAILSCALE:-1}"
HOSTNAME_SHORT="$(hostname -s)"

echo "======================================================"
echo " 家庭マシン初期セットアップ: ${HOSTNAME_SHORT}"
echo " （sudo でシステムに変更を加えます。共有サーバでは実行しないでください）"
echo "======================================================"

# --- 誤爆防止の確認 -----------------------------------------------------------
if [ "${ASSUME_YES:-0}" != "1" ]; then
    read -r -p "このマシンは自分専用の家庭マシンですか？続行しますか？ [y/N] " ans
    case "${ans}" in
        [Yy]*) ;;
        *) echo "中止しました。"; exit 1 ;;
    esac
fi

# --- 1. apt 依存パッケージの一括導入 ------------------------------------------
# OpenBLAS / PLASMA / NoFlush のビルドと uv 導入に必要なもの一式。
echo ""
echo ">>> [1/2] apt 依存パッケージの導入"
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    gfortran \
    cmake \
    git \
    wget \
    curl \
    ca-certificates \
    pkg-config \
    python3 \
    python3-venv \
    numactl

echo "[OK] ビルドツールチェーンを導入しました。"

# --- 2. Tailscale の導入 ------------------------------------------------------
echo ""
echo ">>> [2/2] Tailscale の導入"
if [ "${INSTALL_TAILSCALE}" = "1" ]; then
    if command -v tailscale &>/dev/null; then
        echo "[SKIP] tailscale はすでに導入済みです: $(tailscale version | head -1)"
    else
        echo "tailscale を導入しています..."
        curl -fsSL https://tailscale.com/install.sh | sh
    fi
    echo ""
    echo "  認証するには次を実行してください（ブラウザ認証）:"
    echo "    sudo tailscale up --hostname=${HOSTNAME_SHORT}"
    echo "  認証後、MagicDNS 有効なら 'ssh ${USER}@${HOSTNAME_SHORT}' で接続できます。"
else
    echo "[SKIP] INSTALL_TAILSCALE=0 のためスキップしました。"
fi

echo ""
echo "======================================================"
echo " 初期セットアップ完了: ${HOSTNAME_SHORT}"
echo ""
echo " 次のステップ:"
echo "   1. ネイティブ環境をビルド:   bash setup/install.sh"
echo "   2. 確認:                     bash setup/check.sh"
echo "   3. Python 環境（tuning/viz）: cd ../plasma-perf && bash scripts/setup_python.sh"
echo "======================================================"
