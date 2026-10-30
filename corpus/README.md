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

## Manual entrypoint/dependency review,25 sources

`manual-entrypoint-dependencies-20261029.json` records full-source manual review
of12 MT tests,3 multifnc modules and10 frontier/default-only originals. Hashes
and exact line witnesses tie each judgment to the pinned source. This is25
source review records, not25 new executed/accepted programs. Five overlap the
existing19 default/reference executions.20 had no prior reviewed execution in
that allowlist. Dependencies are required capabilities, not verified installs.

Important partitions found by reading, not main-name regex:
- multifnc's3 sources belong to ONE project. Only t0 has Main; t1/t2 are companion
  Main2/Main3 procedures. The project permits duplicate linker definitions and
  t1 embeds C. Isolated-file compile failures are not a full project verdict.
-12 MT sources require thread/runtime-specific harnesses. Some block on input,
  one has intentionally racy counters, one creates/writes/deletes a DBF, one
  opens per-thread GT windows, one has an infinite background clock loop.
  A future MT harness needs invariants and event assertions, not fixed stdout.
- dynwin's Linux acceptance skips the Windows feature body. The Windows body
  loads DLLs, shows a message box and toggles a Windows desktop setting. It
  must not be executed as an ordinary console regression.
- dates reads the current date and changes formatting; errsys intentionally
  faults. funcarr depends on shared static arrays and VM introspection. These
  need declared comparison semantics, not whitespace/time normalization.
- arrindex is a deterministic-looking console candidate after manual review,
  but missing nested/missing-value array semantics remain a separate contract.
  This review neither implements it nor permits automatic execution.

`manual-review-family-index.json` groups the observed constructs from those25
sources. Tags are research/navigation aids, not a complete grammar, parser pass,
implementation count or coverage percentage. They complement the17family seed,
not expand17 to a larger number of completed families.

```
python3 tools/check_corpus_review.py --core /path/to/pinned-core \
  --output /tmp/manual-review-index.json
cmp /tmp/manual-review-index.json corpus/manual-review-family-index.json
```

This verifies hashes and line witnesses without compiling or executing any
reference program. It intentionally does not infer safe execution from those
witnesses. Entry/dependency review of the remaining inventory stays pending.

The ledger now reconciles the25 manual reviews alongside existing execution:
39 distinct sources have either manual entrypoint/dependency review or reviewed
execution evidence (25+19-5 overlap). Only19 default/14LLVM have exact execution
results. Neither39 nor25 is an automatic execution allowlist. Earlier per-gate
compiler provenance is preserved, including pending states for other profiles.

### Expanded review:48 sources /62 distinct reviewed-or-executed

A second pass adds23 small source/script records to the initial25, bringing
manual full-source review to48 and the union with19 previously executed
sources to62 (48+19-5overlap). Prior25/39 counts above describe the first batch.
Execution remains19default/14LLVM. No new original was compiled or run.

The additional pass separates environment queries, report/DBF fixtures,
module exports/INIT procedures, C-embedded builds, audio, subprocesses,
loopback sockets, file effects and utility scripts. Small file size does not
mean safe console example:
- stripdoc.hb overwrites matching .c/.prg in its current directory.
- hbpp/compare.hb runs Harbour,Clipper and diff, then deletes intermediates.
- osshell.prg is marked NOTEST and starts an interactive OS shell.
- ipclnt connects to127.0.0.1:10000 and sends a quit message. Loopback is not
  permission to contact a pre-existing service.
- fileio/fileio2 truncate test.txt; usrrdd/exmemo creates three memo tables.
- hrbext is a module with exports and INIT,not a standalone Main program.
- initproc has both INIT and Main; startup behavior needs its own measured
  oracle rather than inferring semantics from a comment.
- environment/memory/disk/date outputs require declared field/invariant
  comparisons,not fixed numbers,blind normalization or generic speed claims.

The family index now has83 observed tags across48 sources. This is a navigation
index only. It does not replace the17-family implementation-test seed or assert
83 implemented/full grammar families. The unreviewed inventory remains pending.

### Third batch:74 manual records /88 distinct reviewed-or-executed

26 further full-source reviews cover the remaining5 usrrdd examples and21
small lexical,closure,module,numeric and effect cases. The reviewed/executed
union is88 (74+19-5overlap). Execution stays19default/14LLVM. No original was
compiled or run during this review. Earlier counts above are batch history.

All6 usrrdd sources now have requirement/effect records. In particular exlog
modifies an existing table and logs machine/user identity; exhsx creates an
index and appends fixture records; exrlx exercises repeated locking. This is
not6 supported drivers or6 runnable cases. No RDD implementation source read.

statics1/statics2 form a source-declared companion pair,distinct from the
explicit .hbp manifest grouping for multifnc (neither project build-verified here); neither was linked here.
dupvars is a diagnostic case,not an exit0 test. fwdref's TOFIX and sortbug's
TOFIX are comments to investigate,not proof of current reference behavior.
test.prg writes embedded NULs and needs binary capture. for2 waits for keyboard
input despite its small size. Arrays with cycles,closures with later locals,
static initialization,PUBLIC lookup and symbol objects need their own existing
contract gates. This review does not grant them or imply acceptance.

