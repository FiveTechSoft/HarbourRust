# Thread-start runtime-name delta after c9effca4

BASE c9effca4417adaaf79e9836eefe8523e58ec64f4 already lifts supported block
literals and known literal names into function-reference starts. This delta
preserves that lifting and adds runtime lookup for typed string targets.
It does not install a block-value thunk or a general closure representation.
Linux x86-64 only; Windows/macOS threads remain rejected.

```sh
rustc src/hbc.rs --edition=2021 -C opt-level=1 -C debuginfo=0 \
  -C strip=symbols -o /tmp/hbc-name-delta
python3 tests/threads-start/check_oracle.py \
  --compiler /tmp/hbc-name-delta --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 \
  --output /tmp/thread-name-oracle
python3 tests/threads-start/check_limits.py \
  --compiler /tmp/hbc-name-delta --output /tmp/thread-name-limits
python3 tests/threads-start/compare_base.py \
  --base /tmp/hbc-c9 --compiler /tmp/hbc-name-delta --output /tmp/thread-name-regression
```

Requires official Harbour commit694428e1c12f726675b19324d62167fa77d68185
built with MT support, Rust1.100.0 and GNU as/ld. Output directories must
not exist. Every command, raw stdout/stderr and rc is retained. No newline
normalization. PE comparison is compilation/emission only, not execution.

## Results and meaning

The original33 probes from the superseded broader prototype are retained.
On c9 BASE,12/33 pass; this delta reaches30/33. The remaining3 are preserved
as explicit inherited compile limits, not counted as raw oracle passes:

- `block_variable`: the published lifting only handles block literals.
- `stress`: likewise uses a block variable; replaced for active stress by
  an additional `stress_literal`, without deleting the original probe.
- `name_literal_missing`: Observe(s) with no literal argument fails its
  existing parameter inference. No extra inference fix is bundled here.

Two additional lifted-block probes prove BASE's string parameter/result
support is preserved. With `stress_literal`, the gate has36 cases:
33 raw Harbour/internal-ELF/GNU-as-ld differentials and3 expected baseline
compile limits. The limits still compile with Harbour, but this gate does
not run them as successful equivalence cases. Every raw differential
compares the complete `(rc,stdout,stderr)` tuple and exits0 on all3 paths.

Coverage: exact Lailton case, lifted blocks, names as literal/variable/
expression/owned temporary; case,NUL/space/tab; name snapshot across later
by-reference mutation; evaluation order,ignored extras,NIL dynamic-name
omission,string/logical/mixed identity values,12args,owned returns,shared
reference/name thunks. Stress per executor:2000integer threads plus200
owned-string threads. Worker console output is serialized before Main.

12 named-limit checks cover inherited platform/instrumentation guards,
invalid targets,capture,float/array thread values,float results,Main,and
unknown runtime/literal names failing after argument effects. These are
not Harbour error-output equivalence claims.

Full manifest:1743cases xLinux/Windows compile rc/stderr match c9 BASE;
1172ELF+1160PE assemblies match byte for byte;1171Linux positives execute
with matching raw rc/stdout/stderr. This is regression evidence, not a
claim that every inherited fixture oracle is correct.

Existing F1-F4 suite:34/37 with original sources (three reserved local
`val` rejections also on BASE),37/37 with only that identifier renamed in
private copies. Of the latter,36 are raw output+rc0 comparisons,1 is the
inherited SubscribeNow-flush PREFIX exception (Harbour rc124,candidate0).
Tracked historical test sources are not silently modified.

## Limits

See docs/THREADS.md. No Windows MT,captures,block-variable targets,general
closures,Dyn target values,numeric attribute prefixes,new thread argument
ABI,builtin/Extend/method dispatch or substitutable errors. Runtime names
select compatible integer/Dyn/object parameter ABIs only. Unknown names
left by lifting now fail at runtime. Existing retained-until-process-exit
thread-handle storage and instrumentation restrictions remain. No exact
hb_memcheck/leak-free/performance claim is made.
