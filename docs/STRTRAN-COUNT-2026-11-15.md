# StrTran: I64 occurrence start and count

Base:960e79bd0c026aeb83ab95898677b2dc6e43a4d3 (published Val design plus
its bytecode-ignore correction). This increment does not implement Val or
change the numeric ABI. It extends the existing typed native StrTran path.

## Admitted semantics

StrTran(text,seek[,replacement[,start[,count]]]) admits typed byte strings
in arguments1 through3 and I64 values in4/5. Omitted replacement deletes;
omitted start is1 and omitted count is unlimited. Omitted arguments between
commas, NIL/default coercion, F64 truncation and Dyn dispatch are not admitted.
Those are Harbour behaviors outside this unit, not Harbour runtime errors.

Fresh Harbour oracle:core694428e1c12f726675b19324d62167fa77d68185,
src/rtl/strtran.c. The independent exploratory oracle contains740rows,
including non-admitted type/default behavior. Native semantics were selected
from the typed I64 cases, not guessed from byte indices:

- start is a one-based NONOVERLAPPING OCCURRENCE index, not a byte offset.
  StrTran("aaaaa","aa","X",2,1) returns"aaXa".
- start0 OR count0 returns empty, even with empty seek or negative start.
- negative start leaves the original bytes unchanged unless count0 wins.
- any negative I64 count means unlimited for reachable string sizes; no
  negation/abs of MIN_I64 is used. Extremely negative start is not clamped1.
- start beyond available occurrences leaves original bytes unchanged.
- replacement bytes are not rescanned. NUL/0xFF are ordinary bounded bytes.
- empty seek, seek longer than text and empty text retain prior behavior,
  except the start0/count0 override. Source/seek/replacement are not modified.

Harbour converts its numeric start/count to platform HB_SIZE. On this64-bit
path negative start becomes an unreachable occurrence index, while negative
count behaves as a very large unsigned count. We implement the equivalent
observable signed-I64 rules above, not a general 32-bit Harbour claim.

Every result has independent owned storage including no-match/empty cases;
Harbour may share an original item. Ownership and cache headers are unchanged.

## Evaluation, lifetime and implementation

All arguments run once left-to-right, including start/count when a zero
parameter means the result will be empty. The emitter stores the start value
before evaluating count, so count's byref mutation cannot change the already
evaluated start. Borrowed strings in any of the first3 positions are copied
when later expressions may have effects. This now includes replacement when
start/count can mutate it. Owned temporary strings are kept live and released
after saving the result; no extra snapshot is needed for their own storage.
The same conservative expr_has_call check covers calls, Seq/Set and unknown
forms, not just explicit byref syntax. This is normal-path retention, not
new general exception cleanup. A numeric ABI/provenance word is not altered.

Two/three-argument calls still use the existing all-occurrences helper.
Explicit start1/negative count tail-dispatches to it after zero checks.
Other ranges skip complete nonoverlapping matches, then count only the
selected range, check result length and fill prefix/replacements/suffix.
Skipped prefixes are not searched again during the fill phase. Finite small
counts stop counting as soon as the selection is satisfied and copy the
remaining suffix in bulk. This avoids a full character scan for count3 on
large strings. Empty/no-match results still copy under native ownership.

One-byte patterns with unlimited or count>16 use a linear count/fill kernel.
Its initial skipped-occurrence search checks up to4 bounded bytes at a time
without reading beyond the string; dense matches fall back to scalar progress.
Unlimited count copies the skipped prefix in bulk and uses tight0/1/2-byte
replacement loops. Other replacement lengths remain bounded byte copies.
The count16 dispatch is a measured heuristic, not a semantic boundary.
Generic ranged patterns use the existing bounded byte-search helper. A
bounded last-byte prefilter was added to that shared matcher, including
original 2/3-argument calls, to reject common-prefix misses sooner. The
original and extended helper gates were repeated after that shared change. Short
replacement0/1/2/3 avoids rep movsb per match; large pieces use rep movsb.

General multi-byte matching still has O(text length * seek length) worst-case
cost. Advancing after each match and not rescanning skipped prefixes does not
turn it into KMP. No linear-general-search/vector promise is made. Existing
allocation/cache/thread helpers, result headers, TLS policy and cache limits
are unchanged. No new assembler instruction, external API or binary update.

## Fresh final evidence

All final records identify the same final source/compiler hashes in evidence.

- Linux instrumented manifest:1729/1729 pass. Full TSV and compressed channels
  included. This is the regression manifest denominator, not the1041 upstream
  .prg inventory or268 files directly under upstream tests/.
