#!/usr/bin/env bash
# =============================================================================
# config.sh — plasma-workspace 共通設定
# ネイティブ環境ビルド（OpenBLAS / PLASMA / NoFlush）の各スクリプトと、
# 計測リポジトリ plasma-perf の run_campaign.sh がこのファイルを source する。
# =============================================================================

# --- インストール先 -----------------------------------------------------------
export PLASMA_LIBS="${HOME}/Library"
export OPENBLAS_INSTALL="${PLASMA_LIBS}/openblas"
export PLASMA_INSTALL="${PLASMA_LIBS}/plasma"

# --- 実行バイナリ（plasma-perf の bench はこれらを参照する）-------------------
export PLASMA_TEST="${PLASMA_INSTALL}/bin/plasmatest"        # tileqr（フルQR）
export NOFLUSH_PATH="${PLASMA_LIBS}/Tune_SSRFB/NoFlush"      # ssrfb（カーネル単体）

# --- ビルド設定 ---------------------------------------------------------------
export NUM_MAKE_JOBS=$(nproc)   # 並列ビルド数（自動検出）

# --- ソースのダウンロードURL --------------------------------------------------
OPENBLAS_VERSION="0.3.28"
export OPENBLAS_VERSION
export OPENBLAS_URL="https://github.com/OpenMathLib/OpenBLAS/releases/download/v${OPENBLAS_VERSION}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz"
export PLASMA_GIT_URL="https://github.com/icl-utk-edu/plasma.git"

# --- 結果転送先（plasma-perf の sync_results.sh が使う。任意）-----------------
# export RCLONE_REMOTE="onedrive:research/tileQR/inbox/manual"
# export SCP_DEST="ryo@desktop:~/tileQR_dashboard/inbox/manual"

# NOTE: Python 環境（optuna 等）は計測リポジトリ plasma-perf 側で管理する
#       （uv: `bash scripts/setup_python.sh`）。このワークスペースはネイティブ
#       ライブラリのビルドのみを担当する。PLASMA のビルドには system の python3
#       が必要（install_plasma.sh 内で存在を確認する）。
