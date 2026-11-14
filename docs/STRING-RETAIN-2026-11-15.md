# PadR / Replicate source retention

Base: e22689202927313db6db1c0f7f1a027b9a4f4988.
This is a correctness fix, not a performance increment or library expansion.

The old emitter retained source ptr/len, evaluated width/count, then read the
source. A later call could reassign that owner through @source, leaving the
saved pointer stale. The new path takes an independent owned snapshot before
an effectful count if the source is borrowed. A nonvariable StrOwn result is
already held until after the helper, so it needs no second snapshot. Result
ptr/len are saved before releasing either retained value.

The existing conservative expr_has_call predicate includes calls, Seq, Set
and unknown forms. The no-effect scalar path is unchanged. Twelve emitted
assembly comparisons (PadR/Replicate x literal/local/arithmetic count x
Linux/Windows) are byte-identical before/after. Benchmark variations on these
pure paths are timing noise, not a claimed speedup or regression in codegen.

CToD is NOT modified. Its checker admits exactly one source argument and its
parser evaluates no later arguments or user callbacks. Its temporary and
byref-returning-source tests already passed before and continue to pass.
There is no reproduced CToD instance of this particular bug.

## Fresh evidence

- Six fresh Harbour programs: PadR mutation, Replicate mutation, >64KiB
  mutation, nested evaluation-order/temporary-owner, CToD lifetime and
  empty/NUL/negative/zero/truncation/padding/repeat boundaries.
- 24 before/after pairs: Linux and PE Wine, normal and instrumented. All
  candidate outputs/exit/stderr match Harbour exactly. The mutation programs
  fail before on Linux in both modes; Wine's heap can leave small stale
  buffers readable, so baseline equality there is recorded, not called proof
  that no bug existed. The large before fixture may exit by signal.
- 24 additional wrappers release Work owners then verify hb_memcheck 0.
  These are HR diagnostics, not claims about a Harbour hb_memcheck API.
- New complete Linux instrumented manifest: 1729/1729.
- Cache/collision/MT/ERP checker: 49 exact executions, three named rejections.
- SubStr checker: 64 exact executions, 12 named rejections; two caught-error
  owned-memory probes still memcheck 1 and remain explicit known limits.
- Trace checker: 28 exact normal/instrumented Linux/PE comparisons.
- No main manifest, runtime helper, allocator, published binary, arity,
  numeric dispatch, CToD parser or TRY engine changes in this patch.

Harbour oracle: pinned core 694428e1c12f726675b19324d62167fa77d68185, fresh
hbmk2 -gtstd. Wine is PE execution, not native Windows. No native macOS/ARM
execution or unrestricted Harbour compatibility is claimed.

## Reproduce

Build BASE unmodified as /tmp/hbc-before, then apply CHANGES.patch and build
as /tmp/hbc-after, using rustc --edition=2021 -O src/hbc.rs. From the repo:

```sh
python3 tests/string-retain/check.py --compiler /tmp/hbc-after \
  --baseline /tmp/hbc-before --hbmk2 /path/to/hbmk2 \
  --wine /path/to/wine --wine-prefix /path/to/prefix \
  --output /tmp/retain-check-new
python3 tests/string-retain/benchmark.py --compiler /tmp/hbc-after \
  --baseline /tmp/hbc-before --hbmk2 /path/to/hbmk2 \
  --output /tmp/retain-benchmark-new
rustc --edition=2021 -O tools/run_native_manifest.rs -o /tmp/manifest-runner
/tmp/manifest-runner --compiler /tmp/hbc-after --manifest tests/manifest.txt \
  --target linux --output /tmp/retain-full-new
```

Existing tests/string-cache/check.py, tests/substr/check.py and
 tests/try-trace/check.py accept --compiler, --hbmk2, --wine, --wine-prefix,
--output for the regression gates above. Output directories must be new.

## Benchmark and limits

Microbenchmark: same-source PadR(source,len) and Replicate(source,1), with
literal count versus count supplied by a nonmutating function. Three
whole-process samples per implementation; exact stdout verified each time.
Startup/shutdown included; not a dedicated host. The function-count variant
exercises conservative retention even though that particular function does
not mutate the source. C malloc/memcpy is a one-copy reference, not equivalent
VM/registry/ownership/call semantics. For these full-width/count-one cases it
computes the same returned bytes; it is not a general PadR/Replicate oracle.

The raw table follows. ns/call, baseline / candidate / Harbour / C.

| Function | Count call | Bytes | Before | After | Harbour | C |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| PadR | False | 8 | 18.89 | 15.12 | 194.60 | 17.60 |
| PadR | False | 256 | 40.03 | 37.66 | 161.48 | 25.72 |
| PadR | False | 4096 | 66.67 | 114.64 | 233.05 | 160.26 |
| PadR | False | 65536 | 1950.65 | 1882.38 | 1296.00 | 2748.94 |
| PadR | True | 8 | 36.19 | 25.12 | 203.31 | 14.22 |
| PadR | True | 256 | 44.14 | 52.30 | 330.18 | 33.50 |
| PadR | True | 4096 | 72.34 | 100.37 | 431.07 | 154.42 |
| PadR | True | 65536 | 2049.45 | 3807.38 | 1001.50 | 2531.12 |
| Replicate | False | 8 | 5382.50 | 4976.88 | 143.91 | 14.30 |
| Replicate | False | 256 | 5046.21 | 5048.03 | 321.92 | 21.02 |
| Replicate | False | 4096 | 8539.02 | 9332.54 | 393.27 | 190.17 |
| Replicate | False | 65536 | 64576.88 | 48573.10 | 1137.95 | 2926.98 |
| Replicate | True | 8 | 5072.68 | 5314.41 | 176.96 | 12.80 |
| Replicate | True | 256 | 5251.77 | 5730.77 | 164.44 | 39.66 |
| Replicate | True | 4096 | 9784.93 | 10386.37 | 388.96 | 154.41 |
| Replicate | True | 65536 | 84397.17 | 74335.64 | 1085.07 | 3388.52 |

Replicate's existing direct allocation/copy helper still loses badly to
Harbour/C. Full-length 64 KiB PadR also loses; effectful counts add retention
cost even when the callee does not mutate. This patch does not optimize
those helpers or add RC/COW. That is a separate performance increment.

General TRY owned cleanup remains absent. A new snapshot can be leaked if
later evaluation throws before the ordinary release. Four named diagnostic
probes (PadR/Replicate x Linux/PE instrumented) explicitly record final
memcheck 1, separate from the 24 successful memcheck0 wrappers. This is not
exception-safety completion. No allocation sweep or cleanup engine is added.

The guard is conservative, not a proof of all future expression forms.
Adding new mutation/callback-capable expressions requires preserving that
conservatism. Boundaries remain the currently admitted typed byte-string
and I64 count APIs, not arbitrary Harbour values/codepages/optional padding.
