#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
version=${1:?Usage: package-release.sh TAG}
base="mars-${version}-linux-x86_64"
source_base="mars-${version}-source"
commit=$(git rev-parse HEAD)
upstream=cbf8f594e96db8f757f1d84edf773406b4c72701
mkdir -p "dist/$base/bin" "dist/$base/licenses"
install -m755 .build/mars "dist/$base/bin/mars"
cp LICENSE NOTICE.md STATIC-BUILD.md "dist/$base/"
cp licenses/*.txt "dist/$base/licenses/"
cp .build/sdsl-lite/COPYING "dist/$base/licenses/SDSL-COPYING.txt"
cp .build/sdsl-lite/external/libdivsufsort-2.0.1/COPYING "dist/$base/licenses/LIBDIVSUFSORT-COPYING.txt"
# Preserve the distinct license/copyright comment headers from bundled SeqAn.
python3 - "$base" <<'PY'
import sys
from pathlib import Path
notices = set()
for header in sorted(Path('.build/seqan').rglob('*.h')):
    text = header.read_text(errors='replace')
    prefix = text.split('#ifndef', 1)[0].split('#pragma', 1)[0]
    if 'Copyright' in prefix or 'copyright' in prefix:
        notices.add(prefix.strip())
Path('dist', sys.argv[1], 'licenses', 'SEQAN-LICENSE.txt').write_text(
    '\n\n'.join(sorted(notices)) + '\n'
)
PY
{
  printf 'Version: %s\nFork: https://github.com/TTTPOB/MARS\nFork commit: %s\nUpstream: https://github.com/lorrainea/MARS\nUpstream commit: %s\n' "$version" "$commit" "$upstream"
  printf 'Corresponding source: https://github.com/TTTPOB/MARS/releases/download/%s/%s.tar.gz\n\n' "$version" "$source_base"
  cat .build/toolchain.txt .build/program-headers.txt .build/dynamic-section.txt
} > "dist/$base/BUILD-INFO.txt"
# The archive contains the entire committed tree, including the supplied source archives.
git archive --format=tar --prefix="$source_base/" HEAD | gzip -n > "dist/$source_base.tar.gz"
tar --sort=name --mtime="$(git show -s --format=%cI HEAD)" --owner=0 --group=0 --numeric-owner -C dist -cf - "$base" | gzip -n > "dist/$base.tar.gz"
(cd dist && sha256sum ./*.tar.gz > SHA256SUMS)
rm -r "dist/$base"
cat > .build/release-notes.md <<EOF
Unofficial static Linux x86_64 build of **lorrainea/MARS** (circular sequence rotation), **not maiziex/MARS**. This fork release version is not an upstream official version.

- Fixed upstream commit: \`$upstream\`
- Fork/build-source commit: \`$commit\`
- Binary: \`$base.tar.gz\` (executable: \`$base/bin/mars\`)
- Corresponding source: \`$source_base.tar.gz\`, including original SeqAn/SDSL source archives, build scripts, compatibility shim and all fork changes.
- Built with GCC/musl inside the digest-pinned Alpine 3.20 container documented in STATIC-BUILD.md; OpenMP is statically linked.
- Checks required before publication: ELF has no INTERP/NEEDED entries; deterministic circular rotations and upstream data/10.gappy.fasta pass real CLI tests.
- MARS and SDSL: GPL-3.0-or-later. LICENSE, NOTICE.md and licenses/ ship alongside the executable. SHA256SUMS covers both release archives.

Rebuild from the accompanying source following STATIC-BUILD.md. The only compatibility adaptations are omission of unused bundled GoogleTest and undefinition of musl's PAGESIZE macro before old SeqAn headers; algorithm and CLI sources are unchanged.
EOF
