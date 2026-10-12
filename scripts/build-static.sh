#!/usr/bin/env bash
# Build only from the dependency source archives supplied by upstream MARS.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build
unzip -qo seqan.zip -d .build
tar -xzf sdsl-lite.tar.gz -C .build

# The bundled GoogleTest is not part of MARS; do not build its old test suite.
python3 - <<'PY'
from pathlib import Path
p = Path('.build/sdsl-lite/external/CMakeLists.txt')
p.write_text(p.read_text().replace('add_subdirectory(gtest-1.6.0)', ''))
PY
cmake -S .build/sdsl-lite -B .build/sdsl-build \
  -DBUILD_SHARED_LIBS=OFF -DBUILTIN_POPCNT=OFF \
  -DCMAKE_INSTALL_PREFIX="$PWD/.build/libsdsl"
cmake --build .build/sdsl-build -j2
cmake --install .build/sdsl-build

# musl defines PAGESIZE in limits.h; old SeqAn uses that name in templates.
# Include the system headers once, then undefine the macro before SeqAn.
cat > .build/seqan-musl-compat.h <<'EOF'
#include <limits.h>
#include <unistd.h>
#ifdef PAGESIZE
#undef PAGESIZE
#endif
EOF
sources=(mars.cc matrices.cc utils.cc sacsc.cc ced.cc nj.cc progAlignment.cc
         cyclic.cc RestrictedLevenshtein.cc bb.cc heap.cc edlib.cc)
g++ -std=c++11 -O3 -fomit-frame-pointer -funroll-loops -pthread -fopenmp \
  -D_USE_OMP -static -I. -I.build -I.build/libsdsl/include \
  -include .build/seqan-musl-compat.h "${sources[@]}" \
  -L.build/libsdsl/lib -lsdsl -ldivsufsort -ldivsufsort64 -o .build/mars
strip .build/mars
{
  g++ --version
  cmake --version
  apk info -v musl gcc g++ libstdc++ libgomp
} > .build/toolchain.txt
file .build/mars
readelf -l .build/mars > .build/program-headers.txt
readelf -d .build/mars > .build/dynamic-section.txt
if grep -q INTERP .build/program-headers.txt || grep -q NEEDED .build/dynamic-section.txt; then
  echo 'Refusing to release a dynamically linked executable' >&2
  exit 1
fi
python3 scripts/verify-rotation.py .build/mars