## Normalized planning workstreams,not grammar coverage

`syntax-workstream-taxonomy.json` replaces ad-hoc counting of observed tags with
an explicit routing crosswalk. Each of122 observed tags from74 manual reviews
has one primary workstream; each of17 compile-only seed-family IDs is linked
once. Sources can belong to multiple workstreams,so memberships must not be
summed as distinct examples.15 workstreams are planning buckets,not15 completed
families or the full Harbour grammar. Phase labels are intended dependencies,
not permission to implement a new contract.

`syntax-workstream-evidence.json` joins original-source paths and existing
regression paths per workstream. Six workstreams have no assigned seed-family
link: strings/dates/settings,threads,RDD/reports,filesystem/process/network,
GT/GUI/input/audio and environment/introspection. This is a visible missing
matrix link,not proof that every feature is absent from the compiler. Existing
unmapped regression tests may exist; reconcile them before calling a capability
unsupported. A seed link similarly does not establish complete syntax or runtime.

```
python3 tools/check_syntax_workstreams.py --output /tmp/workstream-evidence.json
cmp /tmp/workstream-evidence.json corpus/syntax-workstream-evidence.json
```

The check rejects duplicate/missing tag or seed assignments. It calls no
compiler and executes no reference program. The original seed's compiler SHA,
source hashes and compile acceptance/rejection remain the supporting evidence;
this metadata operation does not refresh them or create a new test pass.

## Supplementary links,not missing capability inference

`syntax-supplementary-regressions-e71b0ed.json` links7 manually read existing
regressions to two previously seed-unlinked workstreams.28fresh compile checks
record both backends/targets. SET decimal/dateformat/century/printer and ancestor
ProcLine are rejection boundaries. Trim and current ProcName tests are default
accepted,LLVM rejected. This is evidence a missing seed link did not mean all
string/introspection functionality was absent. Default runtime provenance is
separate: these existing manifest rows were in the1098PASS e71b0ed battery.
This metadata step executes no program and claims no new LLVM runtime pass.
The17family seed and its original compiler provenance remain unchanged.

### GT/input batch:84 manual records /98 reviewed-or-executed union

Ten full-source GT/input/class reviews bring manual records to84 and the union
with19existing execution cases to98 (84+19-5overlap). Execution remains19/14.
The existing workstream taxonomy is refreshed for these memberships,not expanded
into a claim of completed grammar. No original was compiled or run.

Screen tests require spatial/cursor/color/driver assertions,not only captured
stdout. box3 emits BEL;gtcolors changes blink;cursor changes cursor modes;
wvt_fs changes graphical font/fullscreen/AltEnter settings. A non-graphical
QUIT from wvt_fs would not prove graphical feature support. browse reads a DBF
fixture and waits for input. cls is class ON ERROR with modal Alert,despite its
short generic filename. achoice6 uses fractional coordinates and injected keys;
its RTE comment is an investigation lead,not a measured result. These records
specify controlled input/screen/restore requirements without authorizing effects.

### Class batch:90 manual records /104 reviewed-or-executed union

Six class/inheritance/object-lvalue/persistence sources are now fully read and
recorded. Manual90 plus prior19 execution minus5 overlap yields104 distinct
reviewed-or-executed sources,not104 passing programs. Runtime remains19/14.
clasinh calls a modal Alert via a super method;persist writes test.txt and
has property/date/virtual-method metadata. classes builds HBClass dynamically
without requiring hbclass.ch,so header-marker acceptance is not a class-runtime
test. objasign changes object-slot types and prints VM stack/static metadata.
inhprob needs three-level self/super dispatch evidence. No class program was
compiled or run;no class runtime,storage or ABI contract was changed.

### Numeric/library/clock batch:100 manual /114 reviewed-or-executed

Ten more full-source reviews bring manual records to100 and the distinct union
to114 (100+19-5overlap);executions remain19default/14LLVM. No new original was
compiled or run. fib is a bounded deterministic candidate but its untyped/NIL
locals and signatures still need gates. speed is a closure-array/Eval loop,
not the scalar inverse kernel. and_or deliberately faults after successful
short-circuit checks. multiarg inspects missing/heterogeneous arguments.
longstr2 needs separate large stdout/stderr captures;sha1 can print raw digest
bytes;base64 uses hash enum-key metadata as well as library algorithms.
seconds has input-dependent profiles;ticktime is a10second busy-clock probe,
not a compiler speed benchmark;dates3 mixes fixed dates with current-clock data.
Library/numeric review does not create runtime/representation authority.

### Structural/alias batch:110 manual /124 reviewed-or-executed

