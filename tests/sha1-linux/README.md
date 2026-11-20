# SHA-1 and HMAC-SHA1, ordinary Linux

Original MIT implementation from the mathematical definitions in FIPS 180-4
and RFC 2104. SOURCES.txt identifies the sections and published test vectors.
No Harbour hbsha1/hmac source, RFC sample code or library implementation is
used. Harbour is an external executable oracle only. This legacy primitive
is for compatibility, not a recommendation for new security designs.

`check.py` compares unchanged source with Harbour, stdout/stderr/rc raw,
internal and external assembly, instrumented. SHA-1 data lengths cover padding
55/56/57 and block63/64/65, binary bytes and1000bytes. HMAC keys cover empty,
20,63,64,65,100,1000bytes. Both raw20bytes and lowercase40hex, default and
explicit flags. The pinned sha1.prg original is not modified and exercises
raw digests through QOut, so it also requires the measured GTSTD renderer.

Only typed string data/key and optional typed logical raw flag are admitted.
No Dyn coercion, nonlogical flag, other backend or thread support is claimed.
The generator records the compiler/flags/source/ASM hashes, requires no
external calls and private static labels. The C core has no heap or libc.

Inputs are snapshotted in left-to-right order before a later argument can
consume or mutate an earlier borrowed owner. Fresh argument temporaries are
freed after copying; results are owned. A local sequence cleanup pad releases
early snapshots if a later string or logical argument throws, then rethrows
unchanged. `unwind.prg` catches2000throws per Work and checks0memory delta
after warmup. It is instrumentation-only, not an unchanged Harbour source.

`core.py` checks1417raw+hex vectors against independent Python libraries and
four published vectors, with UBSan active. `mutants.py` changes rotate,padding,
length,key-boundary,ipad,opad in own C, verifies successful compilation and
execution, then requires every mutant to diverge. These are helper mutants,
not whole Rust compiler mutants.
