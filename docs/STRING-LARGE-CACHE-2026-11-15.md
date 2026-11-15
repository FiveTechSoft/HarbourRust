# Large-string allocation cache within the existing allocation-byte budget

Base: efdb82d6, the published typed StrTran occurrence start/count increment.
This changes private allocator policy, not language semantics or numeric ABI.

## Measurement before implementation

A fresh six-size baseline against pinned Harbour core
694428e1c12f726675b19324d62167fa77d68185 showed a sharp boundary:
65536-byte full SubStr copies cost about3446ns, while65537 cost80061ns.
Baseline128KiB/256KiB/1MiB cost153794/289696/1416151ns respectively.
Sources, all samples and exact outputs are included, not only these medians.

Linux used mmap/munmap for every string above64KiB; Windows used
HeapAlloc/HeapFree. The existing exact-capacity cache stopped at64KiB.
The baseline full-SubStr benchmark compares returned bytes to Harbour and
malloc/memcpy C. Harbour can share a full substring rather than copy it.
Therefore its much faster result is not evidence that all of this delta is
allocator overhead, nor an equivalent-copy performance target.

This is an internal improvement against the existing native baseline, like
prior allocator/copy performance fixes. It is not a claim to beat Harbour's
shared full-SubStr path. The measured cliff justified a bounded reuse trial.

## Policy and unchanged contracts

- Keep all16 small slots:8 buckets,2 ways per bucket, exact capacity matching,
  lengths0 through65536. No small slot is repurposed or removed.
- Add2 large slots, exact capacity matching for65537 through1048576 bytes.
- Share the EXISTING bound of1048832 allocation bytes per thread, equal to
  16*(65536+16). Charge capacity+16 for each logically free cached block,
  including headers. Count ALL small and large cached blocks together.
- If a matching slot is taken, unlink it and subtract its charge BEFORE
  returning a new owner. On free, retain only if an appropriate slot is empty
  AND its charge fits the remaining budget. Otherwise release through the
  original OS path with the original exact base/length validation.
- No active eviction, rounded capacity, larger TLS allocation, RC/COW, in-place
  alias, new OS API, external allocator or dependency. Data above1MiB bypass
  caching. Results still own independent storage.

The budget counts requested allocation bytes, NOT RSS, page-rounded mappings
or Windows heap metadata. Linux rounds mappings to pages and Windows adds
heap overhead. This uses the same metric as the prior16*65552 bound. The
cache's pointer/accounting metadata is separate from that block-byte budget.
Do not describe this as an exact physical-memory/RSS ceiling.

A large cached block can exhaust the shared budget and make a later small
free use the OS despite a vacant small slot. Small associativity is intact;
small retention is not reserved against large occupancy. No starvation or
universal hit-rate guarantee is made. Two1MiB blocks cannot both fit. A1MiB
copy loop therefore alternates OS allocation and reuse, rather than becoming
an all-cache workload. Sizes above1MiB remain unchanged OS allocations.

The string header remains capacity@-16,length@-8 with exact requested size.
Logical allocation/free counters and the live instrumented registry retain
their original meaning. A logically freed cached block is NOT a live owner.
Registry validation still happens before a freed block becomes cache-eligible;
cache reuse re-registers the block. Wrong capacity and double-free detection
are not bypassed. No new code is added to general TRY cleanup.

## Metadata and thread lifetime

A64-byte private metadata area precedes the existing global128-byte cache:
used bytes at cache-64; large pointers at cache-56 and cache-48. The remaining
metadata bytes are unused. The existing Linux MT rewrite maps the cache
pointer to the per-thread block at128, so these locations are existing unused
TLS64/72/80. The TLS block stays256 bytes; owner pointer120 and small cache
128..255 remain untouched. No user-facing or external ABI is changed.

Flush visits both large slots and all16 small slots, physically releases each
cached block, clears the slot and resets used bytes. It changes no logical
owner counts. Normal process/worker exit and existing worker-panic flush routes
continue to use that same helper. Main panic exits the process as before;
this does not add a new allocator shutdown guarantee on fatal process exit.
Linux freestr preserves its previous r10 behavior; no newly clobbered scratch
register is silently imposed on callers.

## Correctness and accounting evidence

- Full Linux instrumented manifest1729/1729 passes, with TSV and compressed
  per-test channels. This is not the1041 upstream .prg inventory or268 files
  directly under upstream tests/; those are different denominators.
- New differential gate21 exact executions:binary/boundary and repeated-TRY
  programs each run Linux/PE normal/instrumented plus final hb_memcheck0
  owner-release wrappers(16), and5 normal MT repetitions. Binary checks inspect
  every returned byte of repeating A/NUL/0xFF data, not just lengths. Tests use
 65535/65536/65537 and larger PadR/Space/StrTran outputs through1MiB+.
- Independent accounting model:231 allocate/free/flush steps in each of
  Linux normal/instrumented and PE normal/instrumented(924 checked states).
  A separate Python model predicts all18 slot capacities and the exact charge
  after EACH step. A separate assembly scan sums actual cached capacities,
  compares the counter/budget, checks no cached/live alias or duplicate cache
  pointer, headers, callee-saved registers and stack restoration. Final live
  registry0 and logical balance are required. Includes full budget,3 equal
  large blocks,1MiB and1MiB+1, finite slot exhaustion, random mixed sizes and
  repeated flush. Linux freestr's old r10 behavior is also checked.
- GNU MT canary:5 runs with2 workers,40 cycles and6 sizes each. Each worker
  independently scans its own TLS budget and verifies flush0 and unchanged
  owner pointer120. This is normal mode; instrumented MT remains unadmitted.
- Existing and extended instrumented registry canaries validate cached reuse,
  double free and wrong capacity for3-byte and65537-byte strings on Linux/PE.
