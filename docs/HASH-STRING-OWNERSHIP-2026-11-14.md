# Hash string ownership, 14 November 2026

Review candidate against `bf358d6be60c95578d35185fd606d7394c97ea00`.
No publication is part of this package. Production changes are confined to
`src/hbc.rs`; fixtures, a checker and this note are supporting changes.

## Objective, short test, conclusion

A string in a hash must survive reading it, printing it or selecting on it.
A local copy must also survive deletion of the original hash entry. All owners
must release their own allocations, with the real registry empty after work
returns. The language-level result is measured against Harbour GTSTD at
`694428e1c12f726675b19324d62167fa77d68185`.

The short reproducer puts an owned string into a hash through an admitted Dyn
array cell, reads with `hb_HGet`, `hb_HGetDef`, `hb_HSetDef` or `hb_HValueAt`,
then selects, stores or prints the result. Before this fix, all 24 cases
(four getters x three consumers x Linux/Wine, instrumented) exit 1 with an
allocation-registry mismatch. The existing 19 getter fixtures only exercise
scalar payloads; they did not prove string ownership.

The same 24 cases now exit 0 with the final actual `hb_memcheck()` equal to 0.
The extended `h["k"]` cases also pass: switch already passed the base; store
and print previously failed on both targets. This is a fix, not merely a new
characterization of the old failure.

## Ownership contract

Raw hash runtime helpers continue returning borrowed payloads. The hash keeps
its string until entry deletion or hash cleanup. The language builtin call
boundary now returns an owned string copy for the four getters. This matches
the admitted Dyn call-result contract used by consumers. Non-string scalar
tags pass through without a string allocation.

Consumers clone borrowed Dyn expressions, including hash indexing, and move
owned results instead of cloning and abandoning them. This applies at local
initialization/assignment, switch, parameter, return, DATA and thread argument
boundaries. Print releases only an owned temporary. The ownership predicate
recognizes calls/messages and recursively the tail of a sequence; selected
Dyn IIF arms normalize borrowing at the branch. This does not add acceptance
of the rejected IIF/sequence probes listed below.

Defaults are snapshots: borrowed defaults are copied, owned defaults move.
HGetDef releases the unused snapshot on a hit and transfers it on a miss.
HSetDef copies into the hash, copies its result and releases its snapshot.
Hash literal initialization/reassignment, HSet and indexed writes release an
owned value temporary after the hash has copied it. Comparison operands keep
an owner through either branch and release once; this was previously gated
on DBF use, leaving non-DBF owned getter comparisons leaking despite rc 0.

No runtime string/value layout or raw helper ABI is changed. The fix does not
transfer the hash's allocation into a consumer.

## Evidence

Candidate compiler SHA256:
`080f63139353a28e2729ba4935f27ecaf102dc9a1267122b1fbec9afe228b60a`.

The committed fixture set has 28 PRGs with exact stdout and stderr companions:

- 12 getter/consumer combinations and three indexed-read combinations.
- 13 extra cases: HGetDef borrowed/owned defaults on hit/miss, unused owned
  default result, HSetDef owned defaults on hit/miss, owned hash init/write,
  owned parameter/return, Dyn reassignment and an owned comparison operand.

Each PRG executes `work()` and then calls the candidate's real `hb_memcheck()`.
All 28 sources x two targets x normal/instrumented = 112 channel checks match
stdout, stderr and exit status exactly, with final registry count 0. This is
also reproduced by `tools/check_hash_ownership.py`. As a sensitivity check,
running that checker against the base fails 88/112 checks, including all 48
getter/consumer checks in both modes (the original 24 instrumented failures).
Linux/Wine run the same
candidate contract. Wine is not a native Windows Harbour oracle.

For oracle runs only, a `hb_memcheck()` function returning zero is appended,
because the pinned Harbour does not provide the candidate allocation registry.
This shim does not measure Harbour allocations. No shim is used in candidate
runs. All program-visible channels are exact against the Linux GTSTD oracle;
the candidate registry check is additional evidence, not proof supplied by
the oracle shim. The source archive was rechecked against
<https://codeload.github.com/harbour/core/tar.gz/694428e1c12f726675b19324d62167fa77d68185>;
SHA256 `80ce1e926bf352d4b12d277f06d13df259f9d06322193e1912a6c0c5f1eab355`.

The full manifest grows from 1692 to 1720 without changing old expectations.
Four complete traversals of this exact candidate give:

| Target | Mode | Passes | Base-identical gaps | New regressions |
| --- | --- | ---: | ---: | ---: |
| Linux | instrumented | 1720 | 0 | 0 |
| Linux | normal | 1719 | 1 | 0 |
| Wine | instrumented | 1699 | 21 | 0 |
| Wine | normal | 1698 | 22 | 0 |

The normal-only gap is `t230_registry_guard`. The other 21 are the existing
Linux-only class gate and 20 CurDir/diagnostic-precedence cases. Every gap was
freshly compared with the base executable, not relabeled as a pass. Raw rows
retain all observed channels and the baseline comparison.

## Reproduce

Build `src/hbc.rs` with Rust, then run from the repository root:

```sh
python3 tools/check_hash_ownership.py --compiler /path/to/hbc \
  --output /tmp/hash-ownership.json \
  --wine /path/to/wine --wine-prefix /path/to/prefix
```

Omit the Wine options for 56 Linux-only checks. The checker compares exact
bytes, process status and the final registry zero in each expected stream.
The review evidence includes the pinned-oracle harness and raw results,
baseline failures, fixture hashes and four full manifest traversals.

## Limits

This fixes the measured admitted string/scalar hash-result paths, not general
Harbour hash/value semantics or universal Dyn lifetime safety. Direct string
literal hash initialization in this source shape remains outside acceptance;
the fixtures deliberately use an admitted Dyn string cell. Five attempted
edge forms still reject before code generation: an owned call in the tested
array construction, two IIF forms, the tested Empty form and the tested
sequence form. These rejections are retained as limits, not claimed passes
or broadened into this increment. No LLVM ownership parity, native Windows
Harbour oracle, Windows-only class/CurDir support, object/array hash-payload
ownership, performance improvement or full upstream-program admission is
claimed. Thread/DATA paths inherit the same ownership rule, but the new
28-source focused matrix does not independently exercise every such boundary;
the existing manifest provides regression checks, not an exhaustive proof.
