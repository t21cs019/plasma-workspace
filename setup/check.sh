#!/usr/bin/env bash
# =============================================================================
# check.sh — セットアップの完了状態を確認する
# 各コンポーネントが正しくインストールされているか一覧表示する
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

PASS="[OK]  "
FAIL="[NG]  "
WARN="[--]  "

ok=0
ng=0

check() {
    local label="$1"
    local condition="$2"
    if eval "${condition}" &>/dev/null; then
        echo "${PASS} ${label}"
        ok=$((ok + 1))
    else
        echo "${FAIL} ${label}"
        ng=$((ng + 1))
    fi
}

warn() {
    local label="$1"
    local condition="$2"
    if eval "${condition}" &>/dev/null; then
        echo "${PASS} ${label}"
        ok=$((ok + 1))
    else
        echo "${WARN} ${label} （オプション）"
    fi
}

echo "======================================================"
echo " plasma-bench セットアップ確認"
echo "======================================================"
echo ""
echo "--- 基本ツール ---"
check "curl"      "command -v curl"
check "wget"      "command -v wget"
check "cmake"     "command -v cmake"
check "gfortran"  "command -v gfortran"
check "git"       "command -v git"

echo ""
echo "--- Python / uv ---"
check "uv"                    "command -v uv"
check "仮想環境 (.venv)"      "test -f '${PLASMA_BENCH_VENV}/bin/python'"
check "Python バージョン確認"  "${PLASMA_BENCH_VENV}/bin/python --version"
check "optuna"                "${PLASMA_BENCH_VENV}/bin/python -c 'import optuna'"
check "plotly"                "${PLASMA_BENCH_VENV}/bin/python -c 'import plotly'"
check "kaleido"               "${PLASMA_BENCH_VENV}/bin/python -c 'import kaleido'"
check "pandas"                "${PLASMA_BENCH_VENV}/bin/python -c 'import pandas'"
check "matplotlib"            "${PLASMA_BENCH_VENV}/bin/python -c 'import matplotlib'"

echo ""
echo "--- OpenBLAS ---"
check "libopenblas.so"   "test -f '${OPENBLAS_INSTALL}/lib/libopenblas.so'"
check "OpenBLAS ヘッダ"  "test -f '${OPENBLAS_INSTALL}/include/cblas.h'"

echo ""
echo "--- PLASMA ---"
check "plasmatest"       "test -f '${PLASMA_TEST}'"
check "libplasma.so"     "test -f '${PLASMA_INSTALL}/lib/libplasma.so'"

echo ""
echo "--- NoFlush（Tune_SSRFB） ---"
check "NoFlush 実行ファイル"  "test -f '${NOFLUSH_PATH}'"

echo ""
echo "======================================================"
if [ "${ng}" -eq 0 ]; then
    echo " 結果: 全チェック通過 (${ok} 項目)"
else
    echo " 結果: ${ng} 項目が未完了 / ${ok} 項目通過"
    echo ""
    echo " [NG] の項目は setup/install.sh を再実行するか、"
    echo " README.md を参照して手動でセットアップしてください。"
fi
echo "======================================================"