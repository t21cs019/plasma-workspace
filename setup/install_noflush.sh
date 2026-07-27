#!/usr/bin/env bash
# =============================================================================
# install_noflush.sh — 同梱ソース（tune_ssrfb/）から NoFlush をビルド
# 管理者権限不要。${NOFLUSH_PATH} の親ディレクトリにインストールする。
#
# ソースはこのリポジトリに同梱（tune_ssrfb/NoFlush.cpp 等）。外部リポジトリの
# clone はしない。NoFlush は実行時引数で MAT_SIZE / N_IT を指定できる:
#   NoFlush [NB] [IB] [MAT_SIZE=4096] [N_IT=50]
#
# BLAS バックエンド:
#   既定は OpenBLAS（このワークスペースの PLASMA ビルドに合わせる）。
#   Intel MKL 版 PLASMA を使う場合は NOFLUSH_USE_MKL=1 を指定すると、
#   同梱の Makefile（MKL 前提）でビルドする。
#     NOFLUSH_USE_MKL=1 bash setup/install_noflush.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

VENDOR_SRC="${REPO_ROOT}/tune_ssrfb"
NOFLUSH_DIR="$(dirname "${NOFLUSH_PATH}")"
WORK_DIR="${HOME}/Download/build_noflush"
NOFLUSH_USE_MKL="${NOFLUSH_USE_MKL:-0}"

echo "======================================================"
echo " NoFlush（同梱 tune_ssrfb）インストール開始"
echo " ソース    : ${VENDOR_SRC}"
echo " 出力      : ${NOFLUSH_PATH}"
echo " バックエンド: $([ "${NOFLUSH_USE_MKL}" = 1 ] && echo 'Intel MKL' || echo 'OpenBLAS')"
echo "======================================================"

# すでにインストール済みか確認
if [ -f "${NOFLUSH_PATH}" ]; then
    echo "[SKIP] NoFlush はすでにインストール済みです。"
    echo "       再インストールしたい場合は ${NOFLUSH_PATH} を削除してください。"
    exit 0
fi

if [ ! -f "${VENDOR_SRC}/NoFlush.cpp" ]; then
    echo "[ERROR] 同梱ソースが見つかりません: ${VENDOR_SRC}/NoFlush.cpp"
    exit 1
fi

# 同梱ソースを作業ディレクトリにコピーしてビルド（リポジトリを汚さない）
mkdir -p "${WORK_DIR}"
cp "${VENDOR_SRC}/NoFlush.cpp" "${VENDOR_SRC}/MultCallFlushLRU.cpp" "${VENDOR_SRC}/Makefile" "${WORK_DIR}/"
cd "${WORK_DIR}"

echo "[1/2] ビルドしています..."
if [ "${NOFLUSH_USE_MKL}" = 1 ]; then
    # 同梱 Makefile（MKL 前提）でビルド
    make NoFlush
else
    # OpenBLAS 版（このワークスペースの PLASMA ビルドに合わせる）
    # --disable-new-dtags: DT_RUNPATH ではなく DT_RPATH を埋め込む。
    # RPATH は推移的依存（libplasma → libopenblas）にも効くため、LD_LIBRARY_PATH
    # 無しでも実行時にライブラリを解決できる。
    g++ -m64 -fopenmp -O3 \
        -I"${PLASMA_INSTALL}/include" \
        -I"${PLASMA_INSTALL}/include/plasma" \
        -I"${OPENBLAS_INSTALL}/include" \
        -o NoFlush NoFlush.cpp \
        -L"${PLASMA_INSTALL}/lib" \
        -L"${OPENBLAS_INSTALL}/lib" \
        -lplasma -lplasma_core_blas -lopenblas \
        -Wl,--disable-new-dtags \
        -Wl,-rpath,"${PLASMA_INSTALL}/lib" \
        -Wl,-rpath,"${OPENBLAS_INSTALL}/lib"
fi

if [ ! -f "${WORK_DIR}/NoFlush" ]; then
    echo "[ERROR] ビルドに失敗しました。NoFlush バイナリが見つかりません。"
    exit 1
fi

# インストール先にコピー
echo "[2/2] インストールしています -> ${NOFLUSH_PATH}"
mkdir -p "${NOFLUSH_DIR}"
cp "${WORK_DIR}/NoFlush" "${NOFLUSH_PATH}"
chmod +x "${NOFLUSH_PATH}"

echo ""
echo "[完了] NoFlush のインストールが完了しました。"
echo "       実行ファイル: ${NOFLUSH_PATH}"
echo "       使い方: NoFlush [NB] [IB] [MAT_SIZE=4096] [N_IT=50]"
