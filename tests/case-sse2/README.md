# Bounded fused ASCII case conversion

Upper and Lower allocate once via the existing hbc_stralloc protocol and
convert while copying. The vector path loads and stores only full 16-byte
blocks. A scalar tail handles 0..15 bytes. Signed comparisons mask only the
ASCII letter range; bytes128..255 pass through. SSE2 only, no AVX or new
assembler forms. XMM0..5 are scratch; XMM6..15 and the usual callee-saved GPRs
are preserved. Inputs remain borrowed and unchanged; returned strings own
their allocation and retain the existing headers/cache/registry protocol.

Tests (from repository root, use fresh output directories):

    rustc --edition=2021 -O tests/hasm-sse2/driver.rs -o /tmp/case-driver
    python3 tests/case-sse2/check.py --compiler /tmp/candidate --hbmk2 /path/hbmk2 --wine /path/wine --wine-prefix /path/prefix --output /tmp/case-check
    python3 tests/case-sse2/guard.py --compiler /tmp/candidate --driver /tmp/case-driver --output /tmp/case-guard
    python3 tests/case-sse2/abi.py --compiler /tmp/candidate --driver /tmp/case-driver --wine /path/wine --wine-prefix /path/prefix --output /tmp/case-abi
    python3 tests/case-sse2/benchmark.py --compiler /tmp/candidate --baseline /tmp/base --hbmk2 /path/hbmk2 --function Upper --size 65536 --output /tmp/case-bench

check: fresh Harbour byte-codepage default oracle; all256 byte values, both
helpers, lengths0/1/2/15/16/17/31/32/33/63/64/65. Retained output survives
source reassignment. hb_memcheck0 checked after Work returns. ELF/PE execute
normal and instrumented; MachO emission only, including retained cases.

Guard: 1,081,346 Linux native-encoder cases, bytes0..255, lengths0..65,
source/destination left/right page edges, 16 source alignment offsets,
source bytes unchanged. Exact page-end source/destination at offset0 proves
no overread/overwrite; other offsets exercise relative alignment. Zero
length also receives inaccessible source AND destination pointers.
ONLY this guard replaces stralloc to force destination page boundaries.
It does not test the allocator. Do not report it as a real-allocation test.

ABI: 300 cases x6 target/modes, real allocator, all-byte patterned source,
lengths0..65 plus127/128/129/255/256/257/4095/4096/4097, owned nonnull result,
length/capacity headers, byte result, GPR/XMM6..15 preservation, stack,
logical allocation balance and (instrumented) registry0 after cache flush.
Four ELF/PE configs execute; two MachO configs emit only.

Benchmark: same source, fresh pinned Harbour, candidate and exact baseline,
7 rotating-order whole-process samples, warmup, verified matching output.
Run Upper and Lower each at64/4096/65536. Linux native, includes process
startup/allocation/loop, no CPU affinity, not isolated helper throughput or
an application speedup. No promise for unmeasured workloads or other hosts.

Limits: ASCII byte-codepage semantics only, not Unicode or locale casefold.
MachO has not executed on native hardware. Reuses SSE2 encoders already
covered by tests/hasm-sse2. Registry0 is not a general memory-safety proof.
