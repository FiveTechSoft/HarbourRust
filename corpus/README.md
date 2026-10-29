# Harbour source inventory and coverage states

This is metadata about the pinned official reference, not copied Harbour code.
The project's implementation remains its own MIT code. Harbour is an external
behavioural oracle; inventorying a file does not approve running it or linking
its libraries into HarbourRust.

Reference:694428e1c12f726675b19324d62167fa77d68185
Source:https://codeload.github.com/harbour/core/tar.gz/694428e1c12f726675b19324d62167fa77d68185
Tarball SHA256:80ce1e926bf352d4b12d277f06d13df259f9d06322193e1912a6c0c5f1eab355

Inventory:1203 files (1041 .prg,19 .hb,143 .ch). These are NOT1203 examples or
1060 standalone programs. Profiles partition files, not language coverage:
A-tests, B-extras, B-utils, C-contrib, internal-source and support. Headers are
not runnable tests. Entrypoints, runtime dependencies, effects and platform
needs still require review. Includes/main regex fields are review hints only,
not a parser or execution-readiness proof. Never execute arbitrary originals
in bulk based on those hints; isolate file/network/RDD/interactive cases.

The frozen175 compilation evidence is imported with exact file hashes and
compiler SHA f5daec7beb1f63af2b416756c063d5e2330c43b9. Counts20 default /14LLVM
accepted are compilation ONLY. No row is marked executed by this inventory.
not-audited means this manifest has not reconciled an execution result, not
that no separate execution evidence exists in the experimental suite. Prior
original execution checks remain separately recorded in those test logs.

Reproduce inventory from an already obtained reference and exact compile audit:

```
python3 tools/inventory_harbour.py --core /path/to/harbour-core \
  --reference 694428e1c12f726675b19324d62167fa77d68185 \
  --audit corpus/frozen175-f5daec7-compile.json --output /tmp/inventory.json
cmp /tmp/inventory.json corpus/harbour-694428e1-inventory.json
```

Per-file progress must move through independent gates: reviewed entrypoint and
safe fixture; reference compiles/links/runs; each backend compiles/links/runs;
stdout/stderr/exit/effects match or have an explicit divergence; sizes captured;
performance comparable and measured. A compiler acceptance is not a runtime
pass. A blocked dependency is neither a pass nor a failure of the language.

## Roadmap working order

P0 inventory and family matrix; P1 comparable speed/size controls; P2 lexical
and preprocessor gaps; P3 scopes/control/functions; P4 representations/runtime;
P5 blocks/classes/dynamism; P6 library/I/O/RDD/contrib; P7 profile closure.
P1 is a gate on every implementation phase, not postponed until the end.
P0 is in progress: file inventory exists, entrypoint/dependency review and full
syntax-family/test matrix remain. P1 has11 trace-equivalent scalar controls and
3 bounded full-process cross-language cases. No language-wide parity claim.

New representations, memory/aliasing models, macro evaluation and extension
bridges require their own decisions. This roadmap records needs, not authority
to change those contracts or merge the experimental backend into main.

## Full recursive tests compile audit

`tests268-9e9ff8b-compile.json` adds all268 .prg in tests recursively, with
hashes and first diagnostic for each backend and Linux/Windows target profile.
Linux21 default/15LLVM accepted; Windows20/14. No linking or execution is
claimed. The only extra Linux acceptance beyond frozen175 is dynwin.prg:
its Windows-only dynamic DLL/GUI body is excluded by preprocessing. Windows
rejects hb_DynCall. This is NOT support for that feature. Keep the frozen175
20/14 denominator separate; don't substitute a larger raw acceptance count.

`tools/audit_harbour_tests.py` reproduces the compile-only sweep with an explicit
compiler, source root, reference SHA and compiler SHA. It compiles into a
private temporary directory with10s compiler timeouts and never runs originals.
The inventory's175 baseline is retained rather than silently replacing it;
this268-file evidence is a separate wider audit pending reconciliation into
per-profile coverage. First diagnostics are not a complete missing-feature list.

## Reviewed originals: exact Linux execution gate

