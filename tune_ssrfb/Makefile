#
# この Makefile は、PLASMA が -DMKL_INTERFACE_LAYER=Sequential で
# ビルドされていることを前提としています。
#
UNAME = $(shell uname)
ifeq ($(UNAME),Linux)
    # --- 1. PLASMA (新しくインストールした場所) ---
    PLASMA_ROOT = $(HOME)/Library/plasma
    PLASMA_INC_DIR = $(PLASMA_ROOT)/include
    PLASMA_LIB_DIR = $(PLASMA_ROOT)/lib

    # --- 2. Intel MKL (システムパス) ---
    MKL_ROOT = /opt/intel/oneapi/mkl/2025.2
    MKL_LIB_DIR = $(MKL_ROOT)/lib

    # --- 3. コンパイラ (g++) ---
    CXX = g++
    # ★修正★: D精度ヘッダがサブディレクトリにある可能性を考慮
    CXXFLAGS = -m64 -fopenmp -O3 -DMKL -I$(PLASMA_INC_DIR) -I$(PLASMA_INC_DIR)/plasma

    # --- 4. リンカフラグ (ライブラリ検索パス) ---
    LDFLAGS = -L$(PLASMA_LIB_DIR) -L$(MKL_LIB_DIR)
    LDFLAGS += -Wl,-rpath,$(PLASMA_LIB_DIR)
    LDFLAGS += -Wl,-rpath,$(MKL_LIB_DIR)

    # --- 5. リンクするライブラリ (最重要) ---

    # ★修正★: MKL「逐次版」をリンク (PLASMAのOpenMPと競合しないため)
    MKL_LIBS = -lmkl_intel_lp64 -lmkl_sequential -lmkl_core

    # ★修正★: .so (共有ライブラリ) をリンク
    PLASMA_LIBS = -lplasma -lplasma_core_blas

    # ★修正★: g++ と -fopenmp に必要なランタイム
    SYS_LIBS = -lgomp -pthread -lm -ldl

    LIBS = $(PLASMA_LIBS) $(MKL_LIBS) $(SYS_LIBS)
endif
# (Darwinセクションは変更なし)

all: NoFlush FlushLRU

NoFlush: NoFlush.o
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS) $(LIBS)

FlushLRU: MultCallFlushLRU.o
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS) $(LIBS)

%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f *.o NoFlush FlushLRU
