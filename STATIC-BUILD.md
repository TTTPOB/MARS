# Unofficial static Linux x86_64 release

This fork packages [lorrainea/MARS](https://github.com/lorrainea/MARS), a circular-sequence refinement tool, **not maiziex/MARS**. Release tags such as `v0.1.0-static.1` identify fork builds, not official upstream versions. Upstream is fixed at `cbf8f594e96db8f757f1d84edf773406b4c72701`.

## Download and use

Download `mars-v0.1.0-static.1-linux-x86_64.tar.gz` from this fork's fixed-version release. Extract it and use `mars-v0.1.0-static.1-linux-x86_64/bin/mars`. Keep LICENSE, NOTICE.md and licenses/ with redistributions. Check SHA256SUMS when downloading.

Example real invocation (the bundled source has this input):

```sh
./mars -a DNA -m 0 -i data/10.gappy.fasta -o rotated.fasta -q 5 -l 20 -P 1
```

The binary is ELF x86_64, entirely statically linked against musl, including libstdc++ and OpenMP. The release workflow rejects any INTERP program header or NEEDED dynamic entry and tests actual sequence rotations, not help text. Upstream `-h` exits with status 1.

## Rebuild from the matching source asset

Extract `mars-v0.1.0-static.1-source.tar.gz`, enter its directory, and run:

```sh
docker run --rm --platform linux/amd64 -v "$PWD:/src" -w /src \
  alpine:3.20@sha256:c64c687cbea9300178b30c95835354e34c4e4febc4badfe27102879de0483b5e \
  sh -c 'apk add --no-cache build-base cmake python3 bash git unzip binutils file && bash scripts/build-static.sh'
```

Podman may replace Docker. No host-global tool installation is needed. The resulting executable is `.build/mars`. `python3 scripts/verify-rotation.py .build/mars` runs a deterministic 240 bp circular sequence in three origins and the upstream 10.gappy.fasta example. Each output must preserve identifiers, lengths and circular sequence content; at least one record must really change, and the identical synthetic circles must reach the same origin.

Builds use the dependency sources in the original repository's seqan.zip and sdsl-lite.tar.gz, not current online dependency checkouts. The build-only compatibility header explicitly supplies stdint.h (upstream relies on transitive int32_t declarations), includes musl's system headers once and undefines PAGESIZE (a conflicting identifier in old SeqAn). The unused bundled GoogleTest subtree is excluded from the dependency build. MARS algorithm and CLI source files are not modified. SDSL's optional CPU-specific POPCNT optimization is disabled to avoid narrowing the x86_64 CPU baseline.

The container image is digest-pinned. Alpine package repositories supply the named toolchain packages; exact resolved versions are recorded in BUILD-INFO.txt. This provides a simple repeatable build recipe, not a promise of byte-identical builds forever against mutable package repositories.

## Release maintenance

The workflow builds pushed `v*-static.*` tags or an explicitly selected existing tag through workflow_dispatch. From a git checkout at the desired commit, use a new tag, never overwrite an existing tag or asset:

```sh
git tag v0.1.0-static.1
git push origin v0.1.0-static.1
```

Actions publishes the binary archive, the complete `git archive` corresponding source (including dependency archives), and SHA256SUMS as real GitHub release assets only after tests pass. It does not substitute Actions artifacts for releases. Packaging requires a git checkout, while rebuilding the executable works from the accompanying source tarball without git history.