- New gate:29 exact executions and16 named rejections. Matrix/order/binary
  programs each run Linux/PE normal/instrumented and four owner-release
  wrappers require final hb_memcheck0 (24 executions). Five further MT runs
  use two normal-mode workers. PE runs are Wine, not native Windows.
- The matrix contains760 calls, including726 systematic/seeded cases plus
  explicit four-argument/default-count calls and32 finite large-count cases.
  Values include0,negative,-1,-2,very negative and max I64; bytes program adds
  MIN_I64 expressions, NUL/0xFF and65535/65536/65537-size boundaries.
- Order program mutates text,seek,replacement while evaluating start; uses
  >64KiB owners, retains a numeric start before count mutates it, exercises
  owned nested argument results and evaluates zero-count side effects. A
  five-parameter wrapper confirms mixed string/I64 parameter inference; a
  misplaced draft pinning hunk was caught and corrected before handoff.
- Eight negative shapes per target:arity6,F64 start/count,NIL start,logical
  count,string start and mixed-array Dyn start/count. Named diagnostics,
  no output executable or compiler panic. Typed-array I64 values remain valid.
-172 GNU as/ld extended helper canaries:86cases x normal/instrumented. Full
  result bytes, length/capacity headers, callee-saved registers, restored
  caller stack and allocation/free balance checked. Covers zero/negative/
  finite/unlimited/unreachable ranges, binary bytes, empty seek, replacements
  of0/1/2/3 bytes and finite counts17/18 stopping inside a large source.
- Original StrTran gate:37 exact+22 named rejections. Former arity4/5 negatives
  are replaced with arity6/7; remaining scope diagnostics still checked.
  Original helper GNU canaries40 pass. Its unchanged test runner now deletes
  temporary asm/source canaries after successful execution to limit disk use.
- Space21 exact+16 rejections; cache/ERP49+3; SubStr64 exact+12 rejections;
  TRY trace28 exact. The unchanged SubStr/trace scripts retain executables,
  so an included adapter removes each one-shot executed binary after its real
  subprocess returns. It does not alter output,status,checks or source.
- Two new caught-array-error probes (start/count) each report3 leaked owners
  on Linux/PE instrumented. Those4 observations are declared limits, not passes
  for ownership. Prior StrTran2/3 composite leaks and SubStr's own error leak
  remain separately recorded by their regression scripts.

Several draft runs exhausted disk; none was counted as passing. Full manifest
was rerun successfully and its TSV plus compressed channels saved. Canary
runners now remove successful temporary .s/.prg files; no compiler behavior
was changed to pass a test. A draft fixture mixed QOut's empty output with
subsequent OutStd and exposed buffering differences; all matrix QOut checks
now follow OutStd checks, as in the prior successful fixture. This is not a
StrTran semantic fix. Mixed-array negatives are intentional:homogeneous
integer arrays are typed I64, so calling them Dyn negatives would be wrong.

## Reproduce

```sh
rustc --edition=2021 -O src/hbc.rs -o /tmp/hbc-strtran-count
python3 tests/strtran-count/check.py --compiler /tmp/hbc-strtran-count \
  --hbmk2 /path/to/pinned/hbmk2 --output /tmp/new-count-gate \
  --wine /path/to/wine --wine-prefix /path/to/prefix
python3 tests/strtran-count/abi.py --compiler /tmp/hbc-strtran-count \
  --output /tmp/new-count-abi
python3 tests/strtran-count/benchmark.py --compiler /tmp/hbc-strtran-count \
  --hbmk2 /path/to/pinned/hbmk2 --output /tmp/new-count-benchmark
rustc --edition=2021 -O tools/run_native_manifest.rs -o /tmp/run-manifest
/tmp/run-manifest --compiler /tmp/hbc-strtran-count --target linux \
  --manifest tests/manifest.txt --output /tmp/new-full
```

All output directories must be new. The original StrTran/Space/cache/SubStr/
trace checkers take the same compiler,Harbour,output and optional Wine flags.
The initial exploratory oracle source and its raw740rows are in evidence.
No main-manifest addition, released executable or upstream-admission claim.

## Performance and limits

