# Third-party and source notices

This distribution is an unofficial fork build of **lorrainea/MARS**, the circular sequence refinement tool by Lorraine A.K. Ayad and Solon P. Pissis. It is **not maiziex/MARS**, and the fork release version is not an upstream version.

MARS: Copyright (C) 2016 Lorraine A.K. Ayad, Solon P. Pissis. Licensed under GPL-3.0-or-later; the full GPLv3 text is in LICENSE and the source headers grant the later-version option.

Linked or compiled-in components:

| Component | Source used | Notice shipped in licenses/ |
| --- | --- | --- |
| SeqAn | Unmodified upstream-supplied seqan.zip | SEQAN-LICENSE.txt (all distinct bundled header notices; BSD-style terms) |
| SDSL | Upstream-supplied sdsl-lite.tar.gz | SDSL-COPYING.txt (GPL-3.0-or-later; full GPL text in LICENSE) |
| libdivsufsort | external/libdivsufsort-2.0.1 inside that SDSL archive | LIBDIVSUFSORT-COPYING.txt (MIT) |
| Edlib | Upstream MARS edlib.cc and edlib.h | EDLIB-LICENSE.txt (MIT, copyright Martin Sosic) |
| musl libc | Alpine 3.20 toolchain | MUSL-COPYRIGHT.txt (MIT and component-specific permissive notices) |
| GCC libstdc++, libgcc and libgomp | Alpine 3.20 GCC, unmodified eligible GCC compilation | GCC-RUNTIME-EXCEPTION.txt (GPLv3 + GCC Runtime Library Exception 3.1; full GPL text in LICENSE) |

The vendored Edlib files do not record an exact upstream revision or their own license file. The MIT license supplied here is reproduced from Martinsos/edlib commit 0ddc23ea06abd95ab6227442acb4c27bd7607b68; this is license provenance, not a claim that MARS uses that Edlib revision. The musl copyright text is from musl v1.2.5. The GCC exception is from gcc-mirror/gcc releases/gcc-13 COPYING.RUNTIME.

The accompanying `mars-VERSION-source.tar.gz` release asset is the complete fork source tree for the binary's recorded fork commit, including the original dependency source archives. Build scripts and the build-only compatibility shim are supplied there. Runtime library combinations are produced by an eligible GCC compilation covered by the GCC Runtime Library Exception; no custom runtime libraries are used. BUILD-INFO.txt records the compiler/runtime versions and source commit. STATIC-BUILD.md explains rebuilding.

All upstream algorithm and CLI implementation files are unchanged. The build-only shim supplies the missing explicit stdint.h include. Build-only changes skip the unused bundled GoogleTest suite, disable SDSL’s build-host CPU probe for portable x86_64 code, and undefine the musl PAGESIZE macro before including the old SeqAn headers. No warranty is provided.