Ten further full-source reviews give110manual records and124distinct sources
in the reviewed/executed union;execution stays19/14. No new original compiled
or run. linecont is NOTEST with unresolved helper calls and NIL operations,
so lexical tests must not assume it is a safe runnable application. pragma
intentionally exercises compiler options/invalid values. altd needs a debugger
session;version should compare identity fields,not pretend Harbour branding.
base2 includes runtime macro and WAIT despite numeric-literal focus. for prints
its bound/step callbacks and needs order/count assertions;its step0 is only TODO.
byref/codebl2 require nested alias and early/late dynamic binding semantics.
array16/arrays are distinct mixed dynamic-array programs,not fixed I64 arrays
or one duplicated success record. Their hashes and different sizes are retained.

### Routing/GET/macro batch:124 manual /138 reviewed-or-executed

Fourteen additional full-source records bring manual review to124 and the
union to138;execution stays19/14. No new original compiled/run. output/dev route
to alternate/extra/printer files and screen;they require isolated virtual output,
not a real printer. flink creates hard/symbolic links and artifacts;rights are
platform constraints,not a reason to elevate privileges. libname only constructs
names,not loads DLLs. GET cases mix widgets,macro binding,mutable indices and
RDD aliases;getblock creates two tables before READ. omacro builds dynamic
object setters/getters. idle registers callbacks and waits;langapi changes
language registry selection;ddate mixes literal dates with clock macro data.
Comments describing expected file size or old platform bugs are not new oracle
results. Metadata distinguishes these gates without extending runtime authority.

### Directory/SET/key/serial profiles:130 manual /144 reviewed-or-executed

Six further full-source reviews give130 manual records and144 distinct sources
in the union;execution stays19/14. No original was compiled or run. adir needs a
controlled directory tree and separate assertions for unequal output arrays and
invalid arguments. files creates1000 tables, opens them simultaneously, then
drops them;interruptions can leave artifacts. Its DBFCDX define alone does not
select or verify that driver. set mostly queries settings but changes directory
separator;printed labels beside numeric IDs are not mapping evidence. setkeys
needs scripted nested input and restoration of the key registry.

com sends modem commands to a serial device;commouse also toggles DTR/RTS and
flushes/reads device data. Neither is safe to classify as ordinary console IO.
Use separately authorized virtual serial endpoints, not real hardware. A usage
return or failed open proves neither protocol nor device support. commouse has
an undeclared nI and a packet branch that checks four bytes before reading a
fifth;these are source-review findings,not measured failures or permission to
rewrite the original. Fragmentation/buffer behavior requires a separate oracle.

### Service/module profiles:139 manual /153 reviewed-or-executed

Nine additional full-source reviews and a richer existing hrbext record give139
distinct manual records and153 distinct sources in the union:139+19-5=153.
Validators now reject duplicate manual source rows before counting them.
Executions remain19default/14LLVM and are historical,not rerun.
No compiler or original was compiled or run for this metadata batch.

ipsvr binds0.0.0.0:10000 and detaches workers;server opens an Inet listener with
an unspecified address in its call. Neither can be treated as loopback-only or
run automatically. pipes spawns copies of itself,uses a10MB buffer,and tests
merged stream aliases and an exit123 child;timestamps/PIDs/chunk boundaries
need invariant-based comparison rather than exact diagnostics.

cgi and inifile have no Main and are library companions for guestbk,not separate
applications. guestbk uses an absolute /www/root fixture and can rewrite its INI;
even TIniFile construction can create a missing file. html has its own THTML
class and a commented SaveToFile call in Main;linking both THTML definitions is
not the intended unit. hrb can invoke a shell compiler if the HRB is missing;
hrbext is a separately loaded module with INIT and overlapping symbols,not an
ordinary linked companion. dyn requires architecture-specific DLL exports and
explicit type/calling-convention/encoding checks. Grouping metadata records
these relationships without building,deployment,network/device access or new
runtime authority. Original bodies are not copied into this repository.

### Alias/RDD artifact profiles:149 manual /163 reviewed-or-executed

Ten additional full-source reviews give149 distinct manual records and163 in
the union (149+19-5). Historical executions remain19/14;no new compile or run.
alias is NOTEST with uninitialized values and unspecified workareas,so its
aliased-expression/pcode focus does not make it safe to execute. aliasrt writes
AGE into the existing test fixture. aliaslck and use create missing files but
later delete their named tables even if they already existed:only disposable
fixtures qualify for any future harness. Lock and error-state assertions are
separate from stdout matching.

cdx explicitly selects DBFCDX;ntx index filenames alone do not prove which RDD
was selected. dbf starts with DBFCDX but recreates its table using the default
driver and later inspects DBT files;the two phases must not be conflated. ZAP,
PACK,memo storage,filtering and input pauses need explicit artifact/state gates.
dbi writes a separate report and calls dbInfo setter forms,not only queries.
delim/sdf both remove test8.txt and attempt import from a deliberately missing
file;they need controlled error handling as well as export-byte comparisons.
The old SDF implementation comment is not evidence of current support. None of
these records authorizes RDD/runtime changes or access to existing user data.
