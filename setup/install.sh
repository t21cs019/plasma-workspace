#!/usr/bin/env bash
# =============================================================================
# install.sh — ネイティブ計測環境を一括ビルドする（OpenBLAS / PLASMA / NoFlush）
#
# 使い方:
#   git clone https://github.com/t21cs019/plasma-workspace.git
#   cd plasma-workspace
#   bash setup/install.sh
#
# 実行順序:
#   1. OpenBLAS
#   2. PLASMA（system の python3 / cmake / gfortran / git が必要）
#   3. NoFlush（Tune_SSRFB）
#
# Python の計測・チューニング環境は計測リポジトリ plasma-perf 側で用意する
# （このスクリプトの最後に案内する）。
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================================"
echo " plasma-workspace ネイティブ環境ビルド開始"
echo "======================================================"
echo ""

# --- 前提ツールの確認（不足なら早期に停止し、案内する）----------------------
missing=()
for cmd in gcc g++ make cmake gfortran git wget curl python3; do
    command -v "${cmd}" &>/dev/null || missing+=("${cmd}")
done
if [ "${#missing[@]}" -gt 0 ]; then
    echo "[ERROR] ビルドに必要なツールが不足しています: ${missing[*]}"
    echo ""
    echo "  家庭マシンなら次で一括導入できます（sudo 使用）:"
    echo "      bash setup/bootstrap_home.sh"
    echo "  もしくは手動で:"
    echo "      sudo apt-get install -y build-essential gfortran cmake git wget curl python3"
    echo "  （共有サーバでは module load 等で用意してください）"
    exit 1
fi

# 1. OpenBLAS
echo ">>> [1/3] OpenBLAS のインストール"
bash "${SCRIPT_DIR}/install_openblas.sh"
echo ""

# 2. PLASMA
echo ">>> [2/3] PLASMA のインストール"
bash "${SCRIPT_DIR}/install_plasma.sh"
echo ""

# 3. NoFlush（Tune_SSRFB）
echo ">>> [3/3] NoFlush（Tune_SSRFB）のインストール"
bash "${SCRIPT_DIR}/install_noflush.sh"
echo ""

echo "======================================================"
echo " ネイティブ環境のビルド完了！"
echo ""
echo " ビルドの確認:"
echo "   bash setup/check.sh"
echo ""
echo " 計測・チューニング（別リポジトリ plasma-perf を隣に clone）:"
echo "   git clone https://github.com/t21cs019/plasma-perf.git"
echo "   cd plasma-perf"
echo "   # 計測だけなら追加インストール不要（標準ライブラリで動く）"
echo "   # チューニング/可視化を使う場合（uv）: bash scripts/setup_python.sh"
echo "   scripts/run_campaign.sh -- python -m plasma_perf bench tileqr --trials 5"
echo "======================================================"