The benchmark records27 workloads at64/4096/65536 bytes:finite replacement,
growth and deletion (start2,count3), multi-byte replacement, miss,31-byte
common-prefix miss, and unlimited replacement/growth/deletion(start2,count-2).
Three whole-process samples include startup/shutdown and shared-host noise;
final loops use4 times the original iterations to reduce short-run noise;
stdout matches Harbour for every sample. It is not application throughput.
C is a malloc/memcmp/memcpy transform reference with the same bytes, not the
VM,ownership registry,TLS cache or argument-snapshot work. C remains faster
on many workloads. No fastest-possible-C or full-library claim is made.

Final complete run has26/27 lower measured median ns/call than Harbour.
The65536-byte multi-byte row(start2,count-2) is442731.59ns native versus
427979.27ns Harbour:3.45% SLOWER(native/Harbour1.0345). C is50802.43ns,
roughly8.4 times faster than Harbour and8.7 times faster than native.
This loss is retained literally. Review accepted it as near parity amid
shared-host variance, not as a victory or proof of universal performance.
All earlier runs are retained too:initial range helper lost the65536 multi
row; a broader27-case run lost unlimited one-byte cases; later noisy runs
lost4096 multi/65536 miss or unlimited-expand. Kernel changes that followed
are described above, not hidden. Shared-host variance makes small margins
uncertain; those historical losses prevent treating27/27 as a universal
speed guarantee. An additional reviewed-build run lost4096 prefix-miss
by12%; the bounded last-byte prefilter was then added. The final short run
still lost65536 multi by18%; the final longer loops measured the3.45% loss
above without another compiler change. All those raw histories are retained.
See raw samples and sources, not a selected headline.

Scope limits:typed strings and I64 start/count only. No F64 truncation,
nonfinite conversion,Dyn/default coercion,NIL/omitted interior parameters,
runtime argument substitution or full Harbour StrTran. General search is
still O(n*m), not linear. >64KiB/cache-collision allocations can be slower;
empty/no-match results copy where Harbour can share. Defensive snapshots
cost more with effectful arguments than in pure benchmark inputs.

General TRY cleanup remains absent:if a later start/count evaluation throws,
retained strings can leak(3 observed owners in each own probe). This package
does not fix or hide that debt; normal final0 wrappers are not exception proof.
No change to I64 width metadata, Val, NumLocal,Dyn representation, cache size,
MT TRY admission,instrumented MT restriction, macOS/ARM or native Windows.
This is the requested typed StrTran4/5 increment, not all string compatibility.

| Bytes | Case | Native ns/call | Harbour ns/call | C reference ns/call |
| ---: | --- | ---: | ---: | ---: |
| 64 | replace | 42.96 | 364.96 | 97.82 |
| 64 | expand | 42.17 | 306.56 | 187.50 |
| 64 | delete | 74.85 | 538.62 | 289.86 |
| 64 | multi | 288.20 | 502.39 | 178.94 |
| 64 | miss | 152.44 | 435.54 | 57.66 |
| 64 | prefix-miss | 117.13 | 1517.85 | 281.70 |
| 64 | unlimited-replace | 234.29 | 958.83 | 99.03 |
| 64 | unlimited-expand | 122.53 | 623.02 | 98.19 |
| 64 | unlimited-delete | 151.13 | 557.07 | 215.67 |
| 4096 | replace | 98.52 | 5317.85 | 4142.80 |
| 4096 | expand | 195.97 | 5516.16 | 17065.47 |
| 4096 | delete | 168.14 | 5328.62 | 18005.16 |
| 4096 | multi | 13283.30 | 29770.81 | 3688.53 |
| 4096 | miss | 1207.40 | 5189.42 | 2111.90 |
| 4096 | prefix-miss | 4366.89 | 174408.04 | 24792.25 |
| 4096 | unlimited-replace | 12349.89 | 39704.50 | 3813.81 |
| 4096 | unlimited-expand | 7286.60 | 43173.97 | 9478.10 |
| 4096 | unlimited-delete | 9773.05 | 31410.58 | 7145.45 |
| 65536 | replace | 2602.45 | 77752.26 | 71182.62 |
| 65536 | expand | 35074.42 | 78739.94 | 200218.19 |
| 65536 | delete | 2160.26 | 79540.99 | 219253.92 |
| 65536 | multi | 442731.59 | 427979.27 | 50802.43 |
| 65536 | miss | 39047.14 | 111850.58 | 77905.85 |
| 65536 | prefix-miss | 51094.01 | 2642458.12 | 407087.14 |
| 65536 | unlimited-replace | 87486.50 | 634532.60 | 37904.19 |
| 65536 | unlimited-expand | 229741.29 | 466654.52 | 128536.27 |
| 65536 | unlimited-delete | 85578.75 | 387046.73 | 163067.59 |