- Existing regression gates pass:StrTran4/5 29 exact+16 rejections; StrTran2/3
 37+22; cache/ERP49+3; Space21+16; SubStr64+12; trace28; fill/retention28
  before/after pairs+28 final0 wrappers, plus its worker runs. Existing ABI
  harness and pre-store overflow checks pass Linux/PE.
- Known error-path limits remain unchanged:StrTran start/count probes3 leaked
  owners, old composite probes2/3, SubStr1, retained-count1. They are recorded
  separately, not counted as successful exception ownership tests. The new
  repeated TRY program ends0; the allocator introduces no new live-owner leak.

PE is Wine, not native Windows. No native macOS/ARM or full-library claim.
Disk-exhausted/interrupted draft runs were NOT counted as pass. A storage-only
adapter losslessly gzips large .stdout evidence files after subprocesses
return; no status/output/assertion is altered. Another adapter deletes
one-shot executed binaries for unchanged SubStr/trace scripts. Both adapter
sources are included. Successful full-manifest evidence was saved only after
independently verifying1729 TSV rows with pass=true.

An allocator comment was corrected from "physical" to "allocation" bytes
before final delivery. Final-source compiler/full/new gates were rerun. The
performance rows below were measured immediately before that comment-only
edit, on the same instructions. Both compiler identities and a byte-identical
representative generated ELF comparison are recorded. No algorithm/ABI or
runtime instruction changed between those measurements and final delivery.

## Performance and honest limits

Final nine-size whole-process benchmark(3 samples, median ns/call) compares
baseline efdb82d, candidate, real Harbour and malloc/memcpy C. Native gains
above the old boundary are19.35x at65537,19.36x at128KiB,18.31x at256KiB and
1.87x at1MiB. These are BASELINE speedups, not Harbour speedups. Harbour and C
remain faster in many large-copy rows; Harbour may share a full substring.

A separate nine-sample interleaved native-only check alternates execution
order to reduce scheduling bias. It records these small-path regressions
literally:8B60.66->64.31ns(+6.0%);4096B106.82->109.28ns(+2.3%);
65536B3334.83->3387.59ns(+1.6%).64B171.24->169.44ns improves about1.1%.
The separate three-sample sweep loses64B by22.4% and4096B by2.3%; earlier
runs vary more. All samples remain included. These are noisy shared-host
microbenchmarks, not a universal parity/speed guarantee or application gain.
Accounting and budget checks add work even when small-cache hits dominate.

An initial interleaved fixture started the destination as a borrowed empty
string and exposed pre-existing extra ownership/copy churn in BOTH baseline
and candidate(~5-6us/call). That longer draft timed out and is not a passing
benchmark. The final owned-initial-value fixture matches the original copy
benchmark and completes. Sources identify the difference rather than hiding
an unrelated performance path as an allocator improvement.

The2 large slots match exact capacities, so varied lengths or collisions can
miss. Shared budget exhaustion falls back to the original OS allocator and
can lower cache retention for small strings despite unchanged associativity.
No universal large-workload parity with Harbour/C or speedup above1MiB is
claimed. TRY owner-cleanup debt in other helpers is deliberately unchanged.

## Reproduce

Build base efdb82d separately for --baseline and patched source for --compiler:

```sh
rustc --edition=2021 -O -C strip=symbols src/hbc.rs -o /tmp/hbc-large
python3 tests/string-large-cache/check.py --compiler /tmp/hbc-large \
  --hbmk2 /path/to/pinned/hbmk2 --output /tmp/new-large-gate \
  --wine /path/to/wine --wine-prefix /path/to/prefix
python3 tests/string-large-cache/abi.py --compiler /tmp/hbc-large \
  --output /tmp/new-large-abi --wine /path/to/wine \
  --wine-prefix /path/to/prefix --mingw /path/to/mingw/bin \
  --mlib /path/to/mingw/lib
python3 tests/string-large-cache/mt-abi.py --compiler /tmp/hbc-large \
  --output /tmp/new-large-mt
python3 tests/string-large-cache/benchmark.py --compiler /tmp/hbc-large \
  --baseline /tmp/hbc-base --hbmk2 /path/to/hbmk2 --output /tmp/new-large-bench
python3 tests/string-large-cache/small-benchmark.py --compiler /tmp/hbc-large \
  --baseline /tmp/hbc-base --output /tmp/new-small-bench
```

All output directories must be new. GNU canaries require as/ld; Windows
canaries require GNU MinGW and Wine. registry.sh follows the existing registry
script's ./hbc and M/MLIB/WINE/WINEPREFIX setup. Full regression uses the
unchanged tools/run_native_manifest.rs runner against tests/manifest.txt.
No released binary, main manifest, upstream program-admission or dependency
change is included. Unrelated tracked-empty cache-test status is excluded.

| Bytes | Baseline ns/call | Candidate ns/call | Harbour ns/call | C ns/call |
| ---: | ---: | ---: | ---: | ---: |
| 8 | 66.14 | 65.94 | 227.96 | 28.53 |
| 64 | 109.36 | 133.83 | 166.72 | 30.42 |
| 4096 | 145.08 | 148.41 | 320.65 | 154.67 |
| 65535 | 3934.84 | 3928.16 | 512.61 | 2016.25 |
| 65536 | 3625.36 | 3374.29 | 626.26 | 2481.39 |
| 65537 | 76518.81 | 3953.81 | 900.65 | 2509.75 |
| 131072 | 143232.63 | 7397.07 | 1330.89 | 5251.70 |
| 262144 | 259241.74 | 14160.24 | 2220.09 | 10234.64 |
| 1048576 | 1257316.47 | 673314.21 | 8273.80 | 101050.97 |