`reviewed-console-originals.json` is a hash-pinned, manually reviewed allowlist
of14 deterministic console sources. They use no files, network, GUI or input.
`tools/check_reviewed_originals.py` is opt-in, needs an explicit core/compiler/
hbmk2/output directory, and fails before running if any source hash changed.
It never discovers new execution candidates automatically. Reference output
is compared without normalization to default and LLVM stdout/stderr/exit.

Fresh Linux evidence at89f3ead: all14 exact against rebuilt Harbour pcode/GTSTD:
comments,define,docase,exit,fornext,hello,ifelse,ifinline,longstr,procline,
recursiv,returns,statfun,while. Not14new language features or a claim that all
268 originals pass. dynwin excluded: Linux preprocesses out its feature body.
No Windows reference execution or performance claim is made by this gate.
Existing PE/Wine expected-output tests remain separate evidence.

Run with HARBOUR_LLVM_LIB/LD_LIBRARY_PATH as in the LLVM suite, after building
the desired compiler. The caller supplies its SHA; results record that SHA.
No reference source body is added here. Output files remain in the selected
local directory; only hashes/byte counts/result status enter versioned evidence.

## Syntax family seed matrix

`syntax-family-seed-b105ae0.json` maps17 named families to37 existing project
regression cases with fresh148 compile checks (default/LLVM x Linux/Windows).
It is a SEED, not the entire Harbour grammar or a coverage percentage. The
pending_families list explicitly keeps dates, exceptions, dynamic binding,
macro evaluation, full classes, I/O/RDD and library/platform work open.
Manifest kind records the intended existing regression category, not a new
runtime execution. A rejected negative test can be a correct boundary; it
never counts as implementing the rejected Harbour feature. The class entries
are parser/rejection gates, not class-runtime support. Dynamic-array/static-arg
names refer to existing data-shape tests, not file-scope STATIC storage.

Run `python3 tools/check_syntax_family_seed.py --compiler /path/to/hbc` to
recheck source hashes, diagnostics and acceptance. This check does not run
any test program. Original source coverage remains in the175/268 audits.

## Bytes for reviewed originals

`console14-89f3ead-sizes.json` measures the actual14 Linux programs from the
exact-output reference run: executable bytes/hash, GNU size fields, and LLVM
sized function symbols. Default assembler and Harbour artifacts do not expose
comparable precise function-boundary sizes here; those values are NOT guessed.
`tools/size_reviewed_originals.py` regenerates the report from a successful
execution directory. These are not runtime-equivalent whole-binary codegen
comparisons (Harbour bundles a runtime, HR is freestanding); source-path/layout
changes can alter artifacts. There is no Rust translation or timing claim for
these14 originals. Rust comparison remains the separate reviewed kernels and
bounded-process cases until equivalent programs are defined and validated.

## Five default-only reviewed originals

calling,lnlenli2,mem,nums,passref also match rebuilt Harbour pcode/GTSTD
byte-exact on Linux (stdout/stderr/exit0). LLVM still rejects them; do not
count them as LLVM support. The opt-in gate supports --default-only and a
separate --allowlist corpus/reviewed-default-only-originals.json. The14-case
default path remains unchanged and was rechecked after this script extension.
19 reviewed originals now have default/reference exact execution evidence;
14 of those have LLVM/reference evidence. This is not19ofall268 passing both.
lnlenli2/mem output is empty; successful execution is not proof of no leaks or
complete lifetime semantics. errsys is intentionally excluded because its
reference error handler needs a separate controlled-error harness. No adaptation
or removal of error behavior is authorized by this result.

## Reconciled ledger

`coverage-ledger.json` joins the1203 inventory,268 compile profiles, frozen175
baseline and reviewed19/14 execution evidence without overwriting originals.
Each gate retains its compiler SHA and evidence filename. Source hashes must
match before joining. No tests execute during this operation. Missing gates
are unknown, not failed/passed; review is limited to the Linux console profile.
The reference Linux execution count19 is separate from default19 and LLVM14,
not57 independent original programs. Run tools/coverage_ledger.py to regenerate.
