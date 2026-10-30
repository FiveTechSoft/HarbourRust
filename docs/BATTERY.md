# Battery evidence model (since the QOut audit, 2026-10-25)

`tests/manifest.txt` is the versioned record: one line per test,
`pos <file> <escaped expected stdout>` or `neg <file> <error substring>`.
Positive expectations are derived per category, not assumed:

- **HB-EXACT** (65 tests): bytes captured from the Harbour 3.2.1dev
  reference compiled with `-gtstd` (clean stdio, no ANSI console codes).
  The earlier quick oracle (`hbmk2 file.hb` script mode) runs ONLY the
  first function in the file, not `main` - it was never valid for
  multi-function tests and is no longer used as an oracle.
- **HB-ADAPT-MATCH** (7: t13, t20, t23, t28, t31, t48, t52): Harbour
  rejects the original file (LOCAL after an executable statement). The
  adapted variant (LOCALs hoisted to the function top, semantics
  unchanged) compiles under Harbour and matches our output BYTE-EXACTLY.
- **MODEL** (4: t11, t25, t54, t15): the adapted variant changes meaning
  under our ownership model (move/revive) or is invalid Harbour outright
  (t15: block-scoped duplicate LOCAL; Harbour locals are function-scoped).
  Expected output is our own; the difference is the Rust model, by design.
- **DIVERGE-NUMERIC** (2: t45, t46): Harbour does NOT terminate - its
  double counter cannot advance past 2^63 (observed: 20s timeout while
  printing repeated values). HarbourRust (i64) terminates bounded with
  exact output. Registered model difference, not a bug to fix.

Audit corrections from the QOut review:

1. Earlier "MATCH" labels were computed with whitespace normalization.
   Harbour `?` pads integers to a 10-column field and emits the newline
   BEFORE the items (QOut semantics) - all prior integer MATCH claims
   were not byte-exact. The current battery is byte-exact.
2. The battery runner previously executed STALE binaries when a build
   failed, masking two genuine compile failures (t61: for-bound did not
   pin the parameter type - fixed by pinning for-bounds as i64; t62:
   `id(x)` with only `return x` is beyond the PoC's inference - test now
   pins via `x + 0` with a comment; reverse call-site inference is a
   registered limit). The runner now fails loudly on any build error.

`?` byte semantics implemented (probes b51-b59, q1-q6): evaluate ALL
items first (side effects of calls happen before the newline), then one
newline, items joined by one space, integers right-aligned in a field of
max(10, digits+1) for positives and 10 (or 20 past 10 chars) for
negatives, strings raw (UTF-8 passthrough), no trailing newline; bare `?`
prints just the newline. Unary minus added (q1 needed `-7`).
Registered `?` differences: no float literals, no `.T.`/`.F.` or NIL
printing, trailing comma rejected (Harbour prints a NIL item - probe q4).

Benchmark: the frozen three-program series (bench/RESULTS.md) was
re-run after the QOut fix with unchanged configs; see the "Post-QOut
re-run" table there. b2/b3 outputs byte-identical to Harbour. b1_int is
WITHDRAWN as a speed comparison (Harbour runs its accumulator in double,
HarbourRust in i64: different numeric work per iteration); the bounded
replacement b1b_int_bounded.hb runs integer arithmetic on both models
with byte-identical output. See bench/RESULTS.md.

Ownership across QOut items (t123-t125, neg-MODEL): `? take(v), take(v)`,
`? take(v), v` and `? take(v) + take(v)` (take consumes a String) are all
rejected as use of moved value - moves ARE applied between QOut items and
inside expressions, matching the Rust ownership contract. Harbour accepts
all three (no ownership); the difference is the registered MODEL
category, not a bug.

## Arrays (t126-t139)

Fixed-size i64 arrays with Harbour base-1 indexing (probes a1-a5).
t126-t129 and the adversarial t140/t141/t145 HB-EXACT against compiled
Harbour (-gtstd) binaries: calls as literal elements and as indexes,
evaluation ORDER of `a[i] := v` (value first, then the index - Harbour's
observed order, the same as Rust's), whole-array reassignment. t130/t144
MODEL: assignment copies (Rust [i64; N] is Copy, rustc-verified); Harbour
shares a reference. t133/t142/t143 DIVERGE-FAILMODE: a runtime
out-of-bounds index (including i64::MAX/MIN) prints the Harbour wording
and exits 1; Harbour opens an interactive error dialog and hangs (no
oracle bytes exist). These three run under the manifest `posx` kind,
which asserts the EXIT CODE on both targets, not only the message.
Constant out-of-range indexes are compile errors (t131/t132). The t02 injection negative moved
one layer up: '{' is grammar now, so the rejection comes from the parser
("trailing tokens") instead of the lexer (U+007B) - same construct, still
rejected.

## Evaluation-order fixes (t146-t149)

`a[i] := v` checks and generates value-first, then index (Harbour probe
adv2; Rust's `a[i] = v` order agrees). The checker applies moves in the
same order, so `a[take(v)] := take(v)` (take consumes a String) is
rejected as use-after-move (t149, neg-MODEL) while one-sided consumers
t147/t148 compile and match Harbour byte-exactly. `for i := a to b`
evaluates the start before the end (Harbour probe c11; Rust `a..b`
agrees); t146 pins the side-effect order byte-exactly.

## Codeblocks v1 (t150-t160)

`{|p1, p2| e1, ..., eN}` with NO captures: the value is a code pointer
(8 bytes, Copy), invoked via the built-in `eval(b, args)`. The body is a
comma-separated expression list returning the LAST one (probe c4).
t150-t156 HB-EXACT against compiled Harbour: one/two/zero parameters,
reuse inside an expression, copy-on-assignment, and extra eval arguments
evaluated (side effects run) and ignored (probes c7/c7b). Fewer
arguments than parameters are a compile error (Harbour fails at runtime
with an interactive dialog, probe c8 - t158 neg). Captures are out of
this increment (Harbour accepts them, probe c3 - t157 neg, next
increment). Bodies are integer expressions only (t159 neg); codeblock
values do not print (t160 neg). No heap is involved.

### Codeblock safety review (t161-t163, probes c12)

Block types carry their arity, so rebinding a block variable to a block
of a different arity is a type error (t161). Blocks cannot be passed to
user functions in this increment (t162; argument errors now name the
actual kind, e.g. "got a codeblock", after a message fix). Non-integer
eval arguments are rejected (t163). Probe c12 (Harbour): in
`eval(block_expr, arg_expr)` the BLOCK expression is evaluated BEFORE
the arguments. Our v1 block expressions are side-effect-free literals
and variable reads, so the order is unobservable today; it becomes a
constraint on the increment that introduces block-returning functions
(blocks cannot be returned in v1).

## Multidimensional dynamic arrays v2b (t183-t207)

Arrays of dynamic arrays: `{{1, 2}, {3, 4}}`, reads `a[i][j]` and the
comma form `a[i, j]` (Harbour m2: identical), writes, `len` at both
levels, `AAdd(a[i], x)` / `ASize(a[i], n)` on subarrays, `Array(n, m)`
itself is not in the compiler (unknown function at compile time);
probes m3/m10/m11 record Harbour's NIL-filled slots for contrast. The
equivalent constructor path, `local a := {}` plus `ASize`, grows slots
that read NIL since iter 15 (t211); they read 0 under the pre-iter-15
i64 model.

Categories: the value cases are HB-EXACT (probes m1/m2/m5/m6/m7). The
ownership cases are OURS-ONLY: Harbour's `b := a[1]` aliases the shared
subarray (m4) and AAdd on it mutates what every alias sees (m5); we move
the child into the parent, and extraction is a compile error in this
increment (indexed borrows only). Destruction is proven by alloc-identity
(hb_memcheck balance 0 across function boundaries), not by output. m8's
ASize shrink shows Harbour's observable reduction only - we claim nothing
about Harbour's internal lifetime. t207 is DIVERGE-FAILMODE: indexing a
fresh null child is a clean bound error (exit 1), not Harbour's dialog.

Two v2a fixes ride along: flat `a[i] := v` (checker gap - t193) and the
epilogue preserving the return value across frees.

## Dynamic arrays v2a (t164-t176)

`{}` is the empty DYNAMIC array (t138's old rejection is superseded and
its manifest entry removed): AAdd/ASize built-in statements grow/resize
in place, `len(a)` reads the length, elements are i64. Ownership: a
dynamic array has exactly one owner; assignment / call / return MOVE
(the source slot is nulled, so each allocation is freed exactly once at
its owner's exit, reassignment or re-declaration). No GC, no reference
counting, no shared aliases: Harbour's sharing patterns (probes d6-d9,
e9) are registered MODEL divergences. Heap: mmap on Linux, HeapAlloc on
Windows, capacity header before the data, doubling growth, checked
overflow, OOM abort. t166 proves alloc/free balance 0
across function boundaries via hb_memcheck(); t173-t175 pin the
compile-time rejections; t176 pins ASize's negative-size runtime error
(clean message + exit 1 vs Harbour's interactive hang).

## NIL as a true tagged value, v2c (t35/t104/t165 updated, t208-t223)

NIL is the tagged union Ty::Dyn ({tag, payload}, 16 bytes; tag 1 = NIL,
tag 0 = i64 payload) - the i64::MIN sentinel of the first v2c was
rejected and replaced, so i64::MIN is an ordinary value again (t213
coexistence in one array). `x := NIL` stores {1, 0} and prints "NIL";
`return nil` RETURNS it (n1c), so the old void-function rejections are
gone - t35 (mixed `return 5` / closing `return nil`) and t104 (a
`return nil` function's result is usable) are re-purposed to the
Harbour behaviour; t165's grown slots read NIL (fill {1, 0}).
Mixed returns unify to the tagged union in either source order
(t217 value-first, t219 nil-branch-first with an early `return nil`
inside a block, now a value return). Tags survive array reads
(x := a[i]), parameters, returns and if/while joins (t214-t216, t221);
`t211` is rewritten from probe n1c (NIL through a parameter and back;
its sentinel-era `p + 0` case is Harbour's type error, covered by
t218). A latent defect from the i64 era is fixed in the same pass: four
free sites (epilogue, re-declare/reassign, DArr2 child overwrite)
still passed element size 8 to hbc_free, so munmap length was
8+cap*8 against blocks mapped as 8+cap*16 - an under-unmap (leak)
for blocks spanning more than one page. Single-page battery
allocations were unaffected and hb_memcheck counts calls, not
bytes, so the battery could not see it; all free sites now pass 16.
The fix has teeth now (t224-t228): hbc_alloc records (base, bytes)
in a 16384-entry registry and hbc_free verifies the exact computed
length and liveness - a wrong size, an unknown block or a double
free prints "Internal error: allocation registry mismatch" and
exits 1. Negative control: reverting one site to element size 8
makes the harness fire. The five tests put >1-page and >2-page
blocks through the four drop paths (epilogue, reassign, local
re-declare in a loop, DArr2 child overwrite) plus shrink-nested;
the work runs in callees because main's own locals are still owned
when hb_memcheck() reads (its epilogue frees afterwards). The
registry's first version clobbered r9/r10 and broke hbc_asize's
shrink loop counter (caught by t190): hbc_free now preserves
rdx/r9/r10 across the registry work.
t208-t210, t212 unchanged. New: t213 i64::MIN/NIL coexistence,
t218 (posx) arithmetic on NIL prints "Type error: NIL used as a
number" and exits 1 on both targets, t220 (posx) ordering a NIL held
in a variable (the literal case stays compile-error t212), t221 loop
joins, t222 fixed arrays stay tagless [i64; N], t223 constant-folded
string comparisons (`=`: .F., `#`: .T.) still evaluate both operands
left to right.

Instrumentation mode (t229, t230): the allocation registry is now
emitted only with `--instrument`, which the battery uses for every
test binary; binaries compiled without the flag carry no registry and
no entry limit, so the harness adds no constraint to normal
compilation. The registry reuses freed slots (t229: 20000 alloc/free
cycles against one live entry, ending balanced) and stops clean when
all 16384 entries are live (t230: AAdd over 17000 children prints
"Out of memory" and exits 1 instead of writing past the table). OS
free results are checked in every build, instrumented or not: a
failed munmap or HeapFree prints "Internal error: OS free failed" and
exits 1, so a registry match can no longer mask an OS-level failure.
t230 also exposed a pre-existing off-by-one in the OOM path itself:
both targets wrote 15 bytes for the 14-byte "Out of memory\n"
message, leaking the first byte of whatever string followed it in
.rodata. No earlier test had taken a real OOM exit, so the battery
could not see it; both length constants are now 14. As before, the
harness verifies exact size, liveness and OS results on the paths the
battery actually exercises - it is not a proof of absence of leaks
on unexercised paths.

Hashes v1 (t231-t244): string-keyed hash maps with Harbour semantics
verified against compiled oracles. `{k => v, ...}` and `{=>}` literals,
`h[k] := v` writes (value evaluated before the key - probe h4),
`h["k"]` reads, `len(h)`. Keys are case-sensitive byte strings
compared with their length (h3b, h12: prefix keys stay distinct), the
empty string is an ordinary key (h10), duplicate keys in one literal
overwrite in place (h8: len 1, last wins) and each literal pair
evaluates its key before its value (h9 - the opposite of `h[k] := v`).
A missing-key read is Harbour's BASE/1132 dialog, which hangs
headless (h3/h3c): the registered failure mode is a clean
"Bound error: array access" with exit 1 (t234/t235). Values are tagged
scalars (integer or NIL, t240). Assignment MOVES the hash; the source
slot is nulled and use-after-move is a compile error (t241), the same
ownership rule as dynamic arrays. The block grows from 4 pairs
doubling, moving entries and freeing the old block shallow (t243);
overwrite keeps the pair count (t244). Key bytes are copied into
owned allocations on insert, so keys from string literals (rodata) and
from evaluated expressions are both safe; no general heap-string
lifetime is claimed. Insertion order is preserved internally by
construction but is NOT claimed verified: without hb_HKeys or
iteration there is no observable order, so no battery test asserts it.
t242 checks the alloc/free balance across a function boundary (the
callee's epilogue frees every key copy and the block, exact sizes
verified by the instrumented registry). Rejected in this increment,
all with clean errors: hash parameters, hash returns, whole-hash
printing, non-string keys, non-scalar values, hb_HKeys and iteration.

## Array() constructor (t245-t253)

`Array(n)` builds a Dyn-element array of n NIL slots through hbc_asize
(oracle a0: Array(0) is empty; m10: grown slots read NIL). `Array(n, m)`
builds n children of m NILs each through a new target-independent
helper, hbc_arraym (frame-held state only: the per-target
hbc_asize/hbc_aadd variants may clobber callee-saved registers).
t246 mirrors oracle avar (variable dimensions, nested write
`a[2][3] := 9`, read back 9, untouched slot NIL). t249 mirrors oracle
aadd (Array(2) then AAdd). Failure modes: Harbour's dialogs for
`Array()` (BASE/1111) and `Array(-1)` (BASE/1131) hang headless, so
hbc's compile error (t252) and clean runtime exit 1 (t250) are
registered failure modes for the same error conditions, not compat
successes. Harbour supports 3+ dimensions (oracle a3d prints
2/2/2); hbc rejects them at compile time (t251). t253 checks the
alloc/free balance across a function boundary under the instrumented
registry (exact sizes verified on this tested path). t255-t258 cover
the constructor edges against oracles: zero rows (az0a), zero columns
(az0b), dimension evaluation left to right and exactly once (aevord;
the helpers print f and g) and AAdd appending at len+1 on a nested
child (anadd). t259 exercises our allocation-overflow guard
(1e18 * 16 bytes overflows i64 in hbc_asize: clean "Out of memory",
exit 1); there is no headless oracle for it - Harbour would attempt
the allocation - so it is registered as our guard, not a compat
claim.

## Internal helper ABI (audited in iteration 18)

Internal helpers take arguments in rdi/rsi/rdx/rcx and return values in
rax/rdx on BOTH targets (kernel32 wrappers adapt inside hbc_alloc /
hbc_free / the print helpers). Every helper preserves the callee-saved
registers it uses (rbx, rbp, r12-r15); the audit found the Windows
hbc_free2 / hbc_aadd / hbc_asize clobbering them unsaved - the same
bug class that broke hbc_arraym on Wine only - and they were fixed to
save and restore what they use (locals moved to rbp-relative slots,
frames re-aligned to 16 at every call). Generated code never emits
callee-saved registers (verified by sweeping the emitter): live state
sits on stack frames and in volatile registers, so the preserved-ABI
rule is what keeps generated and hand-written callers
interchangeable. The ABI evidence is the code audit plus
tests/abi_harness.sh (wired into the battery): an asm canary test
that loads rbx/r12-r15 with sentinels, calls hbc_asize (grow, shrink,
deep shrink freeing a live child), hbc_aadd (including the re-grow),
hbc_arraym, hbc_free and hbc_free2, and after every call checks the
canaries, the stack balance and the 16-alignment at the call
boundary, on Linux and Wine. Negative control verified: removing one
pop from the Windows hbc_free2 makes the harness fail (the Wine run
crashes with rbp holding a canary value). t254 adds a Harbour-level
functional regression (live locals across helper calls); it does not
by itself prove register preservation, the harness does.

## Grown-casilla NIL repair (t191, t262-t266)

A casilla created by growing an array of arrays with ASize is NIL in
Harbour, not an empty subarray (oracles n1-n7). Repaired semantics:
the casilla is (null, 0) internally and prints NIL (n1); len / AAdd /
ASize on it map Harbour's headless-hanging dialogs BASE/1111, 1123
and 2023 (n2, n6, n7) to clean "Argument error: LEN / AADD / ASIZE"
exits (t263-t265, registered failure modes). Assignment into the
casilla installs a new child, converting i64 literals to Dyn-element
children (n3, t266). Real empty arrays (`{}`, empty children,
`Array(n, 0)` children) own a header-only block so they stay
distinguishable from NIL casillas (e4, az0b); the instrumented
registry verifies their allocation/free sizes on the tested paths.
Comparing a casilla against NIL was the last pending n-probe (n4);
it is repaired in iteration 20 (t267/t268, oracle n8): the DArr2
borrow-read path loads the child pointer and compares it against 0
under `=`, with the index evaluated once and bounds-checked. The
precise limitation before the repair was that borrow-read path only -
the NIL literal itself has existed in expressions since iteration 15
(t219: `g(1) = NIL` through Dyn). Empty-vs-NIL is covered by t269
(`Array(3, 0)` rows are real empty arrays, never NIL) and t270
(ASize shrink to 0: every child freed, registry balance 0).

## Mutable string arrays and owned-string parameters (t303/t304 repurposed, t307-t315, iteration 29)

Oracles hk7-hk9 (Harbour core libraries only, `-gtstd`): the array
from hb_HKeys is mutable (AAdd grows it, element overwrite works,
the source hash is unaffected - hk7); passed to a function it is
SHARED, the callee's mutation visible to the caller (hk8); a string
argument is usable by caller and callee alike (hk9). The last two
register the deliberate move-vs-share difference, not targets to
imitate: under the single-owner model the value MOVES.

- t307 (pos): hk7 mirror, byte-exact - AAdd, element overwrite,
  hash untouched.
- t308 (pos): `{}` grown with strings pins an array of strings;
  mutation and self-insert `AAdd(a, a[2])`; balance 0 (wrap).
- t309 (pos): string-array parameter move round-trip
  (`k := grow(k)`); the callee mutates and returns; balance 0.
  Contrast with hk8 (sharing) is registered in the test comment.
- t310 (neg): use of the array after it moved into the call.
- t311 (pos): owned string read from the keys array moves into a
  string parameter, is printed and returned; used as a hash key
  after; balance 0.
- t312 (pos): rodata argument (literal and literal-initialized
  local) to an owned string parameter: copied at the call boundary,
  freed by the callee; balance 0.
- t313 (neg): use of the owned string after it moved into the call.
- t314 (pos): mixed rodata/owned returns unify to owned; the
  literal return point copies; balance 0.
- t315 (neg): ASize on an array of strings.
- t303 (neg, repurposed): a string array no longer fits a parameter
  pinned to a flat integer array - a genuine type mismatch now.
- t304 (neg, repurposed): AAdd with a non-string element onto an
  array of strings.

Also fixed in the sweep: comparisons against owned strings fell
through to the numeric arm (pointer compare + leaked temporary);
they now byte-compare and free temporaries on both targets. No new
helpers, so the ABI harness needed no new entries; it still passes
on both targets.

## hb_HKeys (t298-t306, iteration 28)

Oracles hk4-hk6 (Harbour core libraries only, compiled with
`-gtstd`): hb_HKeys returns the keys in insertion order with their
original case; an overwrite keeps its position and updates the
value; keys differing only in case are two keys (confirms
h3b/t235); an empty hash returns a zero-length array. HGetKeys
(libxhb) is a different surface, not wired as an alias.

- t298 (pos): hk4 mirror plus hash writes, reassignment of the keys
  array and element re-reads; registry balance 0 (wrap pattern).
- t299 (pos): hk5 mirror - case-sensitive dedup and overwrite
  position.
- t300 (pos): hk6 mirror - empty hash, len 0.
- t301 (pos): a kept element `k := keys[1]` stays valid after the
  keys array is destroyed and reassigned, and compares equal to a
  fresh hash lookup - the key copies are owned, no use-after-free.
- t302/t305 (neg): use after move on the keys array and on a moved
  string element.
- t303 (neg): DArrS/StrOwn parameters rejected (same precedent as
  hash parameters).
- t304 (neg): AAdd on the keys array rejected (read-only array).
- t306 (pos): the keys array returned through a function transfers
  ownership; registry balance 0.

The three new shared helpers (hbc_hkeys, hbc_sfree, hbc_strcpy)
have dedicated entries in tests/abi_harness.sh: a real hash is
built, the keys are taken, copied and freed, with the canary
registers, stack balance and alignment checked after every call, on
both targets.

## Three-level parameters (t294-t297, iteration 27)

t294 mirrors oracle pr9 minus the caller reuse: the callee reads
len(p)/len(p[1])/p[1][1][2] and writes p[1][1][2], balance 0 after
the owner returns. t295 pins the use-after-move compile error.
t296 moves through a two-callee chain with balance 0. t297 pins
the print-move hole at two levels: `? consume(a)` now moves the
argument like any other statement.

## Class parser gate (t290-t293, iteration 26)

t290 pins the post-parse rejection of a full class program (the
runtime representation is pending). t291 pins the multiple
inheritance error, t292 the class-scope error, t293 the `==`
identity error. t01's pinned message moved from "':' without '='"
to "trailing tokens after expression": `::` is a real token now,
so the injection probe fails one stage later; it still fails.

## Array() with three dimensions (t285-t286, iteration 25)

t285 mirrors oracle pr7: Array(2, 2, 3) gives len 2/2/3, innermost
slots read NIL, a later third-level write works, registry balance 0
after the owner returns. t286 pins the compile error for a fourth
dimension. t287 mirrors pr7b: zero dimension in any position,
including the real empty child (len 0, not NIL) of Array(2, 0, 3).
t288 mirrors pr7d: the three dimension expressions evaluate once,
left to right. t289 is the pr7c failure mode: a negative interior
dimension with outer count 0 errors cleanly in hbc where Harbour
raises the BASE/1131 dialog (headless hang). pr7e registers the
overflow condition: Harbour's Array(100000, 100000, 100000) ends
killed by a signal (exit 137; exact cause unconfirmed without a
kernel/cgroup log). hbc's clean failure is verified cheaply:
hbc_asize's arithmetic guards (capacity cap, signed-multiply
overflow) route to hbc_oom, and under a 256 MB address-space cap
Array(40000, 40000, 40000) prints "Out of memory" and exits 1 in
under a second. hbc_array3m has its own ABI canary block. The old t251
negative ("3 dimensions unsupported") was retired because three
dimensions are supported now.

## AAdd/ASize at the third level (t281-t283, iteration 24)

t281 mirrors oracle pr8: AAdd(a[i][j], x) evaluates i, then j, then
the value; the innermost grow keeps every other length; ASize
shrink drops the tail and a later grow leaves fresh NIL slots;
registry balance 0 after the owner returns. t284 mirrors oracle
pr8b: ASize(a[i][j], n) evaluates i, then j, then the size. Both
orders match two-level AAdd/ASize (indices first); they were
measured for this increment, not inferred - the two-level WRITE
order (m7: value first) is a different operation, not a different
depth. t282/t283 pin the compile errors on a two-level value.

## Third-level writes and the return chain (t277-t280, iteration 23)

t277 mirrors oracle pr6 (write a[1][1][2] := 99, reads and lengths
unchanged elsewhere). t278/t279 pin the compile errors: three-level
write to a two-level value, and a fourth index level. t280 runs a
three-level value through a return chain (mk -> mid -> use) with a
read after each transfer: the returning function's epilogue skips
the moved value, only the final owner frees, registry balance 0 on
both targets.

## Three levels of nesting (t275-t276, iteration 22)

t275 mirrors oracle pr4 end to end: a {{{1, 2}}, {{3}}} literal,
len at each of the three levels, and a three-level read. t276
checks the ownership side on both targets: a three-level value
built and freed inside one function (epilogue recursive free), and
a three-level value returned by move into a caller whose epilogue
frees it - registry balance 0 in both cases. The old t200 negative
("depth 3 unsupported") was retired because depth 3 is supported.
The ABI harness gained an hbc_rfree block: a live DArr2 wrapped in
a pair block, freed recursively under canary and alignment checks.
Explicit compile errors remain for ASize/AAdd/ArrSet at level 3,
a fourth index level and mixed literals
(three-level parameters entered in iteration 27 under the move
contract).

## Nested arrays as parameters and returns (t271-t274, iteration 21)

t271/t272 mirror oracles pr1/pr3 (parameter and return of an array
of arrays under move semantics; the callee frees a consumed
parameter, the caller frees a returned value). t273 pins the
use-after-move compile error. t274 checks mutation of the owned
parameter inside the callee with registry balance 0. Registered
difference (probes pr2/pr5): Harbour shares the array reference
with the callee, so a callee write or AAdd is visible in the
caller; here the value moves and the caller cannot observe it
(the caller's variable is gone). That sharing belongs to the
standing ownership-contract decision, still pending.

## Hash parameters/returns and ASize on string arrays (t315 repurposed, t316-t323, iteration 30)

Oracles hk11-hk13 (Harbour core libraries only, `-gtstd`): a
hash passed to a function is SHARED - the callee's write is
visible to the caller without any return (hk11); a function
returns a hash it built (hk12); ASize on the array from
hb_HKeys shrinks keeping the first keys and grows with NIL
casillas (hk13).

Under the single-owner model the hash MOVES on call and return
(t316-t318): byte-identical printed values to hk11 via the
explicit move round-trip, the sharing itself stays the
registered difference family D5/D7, pending the user's contract
decision. Pinning: string-key evidence pins the hash, len()
merges into it (t322); a pin conflict (array of strings vs
hash) surfaces as the deterministic body error (t323).

ASize on an array of strings: shrink frees the removed copies
(t319, the shrink half of hk13), same-size is a no-op, shrink
to 0 frees the rest (t320); grow is a clean runtime error with
exit 1 (t321) - Harbour grows with NIL casillas (hk13), a
registered limitation of this increment. ASize on the hash
itself stays a named compile error (t315 repurposed).

322/322 on Linux x86-64 and Wine; ABI harness PASS on both
targets. No new helpers: hbc_asize gains kind 2 (string
elements) reusing the already-canaried hbc_free.

## ASize growth with NIL casillas on string arrays (t321 repurposed, t324-t327, iteration 31)

Oracles hk13-hk15 (Harbour core libraries only, `-gtstd`): ASize
grows the hb_HKeys array with NIL casillas (hk13), overwriting a
grown casilla with a string works (hk14), AAdd after growth
appends past the NIL casillas (hk15).

Mirrors: t324 is byte-identical to hk14 (grow, overwrite, grow,
shrink), t326 to hk15 (grow then AAdd). t325 prints NIL casillas
and string elements mixed. t327 grows, shrinks and checks the
balance is 0 (NIL casillas own nothing, live copies freed). The
string-context read of a NIL casilla is the registered clean
failure mode - Harbour yields NIL dynamically; the static owned
string cannot - exit 1 with a named message (t321 repurposed;
printing the same casilla prints NIL instead).

326/326 on Linux x86-64 and Wine; ABI harness PASS on both
targets. No new helpers.

## Whole array/hash printing and the line-end trim (t328-t332, iteration 32)

Oracles hk16, hk20-hk25 (Harbour core libraries only, `-gtstd`,
byte-compared with cat -A): a whole hash OR dynamic array prints
NOTHING (flat numeric, string-key array, nested array, empty hash
alike); the separator between items is still emitted (`? h, 5`
prints one space before the number; `? 5, h, 6` keeps both
separators); QOut space-trims the END of the line, for literals
and variables alike, while interior spacing is preserved exactly
(`? "ab  ", 5` keeps all 12 spaces); a string-array element in
last position is trimmed the same way (`? s[2], s[1]` prints
"cd ab"); printing a whole hash/array BORROWS it (len works
afterwards).

Mirrors: t328 (hk16/hk20/hk21 hash forms), t329 (hk20/hk22/hk24
array forms), t330 (hk22/hk24 line-end trim), t331 (hk23/hk25
borrow + element trim). t332 is the named compile error for a
constructing temporary in that position (registered limit; the
static suffix analysis never drops operand effects - only
side-effect-free variables render empty). Second registered
limit: a trailing ALL-SPACES string still leaves its preceding
separator in this PoC; exact fidelity there needs a buffered
line, so no general rtrim-fidelity claim is made.

Implementation: the checker admits whole array/hash printing for
variables only (borrow, no move); codegen drops the static
suffix of empty-rendering items with their preceding separators
and right-trims a surviving trailing string with an inline
backward scan (no new helper, so no new ABI canary entry).

## Iteration 33 additions (347 total)

t333 (flat numeric array: elements, len, alive after; hk17/hk26),
t334 (hash values in insertion order, NIL casilla; hk18/hk31),
t335 (empty array: zero iterations, variable restored; hk28/hk29),
t336 (hb_HKeys string elements, keys array alive; hk17),
t337 (grown NIL casillas iterate as NIL, `exit`; hk30/hk28),
t342 (early `return` from inside the body: borrowed slots never
freed, collection owned by the frame), t343 (Dyn+i64 arithmetic
on the loop variable). Rejected by name: t338 (missing EACH -
Harbour E0030), t339 (undeclared loop variable - BASE/1003),
t340 (assignment to the loop variable - Harbour write-through
hk32 not implemented), t341 (growing/modifying the borrowed
collection inside its loop), t344 (loop variable compared
against a string - hk33/hk34 measured, support pending), t345
(`hb_HKeys` with a non-variable argument - clean error, was a
compiler panic), t346-t348 (escaping the borrowed element:
return, copy to another local, store into a collection).

## Iteration 33b additions (352 manifest cases): loop variable vs string

t344 (hk33 mirror: real byte comparison `=`/`#`), t349 (hk37:
xBase prefix rule - right-operand length, left NUL-padded),
t350 (hk35: NIL casilla `=` .F., `#` .T.), t351/t352 (hk34/hk38:
numeric element vs string is Harbour's BASE/1071/1072 dialog,
headless-hanging - clean "Argument error: ="/"Argument error:
<>" exit 1, registered failure modes), t354 (string on the LEFT
and an owned temporary k[1] as the string side, freed after the
comparison). t223 repurposed: its third case assumed the old
always-.T. fold for a NUMBER casilla vs string, which
hk34/hk38 disproved; it now uses a NIL casilla (hk35) and keeps
its evaluation-effects purpose. Runtime dispatch on the Dyn tag
(2: hbc_str_eq, 1: fold, 0: named error).

## Iteration 33c additions (359 manifest cases): ordering vs string

t355-t357 (hk36/hk39/hk40/hk43: ordering a string casilla
byte-wise over the right operand's length - "abcd" vs "abc"
compares EQUAL, "ab" < "abc" by NUL padding), t361 (hk51: Dyn
as the RIGHT operand, same rule), t360 (several comparisons
together and nested - pins the unique-label scheme), t358/t359
(hk42/hk47: ordering a numeric or NIL casilla against a string
is Harbour's BASE/1073-1076 dialog, headless-hanging - clean
"Argument error: <"/"Argument error: >" exit 1, registered
failure modes), t362 (hk48: left shorter than right under `=`
is .F.). hbc_str_cmp (b22) reused as-is; new noreturn stubs
hbc_dyncmp_lt/gt/le/ge_error (no ABI canary entries - they
exit). t353 (the old compile-time rejection of ordering)
removed. Inline branch labels in emitted code now come from
LBL_ID, a per-emission unique counter - fixed numeric labels
caused two silent miscompares.

## Iteration 33d additions (364 manifest cases): FOR EACH over temporaries

t363 (hk52 mirror: a call result - user function returning a
DArrS, or hb_HKeys(h) - iterated directly; owned by the loop,
balance 0), t364 (statement re-entry inside a `while`: the
previous temporary is freed before the new call, epilogue frees
the last, balance 0), t365 (hk55/hk56 mirrors: `exit` and
`return` inside the loop - the epilogue frees the temporary on
both paths, balance 0), t366 (Array(2) temporary: the created
NIL casillas iterate as NIL), t367 (nested collection a[i]
still a named compile error - the pre-existing "cannot extract
the subarray" rejection; hk53/hk57 measured, support pending;
hk58/hk59: iterating a NIL or numeric casilla is Harbour's
BASE/1068 dialog, headless-hanging - future registered failure
mode). Design: a temporary collection gets a slot registered in
darr_slots (layout_locals) - prologue zeroes it, the ForEach
entry frees it if non-null (re-entry), the epilogue frees it on
every path. No new helpers; harness unchanged.

## Iteration 33e additions (370 manifest cases): FOR EACH over a[i]

t367 (hk53 mirror: `for each x in a[1]` / `a[2]` on an array of
arrays iterate the subarray's elements; the root survives and
keeps its length and cells afterwards - t367 replaces the old
"cannot extract the subarray" rejection, disproved by these
oracles), t368 (the collection index expression evaluates
ONCE: `a[ni()]` prints "eval" a single time), t369 (hk58
mirror: iterating a NIL casilla exits 1 with "Argument error:
array access" - Harbour's BASE/1068 dialog hangs headless, so
this is a registered failure mode, not an oracle-matched
equivalence), t370-t372 (named compile errors: ASize(a, 3),
AAdd(a[1], 9) and a[1][1] := 9 inside the loop - the root and
the borrowed child cannot be modified, grown or moved inside
their own loop; indirect moves through the body environment
were already rejected by the 33a guards), t373 (`exit` and
`return` inside a loop over a borrowed subarray: the loop owns
nothing, so there is no per-statement freeing; the epilogue
frees the root as usual, balance 0). Design: the codegen
evaluates the index expression once (Dyn converted via
hbc_dyn_to_i64), bounds-checks it against the parent's length
(hbc_bound_error), loads the child {ptr, len} cell, and jumps
to the new noreturn stub hbc_arracc_error when the child
pointer is null (NIL casilla). No ABI harness entries: the
only new runtime helper is noreturn.

## Iteration 33f additions (376 manifest cases): FOR EACH over a[i][j]

t374 (hk60/hk61 mirror: `for each x in a[1][1]` / `a[2][1]` on a
three-level array iterate the innermost child; the root survives
with its length and cells), t375 (hk64 mirror: both collection
index expressions evaluate ONCE - "eval" prints exactly twice for
a[ni()][ni()]), t376-t378 (named compile errors inside the loop:
AAdd(a[1][1], 9) grows the borrowed innermost child, a[1][1][1]
:= 9 writes through the root, and passing the root to a function
moves it - all rejected because the loop borrows the collection),
t379 (hk62 mirror: `exit` and `return` inside the depth-3 loop -
the loop owns nothing, the epilogue frees the root as usual,
balance 0). Design: the codegen evaluates the first index once,
bounds-checks it against the root length, loads the level-2 cell
(null child -> hbc_arracc_error), preserves it on the stack while
evaluating the second index once, bounds-checks against the
level-2 length and loads the innermost {ptr, len} cell. The
depth-3 hbc_arracc_error path is defensive only: a NIL middle
casilla cannot be built in this PoC (middle-level growth of a
DArr3 is unsupported), so no execution test claims it; hk63
measured Harbour's BASE/1068 dialog there (headless-hanging,
registered failure mode). No new runtime helpers and no ABI
harness entries.

## Iteration 33g additions (383 manifest cases): ASize on three levels

t380 (hk68 mirror: ASize grows a three-level ROOT with NIL casillas;
shrinking back frees the removed children - balance 0), t381 (hk63
mirror, now reachable: iterating a grown NIL root casilla at depth 3
exits 1 with the BASE/1068 text), t382 (hk65 mirror: ASize grows the
MIDDLE a[i] with NIL casillas; existing children survive), t383
(iterating a grown NIL middle casilla exits 1 with the BASE/1068
text), t384 (middle shrink frees removed innermost children - balance
0), t385 (root shrink to zero frees everything - balance 0), t386
(ASize on a NIL casilla is the registered BASE/2023-family failure
mode, n7: clean exit 1). Design: hbc_asize gains kind 3 - grow
zero-fills like kind 1, shrink frees removed children RECURSIVELY via
hbc_rfree depth 2 (kind 1 only does a flat free, which would leak
grandchildren). No new helpers; the existing hbc_asize ABI canaries
stand, and the new kind is exercised by t380/t384/t385 on both
targets. Middle AAdd with array elements (hk66/hk67) is measured and
registered as pending: static literals are not materialized as dynamic
children in this increment. Test-shape note: hb_memcheck must be
printed by the CALLER after the owner function returns - printing it
inside the owner always counts the still-owned arrays.

## Iteration 33h additions: AAdd on the middle a[i]

t387 (hk66 mirror: AAdd(a[1], {5,6}) materializes the static literal
as a dynamic child - header plus tagged cells, the same shape as a
nested-literal child; balance 0), t388 (hk67 mirror: the index
evaluates FIRST, the value after - "eval" then "val"; mirrored with
Array(2), dynamic), t389 (hk69 mirror: a dynamic call result moves
in), t390 (hk70 shape under the MOVE contract: a variable element
moves in and the source is nulled - Harbour SHARES it (b[1]:=99 reads
back through a[1][2][1]), a registered D5/D7 difference pending the
user's contract decision; this does NOT implement sharing), t391
(reusing the moved source is the clean "use of moved value" error),
t392 (a nested literal element - a fourth level - is a named compile
error), t393 (AAdd on a NIL middle casilla is the registered
BASE/1123-family failure mode, n6: "Argument error: AADD" exit 1).
Codegen note: the middle casilla address feeds hbc_aadd directly (it
is a {ptr, len} pair); the new element arm shares the existing
bounds-walk and append tail with the scalar path (a first draft
duplicated the tail with an early return that dropped the following
statements - caught by the battery, fixed before publishing).

## Iteration 33o additions (440 manifest cases): hashes as arguments and returns

Hashes follow the established MOVE contract on arguments and returns
(oracle hk11, compiled hbmk2 -gtstd: Harbour SHARES the hash - the
callee's added key is visible in the caller - so the move is a
registered D5/D7-family difference pending the user's contract
decision, NOT sharing). Tests: t439 (callee reads and extends the
moved hash, balance 0), t440 (hash return moves to the caller,
balance 0). Named compile errors: t441 (caller reuse after the
move), t442 (a hash LITERAL argument - no emission path in argument
position; the named rejection replaces a compiler unreachable found
while probing this increment), t443 (a read-only callee pins a flat
dynamic array - len evidence is array/hash-ambiguous, same
registered pin pattern). No new helpers, no new ABI harness entries.

## Iteration 33n additions (435 manifest cases): string arrays as arguments and returns

DArrS (arrays of strings) follow the established MOVE contract on
arguments and returns - no code change was needed: the call-site
check, the boundary push with source nulling, and the epilogue free
(kind 2, owned strings) already covered the type; this iteration
measures and registers it (oracles hk101, compiled hbmk2 -gtstd:
Harbour SHARES the string array - the callee's write and growth are
visible in the caller - so the move is a registered D5/D7-family
difference pending the user's contract decision, NOT sharing; the
callee's reads of string casillas match hk101 exactly). Tests: t435
(callee reads, writes and grows the moved array, balance 0), t437
(DArrS return moves to the caller, balance 0). Named compile errors:
t436 (caller reuse after the move - "use of moved value"), t438 (a
read-only callee pins a FLAT dynamic array, so the string array is
rejected by name - same registered pin pattern as ASize-only: string
evidence like AAdd(x, "s") or a string operation on x[i] pins DArrS).
No new helpers, no new ABI harness entries.

## Iteration 33m additions (431 manifest cases): static array returns

return a on a STATIC array materializes a dynamic COPY the caller owns
and frees (33m; oracle hk99, compiled hbmk2 -gtstd: Harbour's local
array survives the return and the caller reads, writes and grows it -
a fresh owner matches that observably for the measured non-aliasing
shape; no sharing involved). Tests: t430 (reads, balance 0), t431
(write + growth on the returned copy), t432 (shrink, balance 0).
Named compile errors: t433 (a literal return - only variables this
increment), t434 (len of an array TEMPORARY in expression position -
no free point here; the guard also closes a pre-existing compiler
unreachable reachable via dynamic returns; t399/t421 keep testing the
borrow escape through an assigned result). No new helpers, no new
ABI harness entries.

## Iteration 33l additions (426 manifest cases): static arrays as arguments

f(a) on a STATIC root array is allowed: the call boundary materializes
a COPY as a flat dynamic array (header + tagged cells) that the callee
owns and frees - the same t312 strings pattern, one level up. Oracle
hk98 (compiled hbmk2 -gtstd): Harbour SHARES the array (callee writes
x[1] := 99 and growth AAdd(x, 7) are visible in the caller), so the
copy is a registered D5/D7-family difference pending the user's
contract decision, NOT sharing: the callee reads, writes, grows and
shrinks its own copy and the caller's static array keeps its values
(t425-t427 show both sides). Tests: t424 (reads through the copy,
caller intact, balance 0), t425 (write on the copy invisible in the
caller - Harbour would show it), t426 (growth on the copy, caller
length unchanged), t427 (shrink on the copy, balance 0). Named
compile errors: t428 (static argument into a deeper-pinned
parameter), t429 (a literal argument - only variables this
increment). The old t136 rejection keeps its shape (static array
into an integer-pinned parameter) with the updated named message.
No new helpers, no new ABI harness entries.

## Iteration 33k additions (420 manifest cases): borrowed middles at THREE levels

f(a[i]) on a three-level array passes the middle cell's ADDRESS; the
callee borrows it exclusively (oracles hk93-hk96, compiled hbmk2
-gtstd: reads len(x)/len(x[1])/x[1][1], growth AAdd(x, {9,8}),
element write x[1][2] := 42, shrink ASize(x, 1) - every mutation
reads back in the caller exactly like Harbour's sharing, while
single ownership stays intact: the borrow ends at the return and
escapes are compile errors; NOT Harbour sharing - registered D5/D7
family pending the user's contract decision). The borrowed
parameter pins to DArr2 (its cells are child arrays) and gets the
new codegen-only Ty::DArrRef2: one address word; bounds, base,
reads, writes, AAdd (with static-literal materialization, same
shape as the middle arm) and ASize (kind 3, recursive free) all
load through the owner's cell. The caller walk and the NIL-casilla
failure mode (clean exit 1 "Argument error: PARAM", hbc_param_error
- no new helpers, no new ABI harness entries) are shared with the
two-level borrow. Tests: t416 (hk93 mirror: reads, balance 0), t417
(hk94 mirror: grow visible, materialized literal child, balance 0),
t418 (hk95 mirror: two-level write visible), t419 (hk96 mirror:
shrink visible, recursive free, balance 0), t420 (the index
expression evaluates exactly ONCE - "eval" prints once), t423 (NIL
casilla -> "Argument error: PARAM" exit 1, registered failure
mode). Named compile errors: t421 (returning the borrowed
parameter), t422 (two borrows of the same root in one call). The
pin rules learned one shape: AAdd(p, {1,2}) with a literal array
element pins the parameter one level deeper. Registered pin
limitation: ASize as the ONLY evidence pins a flat array (the deep
shape is ambiguous), so a shrink-only callee needs extra DArr2
evidence (e.g. len(x[1])) - without it the call is a named
rejection, never an inference. Reading a[i] of the borrowed middle
BY VALUE stays a named compile error (child extraction).

## Iteration 33j additions (412 manifest cases): ValType

`ValType(x)` returns the one-character type tag (oracles hk88-hk92,
compiled hbmk2 -gtstd, native Linux): arrays at the supported depths
"A", numbers "N", strings "C", NIL "U" (hk88). Static types classify
at compile time; a Dyn casilla classifies at runtime: a scalar
casilla {tag, payload} reads tag 0/1/2 as "N"/"U"/"C" (hk92:
AAdd'ed string and integer casillas, ASize-grown NIL casillas), a
child-array casilla {ptr, len} reads ptr null/non-null as "U"/"A"
(hk90/hk91, Array(2) and Array(2,2)). The argument evaluates fully
with its effects before the walk (hk89: the index's "eval" prints,
then the tag) and is BORROWED - nothing moves. Works through a
borrowed middle-array parameter: ValType(p) is "A" and ValType(p[1])
reads the owner's casilla through the cell address. Named compile
errors, all unmeasured rather than inferred: ValType over a[i] of a
THREE-level array (t413), over a user call result (t414), over a
hash (t415). A NIL middle in a[i][j] cannot be walked: Harbour's
dialog hangs headless, so it is the registered clean bound-error
failure mode, not a compat success. No new runtime helpers - the
classification is inline over rodata letters and the bound error is
the existing canaried stub - so the ABI harness needed no new
entries. Tests: t409 (hk88 mirror: static shapes plus a Dyn variable
as NIL and as integer), t410 (hk89 mirror: effects order,
byte-compared), t411 (hk92 shapes split by element type, balance 0),
t412 (borrowed parameter, balance 0), t413-t415 (named rejections).
Note: our dialect pins dynamic-array element types, so hk92's MIXED
string+integer array runs here as one array per element type - the
already-pinned AAdd pin limitation, not a ValType difference.

## Iteration 33i additions (405 manifest cases): middle arrays as BORROWED arguments

f(a[i]) on an array of arrays passes the child cell's ADDRESS; the
callee borrows it exclusively for the call (oracles hk73 reads, hk78
growth, hk86 element write, hk87 shrink - Harbour SHARES and every
mutation reads back in the caller; the exclusive borrow reproduces
exactly that observable behavior while single ownership stays intact:
the borrow ends at the return and escapes are compile errors). NOT
Harbour sharing - no alias survives the call (registered D5/D7 family,
pending the user's contract decision). t407/t408 (an argument that moves the root AFTER or BEFORE the borrow is set up - f(a[i], g(a)) and f(g(a), a[i]) - is a named compile error: any argument that can reach the root mentions it, and mentions are rejected). Tests: t394 (hk73 mirror: len
and element reads through the borrow, balance 0), t395 (hk78 mirror:
AAdd in the callee grows the caller's child), t396 (the index
expression evaluates exactly ONCE, before the walk - "eval" prints
once), t397 (hk86 mirror: x[i] := v visible in the caller), t398
(hk87 mirror: ASize in the callee shrinks the caller's child), t402
(a NIL casilla as the borrowed argument: clean exit 1 "Argument
error: PARAM" - registered failure mode of the BASE/1123 family;
Harbour's dialog hangs headless, no oracle). Named compile errors:
t399 (returning the borrowed parameter), t400 (passing it on to
another function), t401 (another argument of the same call mentions
the same root - aliasing), t403 (a[i] of a THREE-level array still
cannot be extracted), t404 (a borrow-pass of the loop's root inside
FOR EACH - the element view could dangle), t405 (a parameter that
borrows elsewhere cannot also receive an owned array, and vice
versa), t406 (reassigning the borrowed parameter). Checker: Sig
carries per-parameter borrowed/arr_moved flags (exclusive modes);
the callee body checks under the owned shape and an escape post-pass
rejects the rest by whitelist. Codegen: the caller pushes the cell
address (bounds walk shared with AAddSub; index first, effects
included); the callee stores it in one slot word (Ty::DArrRef) and
every operation loads through it - hbc_aadd/hbc_asize receive the
cell address exactly like the middle arms, so growth/shrink/writes
land in the owner's cell. No new helpers except hbc_param_error
(noreturn failure-mode stub - no ABI harness entries needed); the
epilogue never frees a borrowed parameter. Parent-requested edge
(21:12): an index expression that MOVES the root (f(a[g(a)])) is
safe by evaluation order - the walk reads the nulled slots and exits
with the clean bound error (verified live: "Bound error: array
access", exit 1).

## Iteration 33p additions (444 manifest cases): codeblocks as user-function parameters

hk102 (Harbour oracle, hbmk2 -gtstd, exit 0): a function taking a
codeblock parameter and calling `eval(b, x)` twice prints 42 and
returns 44. The pin pass now pins the first argument of `eval` to
`Block(args.len()-1)` and its extra arguments to I64 (matching the
existing checker contract). Bug found and fixed during the
increment: when `eval` was the ONLY evidence and sat in a `return`
or an assignment, the parameter's other arguments went unpinned,
the pin pass errored silently and the placeholder env surfaced the
misleading "eval expects a codeblock" body error instead. Tests:
t444 (hk102 shape - 42/44, caller's block variable reused after
the call: Copy semantics, prints 10, balance 0), t445 (two
codeblock parameters), t446 (a block of arity 2 fed to a Block(1)
parameter is a named compile rejection - conservative exact-arity
pin vs Harbour ignoring extra arguments, probes c7/c7b), t447 (a block fed to an integer parameter:
"must be an integer, got a codeblock"). No new runtime helpers.

## Iteration 33q additions (444 manifest cases): codeblock-arity diagnostic

Parent-reported defect on t446: two codeblocks of different arity
used to read "must be a codeblock, got a codeblock". The call-site
rejection now names both arities ("must be a codeblock of 1
argument(s), got a codeblock of 2 argument(s)"). No semantic
change; manifest substring updated. Battery re-run: 444/444 +
ABI harness green on Linux and Wine.

## Iteration 33r additions (449 manifest cases): Array() fourth level

hk103 (exit 0): Array(2,2,2,2) - len 2 at each of the four levels,
NIL innermost casillas, write/read at the fourth level,
valtype(a[1,2,1]) = "A", valtype(a[1,2,1,1]) = "U". hk104: a
four-level write evaluates the VALUE first, then the indices left
to right (V, I1-I4). hk106: a four-level read evaluates indices
left to right. hk107: the bracket form a[1][2][1][2] works the
same. Tests: t448 (hk103 shape + balance 0), t449 (write order),
t450 (read order), t451 (a fifth index is a named parse
rejection), t452 (AAdd on the third level: clean rejection -
"trailing tokens after expression"; hk105 measured AAdd/ASize at
that level, scheduled for the next increment), t286 repurposed
(five dimensions are the named rejection now that four compile).
t279's old parse rejection is now the checker's named "four-level
assignment needs an array of arrays of arrays of arrays". New
runtime helper hbc_array4m (canaried in the ABI harness with an
rfree depth-3 cycle); DArr4 slots free via hbc_rfree at depth 3,
balance 0. No impossibility claims: four levels compile, five are
the named edge of this increment.

## Iteration 33s additions (453 manifest cases): AAdd/ASize at the third level of a four-level array

hk105 (exit 0): on Array(2,2,2,2), AAdd(a[1, 2, 1], 8) takes
len(a[1,2,1]) from 2 to 3 with a[1,2,1,3] reading 8; ASize(a[1,
2, 1], 1) shrinks to 1 and preserves a[1,2,1,1] = 7 (comma head
form measured). hk108: AAdd on that shape evaluates the three
indices left to right, THEN the value (I1, I2, I3, V) - the same
indices-before-value order measured for the one- and two-level
forms (pr8), measured here, not inferred. Tests: t454 (hk105
shape + balance 0), t455 (hk108 order), t456 (bracket head form
a[1][2][1]), t457 (a three-level root is the named compile
error). t452 repurposed: its old comma-head parse rejection is
now accepted, so it pins the new named edge - AAdd with four
index levels is "on more than three index levels is not in this
increment". Parser fix in passing: the AAdd/ASize statement head
split took the first comma WITHOUT bracket-depth tracking, so the
comma head form `AAdd(a[1, 2, 1], 8)` mis-split inside the index
group ("trailing tokens after expression"); the split now scans
for the first depth-0 comma. No new runtime helpers: the generic
hbc_aadd/hbc_asize operate on the walked level-4 slot, so the ABI
harness needs no new entries; execution coverage is via t454-t456
on both targets. Battery: 453/453 manifest cases + ABI harness
green on Linux x86-64 and Wine.

## Iteration 33t additions (459 manifest cases): FOR EACH over a level-3 collection of a four-level array

hk109 (exit 0): on Array(2,2,2,2), `for each x in a[1, 2, 1]`
(comma head) iterates the level-4 elements (7, 8), the borrowed
child keeps its length (2), the root keeps its length (2) and
a[1,2,1,1] still reads 7 after the loop. hk110 (exit 0): the
three index expressions evaluate ONCE, left to right (I1, I2,
I3), before the first element - the same eval-once discipline
measured at the shallower depths (hk53/hk60), measured here, not
inferred. Tests: t458 (hk109 shape + balance 0), t459 (hk110
order), t460 (bracket head form), t461 (a three-level root is the
accurate named rejection - the form gate now lets an Index3
collection fall through to the generic typing so the error names
the real problem, fixing a misleading-diagnostic defect of the
t446 class), t462 (mutating the root inside the body is the
named borrow rejection), t463 posx (an out-of-range index is the
registered bound failure mode, exit 1). Registered fact: a NIL
middle casilla cannot occur in this increment's DArr4 (no
operation nulls one), so the arracc walk path at levels 1-3 is
compiled but has no reachable test here. No new runtime helpers,
no ABI harness additions; the walk reuses hbc_bound_error /
hbc_arracc_error (noreturn stubs). Battery: 459/459 manifest
cases + ABI harness green on Linux x86-64 and Wine.

## Iteration 33u additions (466 manifest cases): four-level parameters and returns by move

hk111 (exit 0): Harbour SHARES a four-level array on a call - the
callee's write to a[1,2,1,1] is visible in the caller (42, 42).
Registered D5/D7-family difference: here the value MOVES
(pending the user's contract decision; same family as
pr2/pr5/hk101). hk112 (exit 0): a returned DArr4 keeps len at
every level, the written value and the NIL casillas. hk113
(exit 0): `? a` on a four-level array renders empty (QOut rule,
same as hk20 at shallower depths). Tests: t464 (callee view of
the moved array: len at each level, level-4 write, balance 0),
t465 (hk112 shape), t466 (caller reuse after the move is the
named compile error), t467 (two-callee move chain, balance 0),
t468 (hk113 shape), t469 (callee reuse after passing the
parameter on is the named compile error), t470 (reassignment
frees the old value after the RHS exists, balance 0).

BUGS FIXED (33r left the DArr4 move machinery incomplete; none
of these paths had execution tests): the return-path source-slot
nulling missed DArr4 (a returned four-level array was freed by
the callee epilogue and the caller held a dangling pointer -
t465 SEGFAULTED before the fix); the local-assignment and
call-argument nulling lists, the callee-side argument copy-in
(a DArr4 parameter arrived with length 0), the caller-side move
marking (reuse after the move was not rejected), the
reassignment routing (a DArr4 RHS fell out of the free-old
arm), the pin-resolution merges with DArr4, and the len() pin
for len(p[i][j][k]) all missed DArr4 as well. The pin-failure
fallback (i64 placeholders) also turned the real conflict into
a misleading "`len` expects an array" - the merges now resolve
it. No new runtime helpers; no ABI harness additions. Battery:
466/466 manifest cases + ABI harness green on Linux x86-64 and
Wine.

## Iteration 33v additions (472 manifest cases): ownership audit + diagnostic fixes

Parent-directed audit of ownership transitions across all supported
collection types, grounded in execution probes (sondas
auditoria33v/, az1-az3, ax1-ax7, ay1-ay2): no soundness hole found
outside the DArr4 routes fixed at 33u. Reassignment-from-call frees
the old value for DArr3/DArrS/Hash/DArr4 (memcheck counts exactly the
live array: 15 blocks for a live DArr4, 30 would mean a leak); the
print-move hole is a named compile error for Hash and DArrS;
self-assignment works on DArr2.

Three diagnostic defects found by the audit and fixed: the four-level
root (and its a[i]) in AAdd / ASize / indexed assignment now produce a
named limit message instead of the misleading "`a` is not an array"
family (au1-au4 -> t473-t476), and the comma form of a two-index
AAdd/ASize head a[i, j] no longer dies with "trailing tokens after
expression" (au5/au6): the parse guard written for the bracket form
(head.len() >= 7) excluded the 6-token comma head; lowered to >= 6 it
routes into the existing single-group comma split. Oracle hk115
(hbmk2 -gtstd, exit 0) measures Harbour: AAdd(a[1, 2], 9) grows the
subarray to len 3 with the 9 in place; ASize(a[1, 2], 1) shrinks it
leaving NIL. t471 mirrors hk115 with balance 0; t472 pins the named
rejection of the comma form on a two-level root.

472/472 manifest cases + ABI harness green on Linux x86-64 and Wine
(Wine is not real Windows).

## Iteration 33w additions (475 manifest cases): static-array variables as whole-array values

Ownership coverage probes (w1-w7) found a REAL compiler panic class:
the checker accepted a static array held in a VARIABLE as a whole-array
value (a[1] := b on a two-level root, AAdd(a, b) on a two-level root,
AAdd(a[1], b) on a three-level root) but codegen only handled the
literal path and hit unreachable (three sites, rc=101). Fixed: the
static variable's cells are COPIED into a fresh dynamic child; the
source keeps its values (copy contract of 33l/33m; Harbour SHARES -
hk116: b[2]:=77 becomes visible through a[1][2] - registered D5/D7
difference, NOT sharing here). t477 (a[1] := b, post-write divergence
pinned: a[1][2]:=99 leaves b[2]=2), t478 (root AAdd), t479 (middle
AAdd): all balance 0. Also probed clean: DArrS element overwrite frees
the old string (w1), DArrS AAdd+ASize shrink frees (w2), same-size
static reassign (w3b), StrOwn reassign-from-call (w5b).

475/475 manifest cases + ABI harness green on Linux x86-64 and Wine
(Wine is not real Windows).

## Iteration 33x additions (476 manifest cases): ValType on four-level casillas

ValType(a[i]) and ValType(a[i][j]) on a DArr4 root now classify the
child-array casilla {ptr, len} - "A" when live (hk114). Pinning detail:
the first hk114 read looked like an empty first line; the hk117 marker
probe (">" / "<" guards) showed Harbour's ? is newline-LEADING, so
hk114 is A/A/A/U/N, and t480 is byte-identical to the oracle binary.
A NIL middle is the registered clean bound-error failure mode.

476/476 manifest cases + ABI harness green on Linux x86-64 and Wine
(Wine is not real Windows).

## Iteration 33y additions (481 manifest cases): FOR EACH over a[i][j] of a four-level root

hk118 measures the elements classify "A" and reads go through the
shared casilla; hk119 measures x[j] := v writes THROUGH (visible in
the caller, only the iterated middle affected). Implementation: the
loop variable is a borrowed flat child array - typed DArr in the
checker, DArrRef layout in codegen (slot = current casilla address,
the param-borrow machinery). t481/t482 byte-identical to the oracle
binaries (entry adaptation: `local x := 0`, bare `local x` is not in
the subset). Named rejections: reseat (t483), grow (t484); restore
after natural completion and `exit` (t485).

t486 (iteration 33z): nested FOR EACH over two middles of the same
four-level root (oracle hk120) - the inner loop over a[1,1] and the
outer over a[1,2] write through independently; a[2,1,1,1] stays NIL.
Byte-identical to the hk120 oracle binary (same local-initialisation
adaptation).

t487 (iteration 34): the middle borrow aliases the root's
casillas (oracle hk121) - x[1] := 8 through the loop variable is
visible reading a[1,2,1,1] directly mid-loop, persists, and the
untouched branch stays NIL. Byte-identical to the hk121 binary.

t488/t489 (iteration 35): `exit` inside the inner of two nested
middle loops (oracle hk122) - only the first inner element is
written, the outer loop completes both iterations; and a second
FOR EACH over the same middle re-borrows it after the first loop
ends and sees the writes (oracle hk123). Both byte-identical.

## Iteration 36 additions (488 manifest cases): `==` measured scope

hk124 measures integer `==` (1==1 .T., 1==2 .F. - same as `=`);
hk125 shows array `==` answers identity (.T./.F.) before `=` on
arrays raises Harbour's runtime error dialog (hangs headless - no
oracle, `=` on arrays stays a named rejection); hk126 pins one-level
dynamic array identity: a==a .T., a==b .F. even with equal contents
(the frame slot's heap pointer is the identity). t490 (integer),
t491 (DArr identity), t293 repurposed from the old blanket rejection
to the measured positive, t492 (neg) keeps static arrays rejected:
Harbour compares references, ours are frame copies (D5/D7), an
element compare would lie. Strings/deeper arrays/codeblocks/NIL
`==` keep named rejections; object identity (cl7/cl19) class-gated.
No new runtime helpers; no ABI harness change.

t493 (iteration 37): string `==` is the EXACT comparison (oracle
hk124: "a"=="a" .T., "a"=="a " .F., "a "=="a" .F. - unlike the
right-length prefix rule of `=`). New leaf helper hbc_str_xeq
(lengths must match AND every byte; same register contract as
hbc_str_eq), canaried in the ABI harness (equal pair answers 1,
shorter right operand 0). t492's expected rejection text updated
for the widened measured-scope message.

t494/t495 (iteration 38): `==` against NIL reuses the `=` codegen
paths because identity and equality coincide where NIL is one side
(oracle hk128: NIL==NIL .T., NIL==1 / 1==NIL / NIL=="" all .F.;
hk129: dynamic casilla == NIL answers like `=` - live child .F.,
NIL casilla .T., .F. after a write). No new leaf helper: the
constant folds and the hbc_dyn_eq tag dispatch already answer these
shapes; the execution cases run on both targets.

t496/t498/t499 (iterations 39/39b): `==` identity extended to
nested dynamic array variables (oracle hk130 for depth 2, hk135
for depths 3 and 4: a==a .T., a==b .F. - same slot-pointer compare
as the one-level case; the first qword of the frame slot is the
heap pointer at every implemented depth). hk130's third shape
(a==c after c:=a) is unreachable by design - assignment MOVES
(difference family D5/D7) - so t496 covers only the same-variable
and distinct-variable shapes; the oracle label must not be read as
the alias case passing.

t497 (iteration 39, retracted at 39b): `==` on same-arity codeblock
variables was admitted on hk131 (x==x .T., x==y .F. for distinct
literals) and RETRACTED when hk136/hk137 showed Harbour's block
identity is per EVALUATION (make()==make() .F.; the same literal
assigned in two loop iterations is .F.) while our slot holds a
per-literal STATIC pointer that would answer .T. there. Those
shapes are unreachable in today's dialect (blocks cannot be
returned, Dyn cannot be reassigned to Block), but admitting the
operator would bake in a model known to diverge. t497 is now a
negative case carrying the named rejection; no helper changed.

t500-t504 (iteration 40): `==` on dynamic casillas dispatches on the
runtime tag. String x string is the exact byte compare (oracle hk141:
hkeys FOR EACH variable against literals, symmetric .T./.T./.F./.F.;
hk143: two casillas compare content, not identity, .T./.F./.F./.T.),
number x number the value compare (hk138: .T./.F./.T./.T.), NIL x NIL
.T. and NIL x payload .F. (hk140: .T./.F./.F.). Mixed number x string
is Harbour's BASE/1070 "Argument error: ==" (hk139/hk139b/hk139c/
hk142: dialogs that hang headless, no oracle) - clean named exit 1,
registered failure mode (t504 posx, both targets). New leaf helper
hbc_dynxeq_dd canaried in the ABI harness (NIL/NIL 1, NIL/number 0,
number/number 1 and 0, string/string 1 and 0) plus the noreturn
hbc_dynxeq_error stub. hk132/hk133 measured indexed-assignment string
cells, which this PoC does not implement (elements stay tagged int/
NIL scalars by indexed assignment) - corpus-only, future material.

t505/t506 (iteration 41): hash VARIABLES answer `==` identity (oracle
hk134: h==h .T., h==k .F. even with equal contents - the frame slot's
first qword is the heap pointer, same model as the arrays; t505), and
the BASE/1070 failure mode now covers both operand orders (hk142:
casilla == int; hk144: int == casilla - both hang headless, no
oracle; t504/t506 posx, both targets).

t507 (iteration 42): the third measured mixed order - a NUMERIC
casilla against a string literal (hk139b: BASE/1070 dialog, hangs
headless, no oracle) - as a posx case on both targets, completing
execution coverage of the hbc_dynxeq_dd mixed-tag error branches
(t504: hk142; t506: hk144; t507: hk139b).

t508/t509 (iteration 43): the hk132/hk133 answers reproduced on the
expressible string-array surface. Harbour's probes build the cells
with Array(2) and indexed assignment - syntax this PoC rejects by
name (dynamic-array elements stay tagged int/NIL scalars) - while
the dedicated DArrS surface ({} + AAdd, indexed overwrite freeing
the old copy) answers the measured shapes exactly: hk132 as 1/0/0/1
(t508: exact, symmetric, no prefix rule), hk133 as 1/0/1 (t509:
content compare between cells, not identity). Mixed-type arrays
stay a named rejection. No compiler change - the Str x Str path
already shipped at iteration 37; these tests close the hk132/hk133
story with execution on both targets.

t510-t512 (iteration 44): `=`/`#` between two Dyn casillas - string x
string by content with the prefix rule (hk145, fixes an always-.T.
tag-only bug in hbc_dyn_eq), string x integer a clean named exit 1
mirroring BASE/1071 (hk146 - dialog hangs headless; registered failure
mode), string x NIL .F. in both directions (hk147).

t513-t517 (iteration 45): ordering between two Dyn casillas - new leaf
helper hbc_dynxcmp (ABI-canaried on both targets): string x string
byte-wise over the right operand's length (hk148; t513), string x
integer a per-operator clean named exit 1 mirroring BASE/1073-1076
(hk149-hk152 - dialogs hang headless; registered failure modes;
t514-t517).

t580-t583 (iteration 59): hb_HDelAt(h, n) over the new frame-based
shared helper hbc_hdelat - the entry AT a 1-based insertion-order
position removed, positions compacted, order preserved and the only
entry emptying the hash (t580; hk187/hk190), the deleted entry's key
copy freed with full balance (t581, wrap + memcheck = 0, own check)
and the named rejections for a non-hash target and a non-integer
position (t582/t583). EVERY out-of-range position is Harbour's
BASE/1187 dialog (hk189): the registered dialogo-sin-oraculo family,
clean bound-error exit here, never a compat success. A float position
truncates in the oracle (hk190) and stays outside the dialect's
numeric syntax; the CaseMatch flag is irrelevant (positional match).
hbc_hdelat is canaried in the ABI harness on both targets, including
the registry check on the freed key copy. Measured note: hb_HPairAt
returns a mixed {key, value} array (hk188), outside this increment's
array support - it stays out of the surface, verified.

t574-t579 (iteration 58): hb_HKeyAt / hb_HValueAt over the new shared
leaf helpers hbc_hkeyat / hbc_hvalueat - key and value casilla at a
1-based insertion-order position, compact after hb_HDel (t574;
hk184/hk186), a stored NIL returned as NIL (t575; hk185), the returned
key an OWNED copy that survives the source hash with full balance
(t576, wrap + memcheck = 0, own check) and the named rejections for a
non-hash target and a non-integer position (t577-t579). EVERY
out-of-range position is Harbour's BASE/1187 dialog (hk184/hk185): the
registered dialogo-sin-oraculo family, clean bound-error exit here,
never a compat success. Float indices truncate in the oracle (hk186)
and stay outside the dialect's numeric syntax. Both helpers are
canaried in the ABI harness on both targets.

t568-t573 (iteration 57): hb_HScan(h, value [, start]) over the new
shared leaf helper hbc_hscan - the first insertion-order entry whose
stored {tag, payload} equals the value argument, 0 when absent (t568;
hk178), the start inclusive with 0/NIL/omitted scanning from the first
entry and negative or past-the-end starts finding nothing without
error (t569; hk179/hk182), a stored NIL matched by a NIL argument
(t570; hk180) and the named rejections for a non-hash target, a
non-integer start and a string scan value (t571-t573). Float start
truncation (hk183) stays outside the dialect's numeric syntax; the
CaseMatch flag does not affect value comparison in this increment
(string values are outside the measured scope - registered limit, no
claim). A missing value argument is Harbour's BASE/1123 dialog
(hk182), the registered dialogo-sin-oraculo family. hbc_hscan is
canaried in the ABI harness on both targets.

t556-t567 (iteration 56): hb_HCaseMatch / hb_HSetCaseMatch over the new
hbc_hcasematch / hbc_hsetcasematch helpers and the CaseMatch flag in the
hash block's new 16-byte [flags][capacity] header - default sensitive
(getter printed 1/0, boolean rendering family), insensitive matching on
the LAST insertion-order match for reads, writes, hb_HPos and hb_HDel
(t556-t559, t561; hk169-hk172, hk174), flag propagation through hb_HClone
including an empty flagged hash (t560/t563; hk173/hk176), hb_HMerge
obeying the DESTINATION's flag (t562; hk175), owned key temporaries
(hb_HKeys(h)[i]) through the insensitive path with full balance including
a header-only block (t564, wrap + memcheck = 0, own check) and the named
rejections for a non-hash target, a non-integer flag and a subscript
target (t565-t567). Folding is ASCII-only (measured scope). hb_HGet on a
missing key stays the already-registered failure family (hk177 confirmed
the dialog in insensitive mode too). The per-target hbc_hfreeblock
releases the new block layout on both targets and is canaried in the ABI
harness together with the two new helpers.

t550-t555 (iteration 55): hb_HClone(h) over the new hbc_hclone helper -
copy independence in both directions (t550, hk166) for string keys
and scalar int/NIL values (the only value types of this increment;
no claim about nested structures), insertion
order + NIL + empty clone (t551, hk167), independent freeing of clone
and source (t552, balance 0, own check), non-hash target rejected
(t553). hb_HMerge edges: self-merge is a clean no-op (t554, hk168)
and merged entries survive the source hash being freed (t555, deep
copies, balance 0, own check). New helper canaried on both targets.

t546-t549 (iteration 54): hb_HMerge(dst, src) over the new hbc_hmerge
helper - source wins on overlap and keeps its position, new keys
append (t546, hk164), empty target/source edges and an unmutated
source (t547, hk165), non-hash target/source rejected at compile time
(t548/t549). The call returns the target hash (hk165: ValType "H");
the statement form is the PoC surface, the return value registered out
of scope, and both arguments are hash variables in this surface.

t545 (iteration 53): leak fix - hb_HDel freed no owned key temporary
(same pattern as the hb_HHasKey leak of the 52, found in the StrOwn
review matrix; h[k] reads/writes and hb_HGet/hb_HSet/hb_HPos verified
clean). t545 pins the fix with a genuine element-copy key (balance 0).

t544 (iteration 52): leak fix - hb_HHasKey freed no owned key
temporary (found by memcheck probing with a genuine hb_HKeys element
copy; a function-returned literal types Str and never exercised the
path). t544 pins the fix (balance 0); t533/t535/t542 were rewritten to
use genuine owned key temporaries (outputs unchanged).

t540-t543 (iteration 51): hb_HPos(h, key) over the new hbc_hpos leaf -
1-based live position, 0 when absent (t540, hk162), positions compact
after hb_HDel and a re-add goes last (t541, hk163), an owned key
temporary is freed after the call (t542, balance 0, own check),
non-hash target rejected at compile time (t543). New helper canaried
in the ABI harness on both targets.

t535-t539 (iteration 49 ownership follow-up): hb_HGet with an OWNED key
temporary frees it after the lookup, with and without the integer
default (t535: wrap + memcheck balance 0, own check, not an oracle);
a string literal, an owning string temporary, an array or a hash as
the DEFAULT are explicit compile-time rejections in this increment
(t536-t539) - no unsupported form is ever silently discarded or leaked
by the default slot.

t532-t534 (iteration 50): hb_HSet(h, key, value) - the functional hash
write over hbc_hput; write semantics reproduced (t532, hk159), KEY
evaluated before the value (t533, hk161 - the opposite of h[k] := v,
h4), owned key temporaries freed after the copy (t533, balance 0, own
check), non-hash target rejected at compile time (t534). The call
returns the hash (hk160: ValType "H"); the statement form is the PoC
surface and the return value is out of scope (registered).

t528-t531 (iteration 49): hb_HGet(h, key [, default]) over the existing
hbc_hget helper; measured reads reproduced (t528: with/without default;
existing NIL stays NIL - the default never overrides it, hk158c); the
default IS always evaluated and its value discarded (hk158f1/f2/f3,
pinned by t531 on both targets - effects fire on present, NIL and
missing keys, before the error), missing
key with or without default is the BASE/1132 condition and takes the
registered clean bound-error exit (t529, exit 1; Harbour's dialog hangs
headless, hk158a/b/d - failure-mode registration, never a compat
success), non-hash target rejected at compile time (t530). New dedicated
hbc_hget canary in the ABI harness (hit: entry pointer with tag/payload
verified; miss: 0; results saved before abi_check).

t525-t527 (iteration 48): hb_HHasKey(h, key) - new leaf runtime helper
hbc_hhaskey (no allocation; hash and key only read); the oracle's nine
answers reproduced as 1/0 (t525 - the dialect has no logical type, so
1/0 is the PoC surface; the oracle's .T./.F. is the registered boolean
rendering family), empty-hash and borrowed-key cases (t526), non-hash
target rejected at compile time (t527). Dedicated hbc_hhaskey canary in
the ABI harness (present and missing key, canaries/stack/alignment after
every call; it caught a result-clobber in its own first draft - the
result is saved before abi_check).

t521-t524 (iteration 47): hb_HDel(h, key) - new runtime helper hbc_hdel
frees the hash-owned key copy and shifts the remaining entries down;
hk155 reproduced byte for byte (t521), hk156's order and no-op facts
verified with literal-key reads (t522 - the Dyn `for each` variable as a
read key stays a named limit), deleted key copies freed with balance 0
(t523, own check), non-hash target rejected at compile time (t524).
Dedicated hbc_hdel canary in the ABI harness (entry shift, count and
no-op redelete verified, canaries/stack/alignment after every call).

t518-t520 (iteration 46): hb_HValues(h) - new runtime helper
hbc_hvalues (ABI-canaried on both targets): value casillas in
insertion order into a NEW independent array (oracles hk153/hk154;
t518/t519), result freed by the DArr epilogue with balance 0 (t520,
own ownership check, not a Harbour oracle).


t599-t607 (iteration 62): Harbour logicals as a real type - dotted
literals .T./.F., operators .AND./.OR./.NOT. (oracles hk197-hk204).
t599 reproduces hk197 byte-exactly (literals print .T./.F., ValType
"L"); t600 hk198 (comparisons produce logicals, printed and typed);
t601 hk203 (short-circuit measured by effects: rama1b/evalT/rama2/
evalF); t602 hk204 (parameters and returns; the identity shape pins
through `.AND. .T.` because body-only inference cannot type a bare
returned parameter - registered limit); t606 the case-insensitive
dotted forms including .NOT..F. (hk199c/hk200); t607 a logical
variable reassigned and branched on. t603 pins the bare-word
rejection (AND/OR/NOT are not operators in Harbour either - E0030,
hk199), t604 the trailing-token parser error, t605 the mixed
logical/number comparison (Harbour's BASE/1071, hk202 - compile-time
rejection here). Dyn logical cells (arrays/hashes of .T.) measured
(hk201); ordering on logicals unmeasured, stays rejected.

t608-t613 (iteration 62b): Dyn tagged logical cells (tag 3) end to
end - oracles hk201 and hk205-hk208e. t608 reproduces hk201
byte-exactly (a flat literal mixing logicals and integers becomes a
dynamic tagged array; Dyn logical equality compares payloads - the
tag-only shortcut made .T. = .F. wrongly .T. and was removed);
t609 hk205 (hash writes; hb_HHasKey keeps the registered 1/0
surface, 1 here vs .T. in Harbour); t610 hk206 (hb_HSetDef
overwrite on tag difference, hb_HScan finds a logical); t611 hk207
(hb_HClone/hb_HValues preserve logical cells); t612 the AAdd/ArrSet
part of hk208; t613 hk208e (hb_HCopy source first, hb_HFill with a
logical); t614 the alloc/free balance of logical-casilla structures
(mixed literal, AAdd growth, hash writes, HClone, HValues, HCopy,
HFill - wrap + memcheck 0 after the owning frame frees them). The
ABI harness carries dedicated canaries for hbc_dyn_eq tag-3 and the
new hbc_dyn_to_log on both targets. t615/t616 pin the missing-key
error contract as executable regressions (ValType and plain read,
hk209/hk209b - exit 1 "Bound error: array access" on both targets,
never a silent read); t617 the NIL casilla in condition position
(hk210 - exit 1 via hbc_dyn_to_log); t618 the positive twin: a bare
logical casilla branches in if/while (the if/while checkers now
admit a Dyn condition, matching Harbour's runtime-checked IF). A Dyn in condition position materializes through the new
hbc_dyn_to_log (logical keeps payload; NIL, integer or string
cell is Harbour's error condition - hk210, dialog hangs headless -
clean exit 1 here); ValType over a hash casilla measures "L";
a missing key is Harbour's BASE/1132-family error condition (hk209,
dialog hangs headless) and takes the registered clean bound-error
exit - not a silent "U" read. Registered limit: a mixed literal must be all
literal elements.

623/623 manifest cases + ABI harness green on Linux x86-64 and Wine
(Wine is not real Windows).

t619 (iteration 63a): PROCEDURE keyword + case-insensitive
identifiers normalized at the token level (Harbour semantics; the
casing of two existing neg messages, t88 and t603, follows the
normalization - same errors, same semantics). Upstream hello.prg
compiles and runs byte-identical to Harbour (the first of the
frozen 175). Forward references stay the next registered blocker.

t620-t622 (iteration 63b): Harbour comment forms, measured by oracle
family hk211 (own probes, no Harbour code): `//` and `&&` to end of
line, `*` as first non-whitespace character (leading whitespace
allowed, hk211b), `/* ... */` blocks mid-line (hk211c) and spanning
lines (hk211f), NON-nesting (the first `*/` closes), code after the
closing `*/` on the same line (hk211g), markers inside string
literals are data (hk211g), unterminated block at EOF is a compile
error (hk211h, Harbour E0023; our message cites the opening line).
Stripping runs inside the preprocessor over raw lines, before
directives and `;` continuation joining, line-count preserving; the
b39c guard (text after `;`, even a comment, is a syntax error) is
kept: a comment stripped after a `;` blocks the join (t622).

t623-t624 (iteration 63c): `!` is the prefix .NOT. (oracle hk212: same
operand rules and precedence as the dotted word; `!=` unchanged) and
single-quoted strings (oracle hk213: same string type, the other quote
nests; NO escapes - hk213b measured the backslash as a literal
character, so '...' is stricter-Harbour than our registered "..."
escape deviation). String `+` concatenation is NOT yet supported
anywhere (no runtime helper); it is the next registered gap and the
reason several quote-form files still stop later.

t625 (iteration 63d): a single `=` in statement position assigns
(oracle hk214: `x = 41 + 1`, `c = 'eq'`, `x = x + 1`); inside
expressions `=` remains the comparison. Parser-only change.

t626-t627 (iteration 63e): string `+` concatenation (oracle hk215,
own probe: literal chains, var+var, var+literal, concat inside a
comparison, reassignment of an owned local) via the new platform-
neutral hbc_strcat helper (fresh owned buffer, length at -8 like
hbc_strcpy; copies BOTH operands, variables keep theirs, owned
temporaries freed right after the copy). Parameter pinning: a `+`
with string evidence pins both sides to strings, not integers.
Dedicated ABI canary in the harness (canaries, stack balance,
alignment, content and free). `"a" + 1` keeps the registered
"arithmetic requires integers" rejection (t627). Frozen-175 sweep
re-run after the 63b-63e batch: still 1/175, no regressions - 25
files report a DEEPER first error (later line or later phase).

t628-t632 (iteration 63f): a whole-line call `f(args)` is now a
statement: the callee runs and its return value may be discarded
(None/I64/Str/Bool are plain values; a discarded owned string is
freed by the statement codegen - t631 pins hb_memcheck() == 0;
Dyn owns nothing). Discarding a dynamic array return is rejected
(t629), and an unknown name in statement position keeps its
name-resolution error (t630). t628 byte-matches the Harbour
oracles hk216b+hk216 for statement-form calls. len() now also
accepts strings (oracle hk217: 5/0/3; t632); the registered
limitation stands that a string parameter under len() still pins
as an array. 623 -> 628 tests, all green plus the ABI harness.
Paired measurement (sonda, NOT upstream; 19999 iterations of
`s = s + "x"`, 3 warmups + 21 timed runs, same machine):
HarbourRust median 158.7 ms (min 135.5, p95 190.3) vs Harbour
median 2.5 ms (min 2.3, p95 4.9) - about 63x slower on this
workload. Attribution: each concat does an mmap/munmap pair
(~100 ms sys) plus a full copy of the accumulator (O(n^2) in
bytes), while Harbour grows the buffer in place when it can,
amortized O(n). Registered as the top optimization target;
correctness first, no parity claim.

## 63g — passing @arguments by reference (t633-t641)

**New syntax** `@name` as a call argument borrows the caller's variable exclusively and passes a pointer; assignments inside the callee store through the pointer, so the caller's variable mutates (Harbour byref semantics). Caller locals named in any @arg widen Str→StrOwn so their storage is owned. Integers, logicals and owned strings are supported.

- t633-t635: i64 mutation (hk216b), string mutation + grow (hk218), byref pass-on `f`→`g` (hk220).
- t636 (neg): alias rejection — `f(@x,@x)` or any second mention of x is refused. **Registered divergence**: Harbour *allows* `f(@x,@x)` (oracle hk219 prints 2) and lets both params alias the same slot; we reject to keep the borrow exclusive. The original byref.prg is therefore not fully compatible here.
- t637 (neg): `@x + 1` is a syntax error, like Harbour (hk221, rc=6).
- t638: self-assign `p := p` through the pointer is a no-op (hk222); RHS is preserved on the stack before the old buffer is freed (no use-after-free). Memcheck protocol: program prints `len(hbc_live())`-style count and the battery compares the exact count.
- t639 (hk224): returning a *derived* string from a borrowed param is safe (`return p + "?"` copies).
- t640 (hk225b): assigning a rodata literal into an owned slot through @ (checker previously rejected `owned := "lit"`; fixed as part of 63g — mirrors the call-arg contract).
- t641 (neg): moving a byref param out of its owner (`q := p`, `return p`, passing by value) is rejected as not Harbour semantics.
- Collections under @ are rejected with a named message pending the RC decision (analysis not done).

**Sweep**: 23 files moved past the `@` tokenizer error to their next blocker (byref.prg now stops at `STATIC`, others at LOCAL-without-init, `%`, floats, ...); still 1/175 — the @-bearing files have other gaps ahead.

## 63h — string capacity header + in-place grow (concat performance)

Runtime: strings carry a 16-byte header {capacity at -16, length at -8}; fresh copies start cap == len; all string frees go through the new hbc_freestr (own registry snippet on Windows). New hbc_strgrow appends in place with doubling realloc; codegen emits it for `s := s + rhs` on a plain owned local only when rhs neither mentions s nor contains a call. Every other form keeps strcat copy semantics.

- t646-t651: dedicated grow/freestr regressions with hb_memcheck() counts — content equality against the strcat path, realloc fallback on a single large append, excluded-call fallback, self-alias fallback, grow with a local rhs, hash key replace under the new layout.
- t650 is also the regression for hk238 (bug found by these new tests, ours not Harbour's): a `@` string param plus a `for` loop crashed — the statement walk restarted the frame from the remapped one-word RefStrOwn size while the layout used the declared 16-byte size, so the loop counter overwrote the byref slot pointer. The walk now starts from the declared param sizes.
- ABI harness: two latent instrumentation bugs fixed (harness, not runtime): a hbc_free2 call that relied on a stale esi (masked by the old heap layout; surfaced as SEGV on Linux and "OS free failed" under Wine) and eight strcpy-built strings still freed with the old-layout free.
- Performance: concat probe median 148.75 → 0.29 ms at N=20000 (total time, startup-dominated at that size); at work-dominated sizes 0.99/1.51 ms vs Harbour 10.94/23.66 ms at N=200000/400000. Full record in docs/BENCH-strcat.md round 3.

**Sweep**: not re-run — no syntax change in this iteration.

## Iteration 63i — LOCAL without initializer + multi-declaration (2026-10-26)

`local name` (no `:= expr`) now parses and the slot starts NIL, matching Harbour oracle hk239/hk241: printing gives NIL, ValType() "U". Comma-separated multi-declarations also parse, with per-item optional initializers: `local a, b, c` and `local a := 10, b, c := "xy"`. The splitter tracks (), [] and {} depth so `local a := {1, 2}, b := 5` is not split inside the array literal.

Limits (existing Dyn-slot rules, not new): a NIL-started Dyn slot accepts i64/bool/NIL reassignment but rejects owned strings ("type mismatch in assignment"); Dyn slots are never string-owners, so nothing leaks at the epilogue. Same behavior class as the already-registered Dyn limits.

- t652: local sin init -> NIL / "U" / reassign 42 / "N" / memcheck 0.
- t653: multi-decl `local a, b, c` all NIL, later assignments sum 6.
- t654: mixed `local a := 10, b, c := "xy"` -> 10, NIL, xy. Matches Harbour hk241 byte for byte.
- t655: neg — string into NIL-started slot rejected with the standard Dyn message.
- t656: regression — array literal inside multi-decl (initial splitter counted only ()/[] depth and broke every `local a := {...}` in the battery; {} added, full battery re-green).

**Sweep**: re-run on the frozen 175 — still 1/175 (hello.prg); the 18 files that previously stopped at "expected `local name := expr`" now advance to their next blockers (comma-in-expression, floats, command verbs), as the earlier category reclassification predicted. Full-directory check (237 files) additionally compiles dynwin.prg, but that is a hollow pass: its entire body sits under `#if defined( __PLATFORM__WINDOWS )`, so it compiles to an empty PROCEDURE. Not counted as a win.

## Iteration 63j — owned strings in Dyn slots (tag 4) (2026-10-26)

A Dyn slot (e.g. `local x` with no initializer) now accepts string
assignment. The value model keeps tag 2 = a BORROWED string view (FOR EACH
over hash keys; never freed) and adds tag 4 = an OWNED string with the
63h 16-byte header layout, freed by exactly one owner. This answers the
load-bearing review point that tag 2 alone never proved ownership.

Boundary rules (each verified by test): a literal is cloned at the slot
boundary; an owned string expression moves in; a Dyn-to-Dyn copy from a
variable clones (Harbour value semantics; a call result moves its owned
temp); every store into a Dyn slot frees a live tag-4 payload first; the
epilogue frees tag-4 payloads of Dyn locals AND Dyn parameters (params
are cloned at the call boundary, so caller and callee never share an
allocation); a Dyn return hands the caller its own clone; a printed or
compared owned temporary is freed after use. Read paths treat tag 4 as a
string: print, ValType "C", and the three Dyn comparison helpers
(hbc_dyn_eq / hbc_dynxcmp / hbc_dynxeq_dd, both target blobs) normalize
tag 4 to tag 2 at entry — this fixes a real bug found by probing, where
two owned Dyn strings compared .F. by payload pointer.

Oracles: hk242 (string/int transitions on a NIL-started local: abc, C,
abcdefgh, 5, N, z, C, .T., .T.) and hk243 (callee reassignment does not
affect the caller; a returned string survives both storage and direct
printing). t657-t661 match them; hb_memcheck 0 wherever no value is
legitimately live at print time (t661 documents its expected 1: the
loop-local still owns its clone at print time, the epilogue frees it
after; the ABI harness process-exit balance is the leak gate and is
green on Linux and Wine).

Limits (registered, not regressions): Dyn array ELEMENTS still reject
strings (checker-named); Dyn-vs-string concat is rejected ("arithmetic
requires integers"); a parameter whose body usage infers an owned-string
type cannot then receive a Dyn argument (the inference pins first);
hash values with a tag-4 payload inherit exactly the existing tag-2
hash-value semantics (hbc_hput stores the pair); `==` between an owned
Dyn string and NIL/numeric follows the same registered failure modes as
tag 2. STATIC/PRIVATE/PUBLIC are ordinary backlog, NOT user-blocked —
an earlier report mislabeled them as awaiting a user decision; no such
decision exists in the record.

- t655 rewritten positive (the 63i neg case is now legal): local s; s := "abc".
- t657: hk242 exact, incl. `==`/`=` against a literal and NIL teardown.
- t658: Dyn-to-Dyn copy independence, self-assignment, content compare.
- t659: param clone-on-pass, callee reassign, caller untouched, memcheck 0.
- t660: return clone, stored and directly printed, memcheck 0.
- t661: loop reassignment + per-iteration redeclare, memcheck 1 explained.

**Sweep**: re-run after this runtime change — frozen 175 still 1/175
(hello.prg); the full-directory hollow pass on dynwin.prg unchanged.

### 63j closeout (boundary evidence)

- Function-exit accounting (t662): memcheck INSIDE the callee after a
  param swap reads 2 (caller's live string + callee's owned swap), 1 back
  in the caller (callee epilogue freed its copy), 1 after `x := mk()`
  (the returned clone; the callee freed its own at its exit), 0 after
  teardown. Process-exit balance alone could hide a temporary retention;
  these counts sit at the exit points.
- Owned vs borrowed (t663, neg): a FOR EACH variable holds a borrowed
  tag-2 view and is checker-fenced — it cannot be stored, passed or
  returned ("its value borrows from the collection"). Borrowed casillas
  therefore never reach the tag-4 free machinery by construction.
- Alias between slots (t658): `y := x` clones BEFORE the old payload of y
  is freed; `x := y; y := x` chains stay independent; self-assignment
  clones before freeing. Caller/callee/return boundaries: t659 (param
  clone-on-pass + callee reassign), t660 (return clone, stored and
  printed directly). All under the ABI harness on Linux and Wine.

## Iteration 63k — DO WHILE / DO ... WITH command forms (2026-10-26)

Two command forms from the originals' largest first-error cluster
(53 identifier-led statements): `DO WHILE <cond>` parses as the plain
`while` loop (same ENDDO; LOOP and EXIT unchanged — oracle hk244: i=4,
n=3) and `DO name [WITH arg, ...]` is command sugar for the bare-call
statement (arguments evaluate: 41+1 -> 42). `DO CASE` gets a named
rejection this batch ("not in this increment; use if/elseif/else/endif")
so the sweep classifies it honestly instead of a generic parse error.
The WITH argument splitter tracks (), [] and {} depth.

- t664: do while + loop/exit, matches hk244.
- t665: do ... with two calls, string and evaluated numeric args (natural shape, oracle hk245).
- t666: neg - DO CASE named rejection.

Also fixed a pre-existing inference defect surfaced while writing t665
(reproduced with plain call syntax, so NOT from the DO parser change):
when ANY parameter of a function stayed uninferable, pin_params
discarded every parameter's evidence and fell back to i64 placeholders,
so an unrelated `param == "literal"` died with the misleading `==`
named rejection instead of naming the uninferable parameter. pin_params
now returns partial pins: pinned parameters keep their real type, only
the uninferable ones get the i64 placeholder, and the error names the
actual parameter (t667 locks it: "cannot infer the type of parameter
`num`"). No previously accepted program changes behaviour: the pin
error still fails the compile after the body check, and body errors
still surface first.

- t667: neg - uninferable parameter named explicitly (regression lock
  for the partial-pin fix; repro shapes v1/v2/v3 in the 63k notes all
  took the misleading `==` path before).

t665 uses the NATURAL shape (string `==` on one parameter before any
arithmetic use of the other) and matches the new Harbour oracle hk245
byte for byte (hello / 43 / bye / 8).

**Sweep** (frozen 175 baseline; delta vs the previous full run): 12 rows changed, all
advances or better-classified errors, 1/175 COMPILES unchanged (dynwin
stays the hollow `#if`-guarded pass, never counted):
- calling.prg: DO ... WITH parses; advanced to the next real blocker
  (forward reference to `secondone`).
- exit.prg, fib.prg, while.prg: DO WHILE parses; advanced to the `++`
  / `+=` blocker.
- fileio.prg, fileio2.prg: DO WHILE parses; advanced to a `?`-token
  blocker deeper in the file.
- guestbk.prg, inherit.prg: first error moved later within the same
  identifier-led category (a DO form earlier in the file now parses).
- docase.prg, returns.prg: DO CASE now gets its named rejection instead
  of a generic parse error (honest classification).
- mem.prg: advanced past `a := "Hello"` on a multi-decl local - this is
  the 63j Dyn owned-string change surfacing (the 10:04 reference run
  predates the 63j binary), not a 63k change. Next blocker: unknown
  function `hb_symbol_unused`.
- directry.prg (include line 10, `IF ! cshort == NIL ...`): same line,
  different named rejection. The partial-pin fix stops masking the
  pinned parameter with an i64 placeholder: `!cshort` pins it logical,
  so the old ".NOT. needs a logical operand" becomes the more precise
  "`==` against NIL is measured only for ..." rejection. Still not
  compilable; the classification is the improvement.

## Iteration 63l — statement ++/-- and compound assignment (2026-10-26)

Statement-level increment/decrement and compound assignment from the
originals' first-error cluster (oracle hk246, measured on hbmk2):
`++x`, `x++`, `--x`, `x--` desugar to `x := x +/- 1`; `x += e`,
`x -= e`, `x *= e` desugar to `x := x op e`. All typing, ownership and
codegen flow through the existing assignment path, so only forms the
desugared assignment already justifies are accepted.

Named rejections, all measured against hk246:
- `/=`: Harbour division yields decimals (n /= 2 prints 24.00); the
  float/decimal design stays parked (hk226-hk233).
- `++`/`--` inside expressions (postfix `x++` reads the OLD value,
  prefix `++x` the NEW one): needs sequenced side effects in the
  expression evaluator, a design of its own. Statement forms cover
  exit.prg and fib.prg; while.prg's `do while x++ < 1000` keeps the
  named rejection.
- Adjacent `--` in expression position: it used to parse as double
  negation `-(-x) = x`, a SILENT Harbour miscompile (`y := --x`
  computed x; Harbour pre-decrements). Now rejected by name (t674).

- t668: ++x, x++, --x, x-- -> 1, 2, 1, 0 (= hk246).
- t669: +=, -=, *= -> 15, 12, 48 (= hk246).
- t670: string += on an owned slot (parameter) -> abcd (= hk246).
  A literal-initialized local is a borrowed rodata view (Ty::Str), so
  `s := s + "cd"` on it hits the pre-existing hk225 owned-into-borrowed
  rejection; that restriction is not from +=.
- t671-t674: the named rejections above.

**Sweep** (frozen 175; provenance: src-sha256:7842db962de8d273,
bin-sha256:fb3d81d80c610b3c, 2026-10-26 (this 63l source); compared
against the post-63k sweep of HEAD 868b3f57): 9 rows changed, all advances:
- errsys.prg: COMPILES and RUNS to Harbour's own failure point - `n++`
  on a NIL local raises "Type error: NIL used as a number" and exits 1;
  Harbour prints the same message and then blocks on its interactive
  error dialog (the registered failure-mode difference, DIVERGE-FAILMODE).
  First real original beyond hello.prg to compile and behave.
- exit.prg, fib.prg: `++` statements parse; advance to the call-args and
  for-variable-declaration blockers.
- while.prg: the embedded-`++` named rejection replaces the generic
  "unexpected token Plus".
- dates3, guestbk, longdev, longstr2, t1: compound assignment parses;
  first error moves to the next blocker in each file.

## Iteration 63m — file-scope declarations and implicit main (2026-10-26)

File-scope forms measured first against hbmk2 (oracles hk247a-hk250a):

- Implicit main (hk247a): a leading group of bare statements at file
  scope becomes the synthetic program entry; locals at its top work
  like any body, and one optional closing `return` is consumed. A
  second top-level statement group after any function definition is a
  NAMED rejection - Harbour silently drops it (hk247c, hk247f), and a
  silently dropped behavior is not one to reproduce. Implicit main
  plus an explicit Main is the existing duplicate-function error
  (Harbour silently prefers the explicit one, hk247e; registered
  divergence).
- File-scope MEMVAR lines are accepted and ignored (hk247b). The
  declaration relaxes Harbour's compile-time memvar name resolution
  only; it creates NO storage, so any later memvar reference still
  fails by name (t685) - accepting the line can never fabricate a
  working memvar.
- REQUEST (hk250a) is NOT treated as a blanket no-op: in Harbour it
  pulls a module and its init code into the link, an effect this
  subset cannot reproduce. The only REQUEST honored is one naming a
  function defined in this same file. Even that honored case is
  inert-only: no module-link, INIT/EXIT or symbol-registration
  semantics are implied or reproduced. Anything else is a named
  rejection (t686) instead of a silently skipped effect.
- STATIC FUNCTION / STATIC PROCEDURE parse as plain functions
  (hk249), scoped to the single compilation unit this compiler
  builds: static linkage only scopes symbol visibility between
  units, and with one unit the distinction is inert. Name conflicts
  stay detected - a STATIC and a plain function with the same name
  hit the duplicate-function error (t687), as Harbour reports too.
  No cross-unit visibility equivalence is claimed. File-scope
  STATIC VARIABLES are globals and get a named rejection (global
  storage needs its own design).
- `func` and `proc` are lexer aliases for FUNCTION / PROCEDURE
  (hk249). NOTE lines are comments to end of line, valid at file
  scope and inside bodies (hk249), unless the second token is an
  assignment (`note := 1` stays a variable named note).
- INIT / EXIT PROCEDURE: named rejection (startup/teardown ordering
  needs its own design).
- The preprocessor now predefines `__HARBOUR__` = 197121 (0x030201,
  Harbour 3.2.0dev, measured on the pinned harbour-core, hk248) on
  every target. It is a VERSION STAMP ONLY, so conditional
  compilation can take Harbour branches (`#ifndef __HARBOUR__` ->
  skip clipper.ch); it is not a claim of Harbour runtime
  completeness.
- The platform macro follows the COMPILE TARGET, never the host:
  the Linux target defines object-like `__PLATFORM__UNIX` and the
  Windows target `__PLATFORM__WINDOWS` (hk248 measured the Linux
  side; the Windows side mirrors the same platform-macro rule).
  Verified per target with one conditional source: the Linux build
  prints the unix branch (equal to the hk248 Linux oracle), and the
  --target=windows build under Wine prints the windows branch. The
  Windows branch print proves OUR target switch selects the right
  macro; it is NOT a measurement against a Harbour Windows oracle
  (none was run). Windows-target compatibility beyond this target-
  switch contrast is not claimed. Macro names are exact-case in this
  preprocessor; the predefined keys use the upper-case spelling the
  ecosystem writes.

- t675: implicit main prints lead, ok (= hk247a).
- t676: implicit main with locals and a closing return -> 42.
- t677: file-scope MEMVAR skipped and REQUEST of a file-defined
  function honored; body runs.
- t678: STATIC FUNCTION + proc + NOTE -> 42 (= hk249).
- t679: func alias -> 42.
- t680: ? __HARBOUR__ -> 197121 (= hk248).
- t681-t684: the named rejections above.
- t685: MEMVAR declaration + reference still fails (no fabricated
  storage).
- t686: REQUEST of an undefined symbol is the named rejection.
- t687: STATIC/plain same-name functions are duplicates.

Battery: 683/683 + ABI harness green (Linux and Wine byte-identical).

**Sweep** (frozen 175; provenance: src hbc.rs sha256
ac5d8a03ac1766f901449ca2b60bc28f3e44614d94ca877950571a2451d9ac60,
src pp.rs sha256
ec5bb2cdaa8287ba2ba1578440d727a4736aaa46f6bef1506603b8b20d9d8df5,
compiler binary sha256
6cb75cce3342ada4d375dbe7655444933383a02d7114e45592630913deda971b,
2026-10-26 (this 63m source); compared against the 63l sweep of HEAD
d37e0f4f): the 22-file "code outside a function" cluster COLLAPSES to
zero; all 22 files now advance to their next real blocker (unknown
builtins such as aeval/cmonth, the ^ and & operators, multi-index
arrays, memvar references). COMPILES drops from 2 to 1 (hello.prg):
- errsys.prg no longer compiles. With __HARBOUR__ correctly defined,
  its `#ifndef __HARBOUR__` / `#include "clipper.ch"` guard now skips
  the include (measured Harbour behavior, hk248), and the file stops
  at line 12 on the unknown builtin `hb_symbol_unused`. Correction to
  the 63l wording: errsys was never a compatible success - it compiled
  and matched Harbour only up to its own error point (DIVERGE-FAILMODE
  on the interactive dialog), and its current state is a plain subset
  limit like any other missing builtin.
- dynwin.prg still compiles hollow behind its __PLATFORM__WINDOWS
  guard and is not counted as a real success.
- langapi.prg now stops at line 4 on the named REQUEST rejection
  (`hb_lang_hu` is an external module; honoring it would fake a link
  effect). This is deliberate: a named limit, not a silent skip.

## Iteration 63n — order-independent inference / forward references (2026-10-26)

Calls to functions defined LATER in the file, including self and mutual
recursion (oracle hk253: Early(3)=30, static MutA(2)=2; Harbour
compiles the whole file without textual order). Pass 1 no longer
accumulates signatures in textual order: `view` always holds a
COMPLETE signature table for the file, seeded with placeholder types
(i64 parameters, void return), and each round re-infers every function
from the AST against the previous round's table. A round that changes
no entry proves convergence; only the converged round's errors are
emitted (placeholder-dependent errors are dropped). Termination rests
on finite progress, not a guessed round count: entries only move
placeholder -> concrete and then up the finite pin-merge lattice
(i64 < Dyn, DArr < DArr2 < DArr3 < DArr4), and call-site
borrowed/arr_moved flags only flip false -> true and live in the
persistent table, so every non-converged round strictly increases the
summed lattice height. The cap is computed from that bound; hitting it
is an explicit diagnostic, never a silent assumption. No new semantics
or storage: the rule that a callee's parameter types come from the
callee's own body evidence is unchanged; callers only CHECK.

- t688: call-before-definition -> 30 (= hk253).
- t689: mutual recursion between STATIC functions -> 2 (= hk253).
- t690: ten-deep reverse call chain -> 109 (no fixed round cap would
  justify this chain; the monotone bound does).
- t691: forward call whose return pins a local's string type across
  rounds -> hi!
- t692 (neg): a forward call with a string argument where the callee
  needs an integer is still detected after convergence.
- t643 FLIPPED from neg to pos: its premise was the define-before-use
  rejection itself. Self-recursion re-lending a @ borrow compiles and
  is byte-identical with Harbour (oracle hk255: both print 0); each
  frame's borrow ends before the inner call's begins.

Battery: 688/688 + ABI harness green (Linux and Wine byte-identical).

**Sweep** (frozen 175; provenance: src hbc.rs sha256 2c67976961c21e6844d25a278c8690b30bd032df30562c05a045676ae6cd2ba9,
compiler binary sha256 d2309ce04279204a7bab3d26bdd3e4418fc8c76385b5402a438e37e15066df3e, 2026-10-26 (this 63n source); compared
against the 63m sweep of HEAD a28f0ac8): the four genuine forward-
reference files advance - statfun.prg COMPILES and its output is
BYTE-IDENTICAL with Harbour (verified with diff: "From Main()" /
"From Second()" / "From Main() again") - the second real original to
compile and behave (hello.prg was the first; dynwin stays hollow and
uncounted; errsys remains the registered DIVERGE-FAILMODE case now
stopped at its hb_symbol_unused limit). and_or, calling and lnlenli2
advance past the forward reference to their next real blockers
(boolean arguments, string arguments, string array literals).

## Iteration 63o — forward-reference hardening (2026-10-26)

Three placeholder-artifact classes in 63n's fixpoint, found by pushing
on the convergence guarantees:

- Call-site argument checks ran against PLACEHOLDER parameter types of
  not-yet-inferred forward callees, and the first such artifact could
  mask the real error at convergence: `sff("ab")` with an uninferable
  callee parameter reported "must be an integer, got a string" instead
  of the uninferable parameter. Signatures now carry per-parameter
  `inferred` flags; call sites skip per-argument checks (and flag
  flips) against uninferred parameters, so a surviving body error
  never rests on a placeholder (t693).
- Call arguments PINNED against placeholder callee types, laundering a
  placeholder into a concrete type across rounds (mutual recursion
  `ma`/`mb` cross-pinned each other's parameters to the placeholder
  i64). The pin arm now only accepts genuinely inferred signature
  entries as evidence (63o).
- Pin-error priority: a first draft gave pin errors precedence over
  body errors to surface the root cause, which broke the established
  body-first contract (t66 duplicate local, t323 pin conflict named by
  the body). Reverted: body-first stands; the artifact classes are
  excluded by the skips above, not by reordering. A no-evidence mutual
  recursion (`ma`/`mb`, t694) is rejected by the CONVERGED fixpoint -
  the ret=None cycle is the stable fixpoint state, so "`ma` never
  returns a value" is a convergent verdict, not a placeholder guess.

- t693 (neg): forward call with an uninferable callee parameter names
  the root cause.
- t694 (neg): no-evidence mutual recursion, convergent rejection.

Battery: 690/690 + ABI harness green (Linux and Wine byte-identical).
Sweep: unchanged from 63n (no sweep-visible behavior change; this is a
diagnostics/robustness increment). Provenance: src hbc.rs sha256
0ac9b666a42dffe16ee1b3affd22bde9c64715000cd6b95b60e12ecd0f50526e,
compiler binary sha256
87dab435b432629103089892f6e76d496d79f340bf1051c4e53d7eb8d5e5a07f,
2026-10-26, reference HEAD a43404a1 (63n).

## 63p - array literals of strings (routine extension; oracle hk254)

All-string array literals now compile to the same dynamic string-array
shape an AAdd-grown one has (33n): a `{data pointer, length}` slot, cells
of 16 bytes `{tag 2, owned copy}` behind an 8-byte capacity header
(capacity equals the length; later AAdd growth doubles). The layouts were
demonstrated before the change from three published paths: the AAdd
string arm (appends `{tag 2, hbc_strcpy copy}`), the epilogue free
(kind 4, `hbc_sfree` walks the cells freeing every owned copy, then the
block), and `hbc_hkeys` (same header-plus-cells block). The literal
materializes each element with the same `hbc_strcpy` the AAdd arm uses,
so every cell owns its copy and the existing free path releases it.

Scope discipline (grow-guard): pure string elements only. A string and
integer mix keeps the named rejection "array elements must be integers or
logicals" (a mixed Dyn-leaf array is parked new storage, not a routine
extension). The empty literal `{}` is untouched (still the growth seed).
Nested string literals (`{{"a"},{"b"}}`) keep the named nested rejection.

New tests (battery 690 -> 693, all green):
- t695: `{"a","bb","ccc"}` local - LEN 3, concatenation, AAdd growth to
  LEN 4, VALTYPE "A"/"C", allocation balance 0 after the owning
  procedure returns (oracle shapes hk254).
- t696: a string literal passed as a procedure argument. String-element
  evidence (`a[1] + "!"`) pins the parameter as an array of strings; the
  move at the boundary transfers ownership, balance 0. Print-only
  parameter evidence still infers a generic dynamic array and rejects the
  string argument by name - the 63n/63o inference limit, unchanged.
- t697 (negative): `{"a", 1}` keeps the named mix rejection.

Sweep 175 (reference HEAD ab4d1ea0, 2026-10-26): COMPILES 2 (hello,
statfun) - unchanged. Two diagnostic moves, both still named rejections:
- lnlenli2.prg: the line-14 string literal no longer blocks (this
  increment); the file now stops at the next named limit, "discarding an
  array of strings return is not in this increment".
- calling.prg: late-registered 63o effect, not 63p - a print-only
  parameter stopped pinning as integer when the 63o pin arm began
  requiring inferred evidence, so the file now reports "cannot infer the
  type of parameter `ctext`" instead of the old integer/string conflict.
  The new message names the real limit; coverage is unchanged.

Pending question from the 63o review, answered with probes: mutual
recursion WITH a value-returning base case infers correctly (probes:
two-function cycle returning a string prints "fin"; the same shape
returning an integer prints 7; both compile and run right). The "never
returns a value" rejection (t694) fires only for cycles with no
value-return ground evidence anywhere - genuinely ground-less recursion -
so the diagnostic is exact, not over-broad. No code change needed.

Wording register (standing): platform evidence is "Linux nativo y Wine
con oracle Linux", never "tres plataformas".

Sandbox recovery provenance (2026-10-26): the sandbox was rebuilt at
11:26 CET and the local checkout was lost; the tree was recovered from
the published 63o files plus the transcript-verbatim 63p edits. The
reconstructed src/hbc.rs hashes byte-identical to the pre-wipe
battery-tested source: sha256
aa3687fc6445e179bbd0bc652257f32c1540b2cde50f63a68e4a1e312a61ef60.
Compiler binary rebuilt after recovery with rustc 1.99.1: sha256
aa99fefeb47044565165f582b904d1ef7201fb35a0a6932f609a7c4a7a884f49.
tests/run_battery.sh sha256
f9414ceff4c03b5c5488a664f32102b5c553244bd1765a86616422124b2310ae.
Full battery re-executed on the recovered bytes at 11:36 CET:
693/693 manifest cases green plus the ABI harness, on Linux nativo y
Wine con oracle Linux - the recovered bytes are the tested bytes.

## 63q - discarding an owned array return (routine extension; oracle hk256)

A bare call discarding the callee's return is legal Harbour (oracle
hk256: the callee runs for effect, the program continues, exit 0). The
compiler already defined the discard for returns its discipline can
release right after the call; this increment extends that set from one
owned string to owned arrays of up to two levels, freeing the returned
block with the SAME helpers the epilogue uses on a slot of that type:
DArr -> hbc_free, DArrS -> hbc_sfree, DArr2 -> hbc_free2 (the return
arrives as {pointer in rax, length in rdx}, the slot convention).
Hashes, deeper arrays and codeblocks keep the named rejection.

- t698: discard a string-array return twice - side effects print,
  allocation balance 0.
- t699: discard an integer/logical array return - balance 0.
- t700: discard a two-level array return - balance 0.
- t701 (negative): discarding a hash return stays rejected by name.
- t629 FLIPPED neg -> pos (same pattern as t643 at 63n): its premise
  was the old rejection itself; `Array(2)` discarded now compiles and
  prints nothing, matching the oracle shape.

Sweep 175 (reference HEAD bb509326, 2026-10-26; src/hbc.rs sha256
d83b63e2fcb8e102c8e653f12e7444c977fd255be56824c8a9831f17a027ee29,
compiler binary sha256 2c890a2f33ac4573936677d562251e159b86cab9b21f4ec9c87cfa595acd132a,
rustc 1.99.1): COMPILES 2 -> 3. lnlenli2.prg (the line-length stress
original, 240-string array literal built and discarded) now compiles;
its output is byte-identical to the oracle's - EMPTY BY DESIGN (the
file is `//NOTEST` upstream: the work is building and discarding the
array, there is no printing), exit 0/0. This is a real build-and-free
execution, not a hollow guard like dynwin.prg's `#if __PLATFORM__WINDOWS`
(registered there). hello and statfun unchanged, still byte-identical.

Battery 693 -> 697 + ABI harness green (Linux nativo y Wine con oracle
Linux).

Correction register (from the recovery closeout): the published
tests/run_battery.sh hashes 5758eec78ce6164c3c354619b8ea16c9218d8f0ca3ee2f8b88b63a5f458ff2b3;
the f9414cef... value registered at 63p is the same file without the
web editor's trailing blank line. Content identical.

## 63r - print-only parameters pin to the tagged union; calling.prg is the fourth original

Oracles first (hbmk2 -gtstd @694428e1, sondas hk257-hk263): hk257 (a
print-only parameter accepts a string, an integer, .T. and NIL across
calls to the same function, exit 0), hk258 (a print-only parameter
receiving an array prints an empty line - NOT replicated: the tagged
union has no array cell, named rejection instead), hk259 (the exact
t693 shape `? s; return s` plus caller: prints ab, ab, 7, 7, exit 0),
hk260 (print + arithmetic pins integer: prints 5, returns 6), hk261
(print + concatenation pins string: prints ab, returns ab!), hk263 (the
exact t70 shape: prints x, returns 0).

Change: in the pin pass, a parameter whose sole non-copy evidence is a
whole-variable print pins to the tagged union (16-byte casilla: 0=i64,
1=NIL, 2=borrowed string, 3=logical, 4=owned string). Pinning evidence
(arithmetic, concatenation, known-type compare) wins order-independently
because the fallback runs after the walk. Return-only and copy-only
parameters keep the named "cannot infer" rejection (its text no longer
mentions printing). New call boundary: a string argument to a Dyn
parameter is cloned to an owned tag-4 payload - the callee owns and
frees its slot at the epilogue, the caller keeps its value (same
contract as Dyn->Dyn, cg_dyn_clone_if_str). A Dyn return hands the
caller its own clone; the shared epilogue frees the callee's copy.

- t70 FLIPPED neg -> pos (exact-case oracle hk263): its premise was the
  old rejection itself ("printing alone cannot pin").
- t693 FLIPPED neg -> pos (gate: byte output and exit match Harbour for
  `? s; return s` and the caller, oracle hk259).
- t702 (negative): a return-only parameter still cannot be inferred.
- t703: print then arithmetic - the integer pin wins (hk260).
- t704: print then concatenation - the string pin wins (hk261).
- t705: one print-only parameter called with a string, an integer and
  NIL (hk257 minus the logical call).
- t706 (negative): an array argument to a Dyn parameter is a named
  rejection (the tagged union has no array cell; oracle hk258).
- t707: Dyn parameter ownership boundary - clone at the call, epilogue
  free, clone on return, printed temporary freed; balance 0.
- t708 (negative): a logical argument to a Dyn parameter is a named
  rejection - tag-L Dyn cells land separately (registered limit; hk257
  shows Harbour accepts it).

Sweep 175 (src/hbc.rs sha256
f573bf921a83ba1caeb22cb3535c22408ec4bd4618ef409f5e5074335a31a42d,
compiler binary sha256
362395d0bb753c2f0fe3344f9edfb21b37420df69babae35f72da4874648a0b4,
tests/manifest.txt sha256
888629f40a9074e9666d332b67a37e454616b16fc4bde9110ff31bfbc7548e15,
rustc 1.99.1): COMPILES 3 -> 4. calling.prg now compiles:
`FUNCTION Fourth( cText ) ? cText RETURN NIL` is exactly the print-only
parameter shape. Original intact (sha256
2bc92508ea35cd18d06ebbeaa82afdf7c8894495fe31cec77cb8968246032de5 ==
upstream raw @694428e1); output byte-identical to the oracle on Linux
nativo y Wine, exit 0/0; 27 hbc_alloc/hbc_strcpy calls in the generated
asm (construction not eliminated). hello, statfun and lnlenli2
unchanged, still byte-identical.

Battery 697 -> 704 + ABI harness green (Linux nativo y Wine con oracle
Linux).

## 63s - logical arguments admitted at the Dyn parameter boundary

Reconciliation (main): tag-3 Dyn values already existed end to end -
hbc_print_dyn prints .T./.F. for tag 3, the Dyn->Dyn clone passes scalar
tags through, a Dyn return hands the caller its own clone, and the
epilogue frees only tag-4 payloads - so the logical case was an
admission boundary, not new architecture. Oracles first (hbmk2 -gtstd
@694428e1): hk264 (print-only parameter called with .T. and .F.: prints
.T. and .F., exit 0), hk265 (print + return of a logical parameter, the
caller prints the tagged result: .T. .T. .F. .F., exit 0). Both
byte-identical with the new compiler on Linux nativo y Wine, exit 0/0.

Change: the call-argument check admits `logical -> Dyn` and the call
codegen tags it in (tag 3, payload 0/1). Scalar: no ownership transfer;
no clone, no free. Nothing else widened: assigning a logical INTO a Dyn
slot keeps its named rejection (t711) - Dyn-slot logical stores land
with the tag-L local increment (registered limit).

- t708 FLIPPED neg -> pos (exact-case oracle hk264).
- t709: logical Dyn parameter through print and return (hk265).
- t710: one print-only parameter called with string, integer, NIL and
  logical (hk257 + hk264).
- t711 (negative): `x := .f.` on a Dyn parameter stays rejected.

Sweep 175 (src/hbc.rs sha256
03749ce74501ec925e9945079acdc77537f3cb7fab808c8b30e149614594ffb3,
compiler binary sha256
b2b269782cae3f26a8d440c26f20a64b7fb8b16ef4ed2b0badbd8ff33217aa8a,
tests/manifest.txt sha256
559cac925093b40c1c9137ccebf0bd4502dace641b7471afc645995a21492a79,
rustc 1.99.1): unchanged, COMPILES 4 (no sweep original uses the
logical boundary).

Battery 704 -> 707 + ABI harness green (Linux nativo y Wine con oracle
Linux).

## 63t - Dyn conditions require a logical cell (silent divergence fixed)

Oracles first (hbmk2 -gtstd @694428e1, sondas hk266-hk268): hk266 (a Dyn
parameter as the condition: .T. takes the branch, .F. does not, NIL is
Harbour's type-error dialog), hk267 (an integer cell in condition
position is the same Harbour type error - even 0), hk268 (a string cell
is the same type error). The dialogs cannot be probed headless; the
registered failure mode is a clean named exit 1.

Found while probing: hbc_dyn_to_log passed tag-0 (integer) payloads
through as the branch value while its own comment claimed integers are
a type error "like Harbour" - a silent divergence from hk267. Fixed in
BOTH target blobs: only tag 3 is a valid condition; every other cell
goes to the new hbc_dynlog_error ("Type error: condition is not a
logical", exit 1), so the message also stops borrowing the arithmetic
wording ("NIL used as a number") for condition failures. t617's
expectation updated accordingly (same exit 1, right message; its hk210
premise unchanged).

- t712: logical Dyn cells decide the branch (hk266).
- t713 (exit 1): an integer cell in a condition errors cleanly (hk267).
- t714 (exit 1): a string cell in a condition errors cleanly (hk268).

Sweep 175: unchanged, COMPILES 4 (runtime-helper change only).
src/hbc.rs sha256
0d74064ed1d983f7336aac56f8ea33e57a4f1928cace3c038ec636d077b4db84,
compiler binary sha256
f996c7f9b3f04e5803c483c31bef86c211da70bb7be3173972a36fc233cad9df,
tests/manifest.txt sha256
e36c675e4cd4f47c587d030b80c2fe5026b54713ba4808ca3d2c983317baf4d7,
rustc 1.99.1.

Battery 707 -> 710 + ABI harness green (Linux nativo y Wine con oracle
Linux).

### 63t canary matrix (support)

- tag 3 (.T./.F.) accepted: t712, both platforms.
- tag 0 (integer) rejected: t713, exit 1, both platforms.
- tag 1 (NIL) rejected: t617, exit 1, both platforms.
- tag 4 (owned string) rejected: t714, exit 1, both platforms.
- tag 2 (borrowed string view): unreachable from accepted shapes - a
  string-array element in condition position types as a string and is
  rejected at COMPILE time by name (t715, negative; stricter than
  Harbour, registered). The helper still rejects tag 2 by construction:
  only tag 3 passes the `cmp $3 / jne hbc_dynlog_error` guard (asm
  inspected in the generated Linux and Windows output of t712).
- Success path is a leaf (cmp/jne/mov/ret: no stack, no callee-saved
  registers); the Windows error path aligns the frame before calling
  out (push rbp / and $-16, mirrors hbc_type_error; asm inspected).
- Sweep 175 re-executed after the helper change: COMPILES 4, output
  identical to the 63s run (verified, not assumed).

## 63u - Dyn regressions: DO WHILE conditions and pinning-vs-calls

Oracles first (hbmk2 -gtstd @694428e1, sondas hk270-hk273): hk270 (a
print-pinned Dyn parameter as the DO WHILE condition: .F. skips, .T.
enters and EXIT leaves - byte-identical, exit 0; the While checker
already accepted Bool|Dyn bare conditions, no code change), hk271
(comparing against an integer pins the parameter; calling with NIL hits
the extraction failure at the call boundary. CLASSIFICATION (main,
12:47): Harbour RUNS that program - NIL = 5 is .F. (hk271) and
NIL == "ab" is .F. (hk272) - so our rejection is a registered
SEMANTIC DIVERGENCE of a valid Harbour program (a pinning-model
limitation), NOT a native failure mode. Future pin work must measure
valid polymorphism against the oracle instead of treating
"pinned, so rejected" as native-equivalent), hk272 (same class:
string-pinned parameter called with NIL - valid in Harbour, named
rejection here), hk273
(an integer Dyn cell as the DO WHILE condition is Harbour's type-error
dialog - clean named exit 1 here).

No compiler change in this increment: battery coverage over already
justified routes.

- t716: DO WHILE with a Dyn condition (hk270).
- t717 (exit 1): integer Dyn cell as the DO WHILE condition (hk273).
- t718 (exit 1): integer-pinned parameter called with NIL (hk271) -
  locks current behaviour; registers a SEMANTIC DIVERGENCE of a valid
  Harbour program, not a native failure mode (see above).
- t719 (negative): string-pinned parameter called with NIL (hk272) -
  same class: a valid Harbour program this PoC rejects by name.

Sweep 175 re-executed: COMPILES 4, identical to the 63t run.
tests/manifest.txt sha256
b756b30c4b74ee2cbe6f57e720c46195d19c234b69761ec5b4e4b61401dc99f2.

Battery 711 -> 715 + ABI harness green (Linux nativo y Wine con oracle
Linux).

## 63v - `??` operator (QOut without the leading newline)

Oracles first (hbmk2 -gtstd @694428e1, published in sondas/): hk274
(`?? "ab" ?? "cd" ? "ef" ?? 42 ? "gh"` -> "abcd\nef        42\ngh"),
hk275 (comma items join with one space; integers right-aligned in a
10-column field, same as `?`: "a b          1          2\nc d"), hk276
(logicals print .T./.F. unpadded), hk277 (bare `??` prints NOTHING -
no newline, no space). Item evaluation order, separators, field
widths and the trailing right-trim are the `?` QOut rules; `??` skips
ONLY the leading newline. Both oracles and ours byte-identical
(exit 0, Linux native and Wine).

Change: new Tok::QuestionQ; Stmt::Print gains an `inline` flag; codegen
emits `hbc_print_nl` only for `?`. No new runtime helpers, no Dyn
change, no pinning change.

Tests: t720 (hk274), t721 (hk275), t722 (hk276), t723 (hk277).
BATTERY 715 -> 719 + ABI ALL GREEN (Linux native and Wine with Linux
oracle). Sweep re-run: COMPILES 4, identical to 63u. The four sweep
files that failed first on `??` now advance to their next registered
blocker: ains.prg -> inference non-convergence (explicit diagnostic,
cap by design), fileio.prg -> include fileio.ch, fileio2.prg -> fcreate,
procname.prg -> `++` inside expressions.

## 63w - inference monotonicity violation found and fixed (ains.prg)

Diagnosis (main flagged the 63u non-convergence as evidence against the
63n/63o monotonicity claim, not a "by design" cap): HBC_INFER_TRACE
(env-gated round dump, kept in the source) showed function aDump
oscillating I64 <-> DArr every round. Root cause: when pin_params
FAILED (the recursive call `aDump( aShow[ n ] )` conflicts with the
DArr pin - array parameters are not in this increment), the Err arm
reset the entry to i64 placeholders, RETREATING down the lattice; the
next round re-pinned DArr, the conflict recurred, and the round cap
fired as an internal error.

Fix: on pin failure the entry carries the PREVIOUS view types forward
instead of resetting to placeholders. The table never retreats; the
conflict is stable across rounds, the round converges, and the
converged round reports the named rejection (body-first contract
unchanged). No cap increase. ains.prg is still rejected - it uses
features this PoC does not have (AClone/AIns/ADel, array parameters) -
but now fails CONVERGENTLY on its first real blocker
(`unknown function aclone`, line 12) instead of an internal error.
ains.prg is a valid Harbour program; the rejection is a registered
limitation, not a native-invalid verdict.

Tests: t724 (neg): minimal recursion oscillation repro
(`p(a): ? len(a); p(a[1])`) converges to the named rejection.
BATTERY 719 -> 720 + ABI ALL GREEN (Linux native and Wine with Linux
oracle). Sweep re-run: COMPILES 4; ains.prg now reports `aclone`.

Also this increment: float oracles hk278-hk281 measured and published
(pre-design, option A): print field width = 11 + decimals shown;
literals keep written decimals (100.0 -> "100.0", 0.12 = .12);
division floor is 2 decimals (10/3 -> "3.33", 9.0/2 -> "4.50");
0.1+0.2 = 0.3 is .F. (binary double semantics); hex literals print
as plain integers (0xABAB -> 43947).

## 63x - float phase 1: literals, locals, printing + hex literals (5/175)

FIFTH original upstream file: nums.prg compiles and runs BYTE-IDENTICAL
to the Harbour Linux oracle, exit 0, on Linux native AND on Wine
(oracle from Linux; oracles hk278-hk284 measured pre-design, published
in sondas/; helper + plan + standalone driver in design/f64/).

Scope (phase 1 only): float literals (incl. `.12` and `0x` hex integers),
LOCAL storage, `?`/`??` printing, copies and reassignment. A float local
is TWO dynamic slots: the f64 value and its decimal metadata; assignment
replaces both (a := 1.50 then a := .123 reprints with the new precision).
Everything else is a named compile-time rejection: float arithmetic,
comparisons, conditions, call arguments, array elements, for bounds,
returns (t729-t734 negs; t733 closed a silently-accepted `return 1.5`
hole found during this increment's own audit).

Print semantics (hbc_print_f64, both runtime blobs): sign by bit (-0.0
prints "0.0", hk282); normalize to mantissa [1,10) tracking e;
N = round(m * 1e15) (16 significant digits, carry at 1e16); integer
digits e+1 or "0"; fraction zero-padded to the written decimal count;
field width 11 + decimals, growing for long integer parts. Labels
honest: "16 significant digits" is OBSERVED in probes, not proven
universal; the half-up tie at digit 16 has no direct oracle; the
Harbour `*` overflow display near 1e16 (hk284) is unmeasured, so
literals are frontier-rejected: |x| >= 1e15 or nonzero |x| < 1e-17 is
a named compile error (t732/t734), a coverage limit on valid Harbour,
not an invalidity verdict. Zero IS admitted: the check is
a >= 1e15 || (a != 0.0 && a < 1e-17), so 0.0 prints normally.
Direct ABI canary (tests/abi_harness.sh, 63x): hbc_print_f64 is called
with the value in xmm0 and the written decimals in rdi, with sentinels
in xmm6-xmm15 and rbx/r12-r15 plus stack balance and 16-alignment
checks around the call, on BOTH targets (linux native and wine); the
printed field is also compared byte-exact in the harness stdout.

ABI: the helper touches only xmm0-xmm2 (volatile on both ABIs), saves
r12-r15, and makes one aligned call (hbc_print_str). Tests t725-t728
(byte-exact vs hk278/hk281/hk282/hk283) + t729-t734 negs.
BATTERY 720 -> 730 runner rows (63x: 453 pos + 45 posx + 232 neg; one manifest row = one executed test, 730 unique files, no duplicate IDs, no multi-expectation files; the +10 delta is exactly t725-t734, nothing removed or rewritten) + ABI ALL GREEN (Linux native and Wine with Linux
oracle). Sweep: COMPILES 5 (nums.prg joins hello, statfun, lnlenli2,
calling); ains.prg still converges to its named `aclone` blocker.

## 63y - star-rule mapping and measured (int,dec) frontier (733 rows)

Star overflow mapped with hk285-hk288 (published in sondas/). Harbour's
`*` overflow is a value-dependent artifact of hb_itemStrBuf's
digit-extraction loop (sequential modf*10 with a +0.01 fudge; a rounding
carry that runs off the left edge of the field stars it): measured stars
at (int,dec) = (14,2) (10,6) (11,5) (12,4) (13,3) (10,7) (15,1)
(16,1-all-nines), measured printing at (14,1) (12,3) (11,4) (10,5)
(9,7) (8,8) (5,11) (3,13) (9,6) (16,1) (17,1). The artifact zone is
rejected, not imitated. Frontier is no longer |x| < 1e15: admitted is
|x| < 1 with dec <= 17, or int+dec <= 15 with int <= 14, or int <= 9
with int+dec = 16, or int <= 2 with int+dec = 17; nonzero |x| >= 1e-17;
dec <= 17. Zero admitted.

KNOWN DIVERGENCE CLASS — RETRACTED IN 63z (wrong attribution): the
leading-9-chain family (9.999999999999999 -> 10.000000000000000 etc.)
was blamed on Harbour's digit-EXTRACTION and parked as t735/t739 neg
"until the helper is rewritten". The 63z oracle review (hk289) proved
the cause is Harbour's literal PARSER, not its printer: see the 63z
section. The textual 9-chain guard added here was removed in 63z. Non-chain 16/17-sig literals
print fine and stay admitted (t740: 1.0000000000000001, 9999999999.99999,
99999999999.9999, 999999999999.999, 999999999.999999).
The (int,dec) magnitude frontier above is likewise a probe hypothesis
validated only at the measured points, not a universal guarantee.
BATTERY 730 -> 736 runner rows (456 pos + 45 posx + 235 neg).

## 63z - float literal parse: Harbour digit accumulation, not correct rounding (739 rows)

Root cause of the 63y "rounding-fidelity" family found and fixed, with
the attribution corrected by oracle + source review, not by hypothesis.
Harbour's compiler parses a float literal by accumulating its digits in
an int64 while they fit and dividing the total ONCE by 10^decimals
(hb_str2number, fPCode branch): `9.999999999999999` accumulates to
9999999999999999, whose nearest f64 is exactly 1e16, so the literal IS
10.0 and prints "10.000000000000000" (hk285, re-confirmed in hk289).
Correct rounding (strtod, Rust parse) gives 9.9999999999999982 instead
and prints "...999999999999998". The 43-case helper driver had encoded
the correctly-rounded bits, so the sequential helper was blamed for a
divergence that lived in the oracle translation: with the bits Harbour
actually computes, the PUBLISHED helper passes the driver 43/43 under
Wine unchanged, and a bit-faithful Python simulation of the documented
C algorithm also goes 43/43 against the same oracles.

Fix: new `harbour_parse_f64` in src/hbc.rs implements the accumulation
semantics (own code written against oracles; Harbour is
GPL+runtime-exception, no code copied) and BOTH parse sites use it —
admission (parser) and constant emission (codegen) — so the value and
its metadata travel together. The textual 9-chain guard (63y) is
removed: the parse semantics carry it. The i64 overflow fallback of
Harbour's parser is unreachable from admitted literals, by lexer/frontier
rules rather than hypothesis: dec <= 17 (lexer) plus the frontier rules
bound accumulated digits at 18 (the "0." + 17-decimals case, worst
999999999999999999 < i64::MAX); reaching the switchover threshold
(~9.2e17) needs a 19th accumulated digit, which no admitted rule can
produce. Boundary measured with real cases (hk290, published):
0.00000000000000001 prints "0.00000000000000001" (t742),
0.9999999999999999 -> "1.0000000000000000" (t742), 12345678901234.5 at
the int+dec = 15 edge (t742); 18 written decimals stay a named lexer
rejection (t743 neg; Harbour prints 0.000000000000000009 — coverage
limit, not invalidity) and int+dec = 18 stays frontier-rejected (Harbour
prints 10.00000000000000000 there — same named limit).

Tests: t735/t739 flipped neg -> pos with their oracle outputs
(10.000000000000000, 1000.0000000000000); t741 covers copy-to-local
with metadata, unary minus, and same-value-different-writing
(0.10000000000000001 and 1.0000000000000001, oracle hk289). Sondas
hk289/hk290 published in sondas/ with hbmk2 -gtstd captures.
BATTERY 736 -> 739 runner rows (459 pos + 45 posx + 235 neg) + ABI ALL
GREEN (Linux native and Wine with Linux oracle). Sweep: COMPILES 5
(hello, statfun, lnlenli2, calling, nums; nums byte-exact).

## 63za - integer division is Harbour's double division (744 rows)

Harbour has no integer division. The compiler folds constant int
division at parse (expropt2.c hb_compExprReduceDiv; oracle hk291):
exact int/int folds to LONG (10/2 prints "5", 84/2/3 keeps printing
"14"), non-exact folds to DOUBLE with dec = current SET DECIMALS (the
folded bDec = HB_DEFAULT_DECIMALS defers to the runtime setting, fixed
at 2 in this PoC: 10/4 -> "2.50", 1/3 -> "0.33"). A zero divisor is
never folded (runtime EG_ZERODIV); i64::MIN / -1 cannot fold without
overflow and takes the runtime path. Unary minus folds onto integer
literals at parse so Harbour's fold survives through division (-8/2 ->
"-4", -7/2 -> "-3.50").

With any non-literal operand the VM always divides as doubles:
hb_vmDivide stores hb_itemPutND((double)n1/(double)n2) with dec = SET
DECIMALS (oracle hk292: variable 10/2 prints "5.00", not "5"; 10/3 ->
"3.33"). Codegen converts both i64 operands with cvtsi2sd and divides
with divsd - no idiv, so no SIGFPE exists (Harbour's VM also divides
as doubles; oracle hk293: -9223372036854775807-1 over -1 prints
" 9223372036854776000.00", byte-exact in t745). A runtime zero divisor
raises a controlled error ("Error: division by zero", exit 1, both
targets; t746 posx). Harbour raises EG_ZERODIV there (hvm.c
hb_vmDivide); established from source plus probe hk294 (capture and
exit state preserved in sondas_ac/hkeys/): hb_errRT_BASE_Subst returns
no substitute under the default headless handler, hb_vmDivide leaves
the result item untouched (the `?` printed the stale slot contents,
"0", rc 0) - our clean error exit is the registered failure-mode
difference for the same error condition, not an emulation of that
headless artifact.

Width metadata now travels with every float value: the 16-byte F64
slot is (value bits, length<<8 | dec). Literals carry Harbour's
HB_DEFAULT_WIDTH (10); a runtime division result carries length 20
when |d| > 9999999999.0, else 10 (hb_itemPutND + HB_DBL_LENGTH,
hbdefs.h:570; oracle hk293's 23-wide 2^63 line). The print helper's
integer part past 16 significant digits emitted bytes past the digit
buffer (real bug, found by the 2^63 case): positions beyond the 16
extracted digits are now the trailing zeros Harbour prints. ABI
harness canary updated to the packed metadata input; big-output cases
run on Linux and Wine (t745).

Scope lines drawn by name: `set decimals` is a compile-time rejection
(t747 neg; oracle hk295 shows Harbour honoring `set decimals to 4`
with 10/3 -> "3.3333" - SET DECIMALS is fixed at the Harbour default
2 here). Division with a NIL-able (Dyn) operand is a named rejection
(t748 neg): a Dyn payload extracts to i64 in this PoC, so dividing it
would silently truncate valid Harbour (10/3 -> 3 instead of 3.33);
admitted once Dyn can carry F64 payloads. Float +,-,* on values,
mixed int/float operands, float returns, float parameters and float
comparisons keep their existing named rejections (phase 2 continues).

Tests: t744 (fold: hk291/hk293 cases byte-exact), t745 (runtime:
hk292/hk293 cases byte-exact), t746 (posx, controlled div0), t747/t748
(neg). Sondas hk291-hk295 published in sondas/ with hbmk2 -gtstd
captures. BATTERY 739 -> 744 runner rows + ABI ALL GREEN (Linux native
and Wine with Linux oracle). Sweep: COMPILES 5 (hello, statfun,
lnlenli2, calling, nums; nums re-verified byte-exact after the printer
metadata change).

## 63zb - Harbour's asymmetric length rule for float results (745 rows)

HB_DBL_LENGTH (hbdefs.h:570) is NOT symmetric: a runtime double gets
length 20 when d > 9999999999.0 OR d < -999999999.0 (ten times less
magnitude on the negative side), else 10. 63za used the symmetric
|d| > 9999999999.0: `? -2000000000 / 1` padded to 13 where Harbour
pads to 23 (oracle hk297). Folded constants resolve bWidth 255 to the
same value-driven length, so `? 9223372036854775807 / 3` pads to 23
(oracle hk298) - 63za printed it unpadded. Both fixed: the runtime
division path tests the two Harbour thresholds, and FloatV folds
compute the length from the folded value. Written-literal width stays
10: Harbour's compiler width-from-text rule (max(10, intdigits+sign))
is observably identical to 10 under our admitted frontier (proved by
case split on intdigits+sign vs 10). Oracles hk296 (mixed VM ops,
comparisons, dec-34 mult, double-zero divide), hk297 (asymmetric
thresholds), hk298 (fold lengths/decs) captured and published.
t749 (fold + runtime length cases) byte-exact. BATTERY 744 -> 745
runner rows + ABI ALL GREEN. Sweep: COMPILES 5, all byte-exact
(hello, statfun, lnlenli2, calling, nums re-verified against hbmk2
with this HEAD).

## 63zc - Float arithmetic on values (+,-,*,/) and comparisons (753 rows)

Increment 2 of phase 2: `+`, `-`, `*`, `/` on float values (literals,
locals, mixed with integers) and float comparisons, all against
hbmk2-captured oracles BEFORE implementation (hk296-hk301b).

Semantics (Harbour source + oracles): operands are doubles; integer
operands convert with cvtsi2sd like the VM's (double)n reads (hk300:
9007199254740993 = 9007199254740992.0 is .T.). dec metadata: max for
+,-, sum for *, SET DECIMALS = 2 for /. Result length is the asymmetric
HB_DBL_LENGTH (63zb). Compile-time fold matches expropt2.c: LONG x LONG
exact folds to LONG (on i64 overflow to a dec-0 DOUBLE); any DOUBLE
operand folds to DOUBLE with dec max(+,-) / sum(*) / 2 (/); a zero
divisor is never folded (runtime EG_ZERODIV path, clean exit 1 - the
registered headless difference, hk294/hk296). Packed metadata moved to
(length<<16)|dec (dec is Harbour's HB_USHORT); ABI canary now 655361.

Printing (hk301/hk301b, captured this increment): Harbour ROUNDS the
16-significant-digit image half-up (half-away from zero; the sign is
handled separately) at the dec boundary: 0.125/1 -> 0.13, 0.665/1 ->
0.67 (the double is 0.66499...; the 16-digit image carries the tie),
9.995/1 -> 10.00 (carry grows the integer part), 0.0999/1 -> 0.10
(carry through the leading fraction zeros), -0.125/1 -> -0.13. The
printer previously truncated at dec. A dec-0 double prints no dot.

Non-finite values (hk299): inf and NaN fill the whole field with '*'
(iSize = length + 1 + dec, no padding; NaN keeps length 10 - it fails
both asymmetric length tests). NaN compares like Harbour's C operators
(hk300/hk299/t756): .F. for =,==,<,<=,>,>= and .T. for #, operands in
both orders; inf = inf is .T.; -0.0 = 0 is .T. and -0.0 < 0.0 is .F.

Bounded frontier: the print scratch holds 456 bytes (padding + digits,
or the star fill); beyond it (pathological dec chains, e.g. 450
multiplications) a clean named exit 1 prints "Error: float field out
of range" (t757). Harbour grows its buffer dynamically; this is a
registered limit, not equivalence.

Covered LIMITS (named rejections, valid Harbour programs): arithmetic
or comparison between a Dyn (NIL-able) value and a float - Harbour
runs these when the Dyn holds a number, but this PoC's Dyn has no
float payload tag; rejected by name instead of silently truncating
(t729 family moved here). Float mixed with strings/logicals/arrays is
a Harbour type error and stays a compile-time rejection. Float params,
returns and Dyn promotion remain named rejections of previous
increments.

Tests: t729 rewritten (float+string type error), t750 (mixed arith,
hk296), t751 (comparisons, hk300), t752 (fold vs runtime same value +
negatives), t753 (rounding, hk301/hk301b), t754 (inf/NaN stars,
hk299), t755 (asymmetric length at runtime, hk297), t756 (NaN/inf
comparisons both orders + -0.0), t757 (bounded-field exit). Sondas
hk299/hk300/hk301/hk301b published. BATTERY 745 -> 753 runner rows +
ABI ALL GREEN (Linux native and Wine with Linux oracle). Sweep:
COMPILES 5, all byte-exact (hello, statfun, lnlenli2, calling, nums).
Note: the 170 rejected sweep files keep their named rejections; their
first-error wording drifts as the compiler evolves (the frozen
docs/sweep175.csv records the original wording), which does not affect
the COMPILES contract.
63zd - F64 parameters and returns (scalar-copy model, no new RC):

Float arguments and returns are now native across function boundaries
(oracles hk302-hk318; t758-t776). Declared internal convention, same
on both targets: an F64 argument is a 16-byte stack slot (value bits +
packed metadata (length<<16)|dec, like every argument); an F64 return
is xmm0 = value + rdi = packed metadata, preserved across epilogue
frees (t772: StrOwn local freed while the F64 pair lives). Int
arguments convert to F64 at the call boundary (cvtsi2sd, dec 0;
length by the literal text rule - 10+ written digits add one, hk307 -
or the asymmetric computed rule). The same parameter may receive ints
and floats across callsites (Harbour polymorphism, hk303/hk306): the
arg evidence (arg_ev) is monotone-sticky and convergence waits on it,
which covers forward references (t774/hk316) and cyclic inference
with recursion (t775/hk317). Non-numeric arguments never promote
silently (t776 named rejection). Mixed int/float returns of one
function stay a named rejection (t767/hk312: the bytes diverge when
the result feeds arithmetic). Print-only params still pin Dyn, and a
float argument at that boundary is the covered Dyn<->F64 limit
(t768 named rejection: no bits are passed as a float-less Dyn).

Compute-time metadata guard (main 15:49): the '*' runtime sums dec
and rejects >435 (456 field - 20 max length - 1) via
hbc_f64range_error before any silent u16 wrap; the compile-time fold
defers (None) sums >255 so the runtime guard is the only dec producer
that can reach the bound (t769 demonstrates the fold->runtime
handoff). The guard uses call/label form - a bare jump reaches the
helper without a return address and Wine's ExitProcess faults
(caught by t757 on Wine). t757's expectation lost its leading
newline: the same named limit now fires at compute time, before the
print. t733 (63zc neg "bare F64 return") became the feature itself
and flipped to pos (oracle hk318; the file keeps its historical
name).

Known divergences, documented not modeled: Harbour's QOut wraps
output fields at 80 columns (hk309 original, q(q(lit16)) dec-256
field) - this PoC prints the full field unwrapped; the sonda is kept
verbatim and the dec-64 variant is explicit as hk309b (t765 mirrors
hk309b). On a 450-multiply variable chain (hk315) Harbour prints a
~7200-dec field wrapped at 80 columns; this PoC exits 1 with the
named range error (t771) - registered limit, not equivalence.

Tests: t758-t766 (pos mirrors hk302-hk310/hk309b), t767 (neg mixed
return), t768 (neg Dyn-float boundary), t769-t771 (posx dec overflow:
literal chain, call chain, variable chain), t772 (F64 return +
StrOwn epilogue), t773 (mixed signature string+float, hk314), t774
(forward reference), t775 (cyclic inference), t776 (neg non-numeric
promotion). Sondas hk302-hk318 (incl. hk309b) published. BATTERY 753
-> 772 runner rows + ABI ALL GREEN (Linux native and Wine with Linux
oracle). Sweep: COMPILES unchanged at 5, all byte-exact re-verified
this increment (hello, statfun, lnlenli2, calling, nums); the
frozen-csv wording drift policy from 63zc is unchanged.

63ze - preprocessor WARNINGLEVEL, lazy iif, comparison-valued call
arguments, FOR variable reuse, byref string parameters. Oracles
hk319-hk324 captured first on pinned hbmk2 -gtstd; sondas published.

- __pragma( WARNINGLEVEL ) evaluates to 0 in the preprocessor (oracle
  hk320: hbmk2 defaults to warning level 0 without -w). Scope of the
  claim: it is the only __pragma selector observed in the INSPECTED
  corpus (the core .ch headers shipped in harbour-core, hbclass.ch:118)
  - not a global Harbour statement. The interaction of a SET-level
  warning pragma with this fixed evaluation is unmodeled; other
  selectors keep a named rejection. The 24 sweep files whose #if stage
  blocked on it now advance to their real next rejection (#command
  match markers and the class RTL - parked, needs new architecture).
- Call arguments parse at or_expr level: comparisons and logicals are
  first-class Bool values (hk198) and legal in argument position
  (oracle hk322: p( x == 5 ), (x==5) .and. (x>0)).
- iif() is a lazy builtin (oracle hk321: the dead branch's side
  effects never run). The checker intercepts it (3 arguments, Bool
  condition, scalar branch unification with F64 absorbing I64 through
  the 63zd boundary conversion); codegen emits a conditional jump over
  the false arm. Every Call-named pass has its own intercept.
- FOR reuses a visible integer variable instead of erroring (oracle
  hk323 = stock exit.prg: the outer x counts and stays readable after
  the loop). A read-only or non-integer slot keeps a named rejection
  (t783/t784 pin it; Harbour allows both, so they are registered
  limits, not equivalence).
- Byref string parameters: assigning a string to a parameter pins it
  Str (StrOwn through pin_vars), and the existing byref remap turns it
  into RefStrOwn at codegen; the caller's literal-initialised local
  was already promoted to an owned slot when its address escapes
  (63zd layout rule). Dyn evidence still dominates: a NIL-compared
  parameter stays Dyn and absorbs the string pin (t659/t662 hold).
  Oracle hk324 = stock passref.prg, byte-exact.

Tests: t777 (hk323 mirror), t778 (hk324 mirror), t779/t780 (hk320 /
hk319 pragma), t781 (hk322 cmp-in-args), t782 (hk321 iif laziness),
t783/t784 (negs pinning the FOR reuse limits). t39 flipped neg->pos:
its "no shadow" rejection was wrong Harbour semantics (hk323). Sondas
hk319-hk324 published. BATTERY 772 -> 780 runner rows + ABI ALL GREEN
(Linux native and Wine with Linux oracle). Sweep: COMPILES 5 -> 7,
exit.prg and passref.prg flipped and are byte-exact against hbmk2
-gtstd runs (verified this increment); hello, statfun, lnlenli2,
calling, nums unchanged. Frozen-csv wording drift policy unchanged.

63zf (local, unpublished at session cut) - computed integer print field.
Oracles hk325-hk328 captured first on pinned hbmk2 -gtstd.

- Harbour carries three numeric item kinds with distinct `?` fields:
  HB_IT_INTEGER (value within -999999999..9999999999 -> field 10),
  HB_IT_LONG (integer outside that ASYMMETRIC range -> field 20), and
  HB_IT_DOUBLE (a non-negative literal written with ten or more digits,
  hb_str2number -> the 63zd float rules with literal provenance width).
  Harbour's compiler also constant-folds pure integer expressions, and
  the folded value prints with literal provenance (hk326).
- This PoC printed computed positives as max(10, digits+1): an
  accumulated integer past 9999999999 came out 15 wide, Harbour 20
  (found by the bench_int speed probe, not by a test). Fix: new runtime
  entry hbc_print_i64c in both blobs (10 within the asymmetric range,
  else 20; one digit-count test covers both signs); the Print codegen
  constant-folds pure +,-,* literal trees (fold_int) and keeps the
  literal helper for foldable items; Dyn numeric payloads now route to
  the computed helper (they are runtime values by construction).
- Known divergence, documented not modeled: a VARIABLE initialised
  from a ten-or-more-digit literal carries double provenance in Harbour
  (hk327's b/c/d print digits+1); this PoC types the local I64 and
  prints it with the computed rule. Rejecting the init regressed
  t142/t751 (which never print the value), so it is a named
  divergence, not a rejection; a provenance-tracking prepass is the
  candidate fix, not landed.

Tests: t785-t787 (pos mirrors hk325/hk326/hk328), t789/t790 (iif
owned strings), extended ABI harness. BATTERY 780 -> 785 runner rows +
ABI ALL GREEN (Linux native and Wine with Linux oracle).
Sweep: COMPILES unchanged at 7, all byte-exact re-verified after the
helper change.

KNOWNFAIL (registered divergence, not hidden): sonda hk327 verbatim -
a local initialised from a ten-or-more-digit literal (b := 5000000000,
c := 10000000000, d := 50000005000000) is a DOUBLE item in Harbour and
prints with literal provenance width: expected (hbmk2) " 5000000000"
(11), " 10000000000" (12), " 50000005000000" (15); this PoC types the
local I64 and prints the computed field: "5000000000" (10),
"         10000000000" (20), "     50000005000000" (20). Arithmetic,
comparisons, array bounds and non-print uses agree (t142/t751 hold);
only the print field differs. A provenance-tracking prepass is the
candidate fix, deliberately not landed in this increment.

iif owned-string unification (63zf, oracle hk329): branches Str/StrOwn
in any mix unify to OWNED - a borrowed arm is cloned on its own taken
path only, an owned-variable arm moves on its own taken path only (the
source slot is nulled there, so the epilogue never double-frees), and
laziness keeps single ownership (t789 mirrors hk329 byte-exact; t790
proves the ownership model through hb_memcheck: the live local counts
1 until it moves, 0 after; hb_memcheck is this PoC's instrumentation,
not a Harbour function, so t790's expectation is model-derived like the
t659 family, not an hbmk2 oracle). Harbour's iif is actually
VARIANT-typed (hk330: valtype(iif(.t.,"s",1)) = "C"): mixed-kind
branches stay a named rejection here and valtype-over-iif keeps its
own named rejection - no Dyn payload variant is enabled by this
increment.

ABI canary for the new entry (direct, both targets): tests/
abi_harness.sh now calls hbc_print_i64c with a small positive, both
sides of the 9999999999 threshold, both sides of the -999999999
threshold and a tag-0 Dyn payload through hbc_print_dyn; canaries,
16-alignment and stack balance are checked around every call, and the
printed fields are part of the byte-exact expected stdout on Linux
native AND under Wine (not only end-to-end).

Speed (frozen protocol: native Linux both sides, pinned hbmk2 -gtstd,
output byte-compare gate, 15 runs after warmup, median; libharbour.so
load time included in Harbour's cost; HarbourRust compiler built with
rustc -O, generated asm unoptimised - loop present in bench_int.s):
bench_int (10M integer accumulation, byte-identical): hbmk2 837.8ms
median vs HarbourRust 33.7ms = 24.9x. bench_float (2M float
accumulation, byte-identical): 233.3ms vs 15.5ms = 15.1x. Startup-
dominated trivial programs (hello/nums/statfun): ~5x, labelled as
startup, not engine. These are two concrete programs, not an engine
claim. Bench sources are sondas/bench_int.prg and sondas/bench_float.prg
(raw loops, no elimination: the add and the Lforc label are present in
the emitted .s). Toolchain record: hbc sha256
e1a9de1df483f990df0f26049b4e294ec4f81859ee442d3ec5011bd1d1322e88,
rustc 1.99.1 (58cf8f9c3 2026-10-13) via rustup, hbmk2 from the pinned harbour-core
checkout (3.2.1dev r2026-10-24 21:11), flags -gtstd -o<name>; machine: this sandbox (x86_64, Intel Xeon
2.60GHz). Benched binary hashes (the exact artifacts timed):
hb_bench_int 58f90a0f3e95360952e9e9dead792613e2c3e814a31284b5cd8a0542c35eaa89,
hr_bench_int 8cfa302088c2fa27a1e62ac9c1e4c18f2bb8ac21aaa3d1101ad7b6c709044914,
hb_bench_float dec41ec16aa42c2f387162c9afe34ed431121692711270295e93213204221b70,
hr_bench_float 7d5544fb8a85078599f79960b2adaaa916e19fbffcf285c7b2d06c49bbd2e08e.
Method: one warmup run, then 15 timed runs per binary, wall clock
around the whole process, medians reported with mean and min; the two
sides were timed back to back on the same idle sandbox. Provenance
note: the per-run raw arrays were not persisted before the sandbox
moved on; median/mean/min above come from the frozen-protocol run
(post-fix, byte-identical outputs) and are the values of record - not
re-timed ritually.

63zg - ELSEIF. Oracle hk335 captured first on pinned hbmk2 -gtstd;
sonda published. ELSEIF tokenizes as a keyword and the IF arm folds a
run of arms into Harbour's exact nested-IF shape behind the optional
ELSE body (t791 mirrors hk335 byte-exact; a top-level `elseif` keeps
a named rejection). Stock ifelse.prg advances from the elseif gap to
its real next rejection: `LOCAL i` (bare, NIL-typed) reused as the FOR
variable - Harbour retypes the slot, this PoC's reuse covers I64 slots
only; a sound retype needs a mention-clean prepass shared by checker
and layout, parked in the design notes rather than half-landed.
linecont.prg is NOT a flip candidate: stock Harbour itself rejects its
deliberate negative halves (E0030 at lines 53/58, oracle hk334 build
log); the mid-line `;` separator it also exercises stays unimplemented
with the rest of the `;` bucket.

Tests: t791. BATTERY 785 -> 786 runner rows + ABI ALL GREEN (Linux
native and Wine with Linux oracle). Sweep: COMPILES unchanged at 7;
ifelse.prg's rejection advanced (line 19 -> line 8) with the frozen
csv untouched per policy. Reconciliation with the documented syntax
surface: the DO CASE named rejection text (see the identifier-led
statements batch) already told users to `use if/elseif/else/endif`
while ELSEIF itself did not compile - so ELSEIF was a real gap in a
surface the docs implied, corrected in this batch, not a brand-new
form.

63zh - bare LOCAL as FOR counter (lands the prepass 63zg parked).
Oracles first: hk336 (bare `local i`, `for i := 1 to 3`, body prints
and after-loop value; natural exit leaves the counter one step past
the bound - byte-exact), hk337 (nested `for i` reusing the same
visible counter: Harbour runs the inner loop to completion, leaves i
at 3, and the outer loop ends after one iteration - byte-exact), and
hk339 (stock fornext.prg, 337 bytes of real output - byte-exact).
Rule: a bare `local i` (equivalently `local i := NIL`) whose FIRST
mention in the same block is the counter of a top-level
`for i := start to end`, with start/end free of `i`, types the slot
i64 from declaration. One pure predicate
(bare_local_is_for_counter, same-block, mention-clean at any depth)
feeds checker, layout and codegen so the three cannot disagree.
Covered limits, not Harbour rules: any read, write, call argument or
nested use of the name between the LOCAL and the FOR, a start/end
expression mentioning it, or a `@i` byref alias keeps the Dyn slot
and the named `for` rejection (t793/t794/t795); a later Dyn
assignment to the counter is a named type-mismatch rejection (the
counter stays i64 in this increment). t783's nested same-counter
case is now defined behaviour (hk337) and its manifest row flips
neg -> pos; the filename keeps its historical id. Control-flow
notes: EXIT/LOOP between LOCAL and FOR do not mention the variable
and stay eligible; prior assignments, prints, calls, array/hash
writes and nested mentions all disqualify. Exit value matches native
(counter one step past the bound; EXIT leaves the current value).

Tests: t792 (hk336 mirror), t793-t795 (named rejections), t783 row
flip. BATTERY 786 -> 790 runner rows + ABI ALL GREEN (Linux native
and Wine with Linux oracle).
63zi - `%` modulus and `$` containment operators. Oracles first
(hk340-hk349), then the Harbour source for the two rules the oracles
could not pin alone: hb_vmModulus (src/vm/hvm.c) stores EVERY runtime
result with hb_itemPutND - a double with dec = SET DECIMALS ("Clipper
always returns modulus with the SET number of decimal places"; hk348
shows variable int%int printing 1.00 at width 13) - while
hb_compExprReduceMod (src/common/expropt2.c) folds literal int%int
with a nonzero divisor to a LONG with dec 0 (hk340 prints 1 at width
10). A zero divisor, literal or variable, substitutes integer 0
(hk343/hk344: image "0" at width 10). Float modulus emits x87 fprem
with the C2 retry loop; integer operands convert with cvtsi2sd like
every numeric read. The fold's float form carries dec 2 (measured
width 13 = length 10 + dec 2 + 1, the same print-width formula as
every computed double, hk347). i64::MIN % -1 is UB in Harbour's own
C (the fold defers; this PoC's runtime path yields 0.00) -
unmeasured frontier, registered. Dyn payloads extract to i64 exactly
like +,-,* (NIL payload -> clean type error; Harbour's dialog is the
registered difference). `$` is string-in-string only: case-sensitive
byte scan, an empty or longer-than-haystack needle is .F. (hk341);
emitted as a leaf inline scan at the compare site - no helper
symbol, no ABI surface, no canary needed. Array membership `$`
keeps a named rejection (t803). No i64 codegen path exists for `%`:
the checker types every runtime `%` F64, so the i64 Bin channel
never sees it.

Tests: t796-t800 pos (mirrors of hk340/hk348/hk345/hk341/hk349),
t801-t803 neg. BATTERY 790 -> 798 runner rows + ABI ALL GREEN
(Linux native and Wine with Linux oracle). Sweep: 9 COMPILES
unchanged - no file flips, but str/keywords/vmasort/funcarr advance
past their %/$ error to the next gap (`^` power, `;` mid-line, SET
commands).
63zj - power operator `^` and its alias `**`. Oracles first
(hk350-hk356) plus the Harbour source: hb_vmPower (src/vm/hvm.c) is
hb_itemPutND(pow(base, exp)) - ALWAYS a double with dec = SET
DECIMALS ("Clipper always returns the result of power with the SET
number of decimal places") - and hb_compExprReducePower
(src/common/expropt2.c) folds literal^literal to a DOUBLE too (bDec =
HB_DEFAULT_DECIMALS -> SET), so unlike `%` there is no
integer-preserving case (hk350: 2^3 prints 8.00). The parser
precedence is measured, not assumed: unary minus binds TIGHTER than
`^` (hk351: -2^2 = 4.00, -2^3 = -8.00) and `^` is LEFT-associative
(hk353: 2^3^2 = 64.00). `**` lexes as the same token (hk356).
Measured numeric domain: exp == 0 -> 1 (0^0 = 1); base 0 with exp >
0 -> 0, with exp < 0 -> +Inf (hk355: 23 stars = length 20); base < 0
with a non-integer exponent -> NaN, with an integer exponent -> the
sign comes from its oddness; NaN operands propagate. Non-finite
results print stars through the pre-existing shared rule (NaN at
length 10 = 13 wide, +Inf at 20 = 23 wide); no new printer code.
Runtime emission is an inline x87 fyl2x/frndint/f2xm1/fscale core -
no helper symbol, no ABI surface, no canary needed.

Registered divergence and precision LIMITS (not equivalences):
- The constant fold computes libm powf while the runtime emits the
  x87 core: two DIFFERENT routes. Their agreement is oracle-verified
  on the measured cases only (hk350-hk356 byte-EXACT); general
  bit-equality of the two routes is NOT proven or claimed.
- pow(-0.0, negative exponent) yields +Inf here where C gives -Inf
  for odd integer exponents (unmeasured frontier).
- |exp| > 2^63 saturates to an even integer via cvttsd2si (the sign
  rule for negative bases is wrong in that zone; unmeasured).
- Non-numeric operands are a named rejection (EG_ARG 1088 wording;
  t811/t812). Dyn payloads extract to i64 exactly like `%`.

Tests: t804-t810 pos (mirrors of hk350-hk356), t811-t812 neg.
BATTERY 798 -> 807 runner rows + ABI ALL GREEN (Linux native and
Wine with Linux oracle). Sweep: 9 COMPILES unchanged - no flips;
str.prg advances past `^` (line 37) to the identifier-led-statement
gap (line 6) and funcarr.prg past `^` (line 44) to line 13.
63zk - SET-command gate corrected by measurement, no new runtime
semantics. Classifying the real forms behind the ten sweep files the
old gate stopped: six (dates2/dates3/directry/extend1/say/vmasort)
were `Set( _SET_DATEFORMAT, ... )` FUNCTION-CALL statements
misclassified as SET commands (the gate fired on the identifier
`set` without checking for `(`); four (dev/longdev/output/rdd) are
real SET commands bound to subsystems this PoC does not have - SET
PRINTER/DEVICE/ALTERNATE/MARGIN (output routing), SET EXCLUSIVE (RDD
layer) - plus SET CENTURY in say.prg (date subsystem). The gate now
fires only when `set` is not followed by `(`; a `Set(...)` call
falls through to the ordinary call-statement path and meets the
honest unknown-function rejection (the Set() function itself belongs
to the parked SET-state/date subsystems). The real SET commands keep
a named rejection whose message now enumerates the measured forms and
their subsystems: a no-op accept would route output to the wrong
place silently, which is worse than a named limit. SET DECIMALS
stays fixed at the Harbour default 2 (oracle hk295).

Tests: t813 (Set() call statement reaches unknown-function, not the
SET gate), t814/t815 (SET CENTURY / SET PRINTER keep the named
rejection). BATTERY 807 -> 810 runner rows + ABI ALL GREEN (Linux
native and Wine with Linux oracle). Sweep: 9 COMPILES unchanged; all
six misclassified files advance to their real next gap - dates2 to
`hb_stod` (line 3), dates3 to `set` (7), directry to NIL-`==` (62),
extend1 to identifier-led (39), say to identifier-led (7), vmasort
to DO CASE (63) - while dev/longdev/output/rdd keep the improved
named rejection.
63zl - line continuation `;` corrected by fresh oracles
(hk357-hk368). The preprocessor already joined a trailing `;`
outside strings/comments, but an old probe (b39c, lost to a sandbox
wipe) claimed even a COMMENT after the `;` blocked the join. Fresh
measurement on the pinned hbmk2 says the opposite: hk362 (`; //
comment`) and hk367 (`; /* block */`, even a MULTI-LINE block
comment with code after its close) JOIN, while hk368 confirms an INCOMPLETE
expression before a statement separator is a Harbour E0030 syntax error
(64bb adds complete same-line statements). The guard is removed;
comments are stripped before the check, so a stripped line ending in
`;` had only whitespace/comments after it by construction. Measured
rules preserved: tokens never merge across the break (hk363: `ab;` +
`c` is NOT `abc`); a blank next line ends the statement (hk359); `;`
inside a string does not continue (hk360 unterminated-string);
trailing `;` after a complete statement continues into the next line
and errors there (hk366). t622 flips neg -> pos: it locked the old
probe's wrong behavior; its new expected output is hk362's measured
one (`\n         3`), same maneuver as the t783 flip in 63zh.

Tests: t816-t819 pos (mirrors of hk357/hk362/hk367/hk364), t820-t822
neg (incomplete expression before `;`, unterminated string, no token merge), t622 row
flip. BATTERY 810 -> 817 runner rows + ABI ALL GREEN (Linux native
and Wine with Linux oracle). Sweep: 9 COMPILES unchanged;
keywords.prg - a NEGATIVE original (Harbour itself rejects it:
E0013/E0020/E0046) - advances from line 138 (`;`) to line 761 (`&`
macro), 623 lines deeper, both sides still rejecting.



 Sweep: ifelse.prg and fornext.prg flip
to COMPILES, both byte-exact against stock Harbour oracles (hk333,
hk339) - 9 runtime-success originals. Negative originals stay a
separate class (linecont.prg: stock Harbour E0030 at lines 53/58,
oracle hk334 build log; rejected by both compilers is equivalence,
not a runtime success). The frozen 175-file csv denominator counts
original files, not programs that must run; unchanged per policy.

## 63zm - DO CASE statement; named rejection of the `&` macro operator

Oracles (pinned hbmk2 -gtstd, sondas hk374-hk376 in `sondas/`): DO CASE runs the
FIRST matching CASE only - no fall-through (hk374, where the `x == 2` arm runs
its two statements and the `x == 3` arm never runs); OTHERWISE runs when no CASE
matched (hk374/hk375); a bare `end` closes the construct as well as `endcase`
(hk375); with no match and no OTHERWISE nothing runs and control continues after
the construct (hk375); nesting works (hk376).

Implementation: `do case` desugars at parse time into the nested `Stmt::If`
chain that ELSEIF already produces (63zg), so the checker and both codegens are
untouched. Inside a nested body, statement-initial `case` / `otherwise` /
`endcase` / `end` are terminator lines that hand control back to the enclosing
`do case` loop; an assignment to a same-named variable stays a statement (the
NOTE precedent). Named rejections: `` `do case` takes no expression ``,
`` `case` takes a condition ``, `` `otherwise` takes no expression ``,
`` `endcase` takes no expression ``, `` `do case` without `endcase` ``.

The `&` macro operator is now a NAMED rejection instead of a generic
"character not allowed". Measured semantics (oracles hk369-hk373): in Harbour
`&` evaluates string contents as Harbour code at RUNTIME with real types
(`"10"` yields N, `valtype` says N), works in expression, statement and
dynamic-send positions, and the expanded text cannot see LOCALs of the caller
(BASE/1003 semantics). That is Harbour's runtime macro-compiler: an evaluator
embedded in the emitted binary. It is out of this native increment by design -
a named limit, not a Harbour error. All six uses in the 175-file sweep
(base2:9, ddate:27, hrb:41, codebl2:14, omacro:17, keywords:761) are dynamic
evaluation on variables, so they stay parked on this limit.

Tests: t823-t825 positive (hk374-hk376 mirrors), t826/t827 negative (DO CASE
forms), t828 negative (named `&` rejection). The old t666 negative lock-in
("DO CASE is not in this increment") is superseded by the feature: its
program is natively valid, so the row flips neg -> pos as t666_do_case.hb
against fresh oracle hk377 (output `\none`), the same maneuver as t622 in
63zl and t783 in 63zh. Battery: 823 rows + ABI canary.

## 63zn - bare `return` inside blocks

Oracles (pinned hbmk2 -gtstd, sondas hk378-hk381 in `sondas/`): a BARE
`return` is Harbour-valid inside any block and returns NIL - inside an `if`
(hk378), a `do while` body (hk380) and a `do case` arm (hk381); a valued
early return keeps its value (hk379, `return x * 10` prints 20). The old
named rejection ("an early `return` inside a block needs a value") was a
false rejection of valid Harbour syntax.

Implementation: one parser line - the bare form now maps to the same
`Stmt::Ret(None)` the closing top-level bare return already used, so both
codegens and the single-epilogue cleanup path are untouched (the checker
already propagated Ret(None) through If/While/For/ForEach bodies - v2c).
No new symbols; no ABI change. Explicit limit: a function whose returns
mix NIL and a value keeps the existing Dyn tagging; nothing here widens
the type model.

Tests: t829-t832 positive (hk378-hk381 mirrors). The old t33 negative
lock-in is superseded: its program is natively valid (oracle hk382, rc=0
empty output), so the row flips neg -> pos in place - same maneuver as
t666 in 63zm. Battery: 827 rows + ABI.

## 63zo - QOut statement

Oracle hk383 (pinned hbmk2 -gtstd, in `sondas/`): on this build QOut is
BYTE-IDENTICAL to `?` - leading newline per call, space-separated items,
numbers width-padded, `QOut()` prints a blank line. It desugars in the
parser to the existing `Stmt::Print(..., false)`; checker, both codegens
and the ABI are untouched. Named limit: expression-position QOut (it
returns NIL in Harbour) stays on the unknown-function path.

Effect: comments.prg (a natively-valid original) compiles and runs
byte-exact against stock Harbour on Linux. Sweep 11 -> 12 COMPILES.

Tests: t833 positive (hk383 mirror). Battery: 828 rows + ABI.

## 63zp - Round()

Oracles hk384/hk386 (pinned hbmk2 -gtstd, in `sondas/`): half away from zero
(1.5 -> 2, -2.5 -> -3); the binary-representation traps round UP
(1.005 -> 1.01, 2.675 -> 2.68, 1.335 -> 1.34); result dec = max(d, 0)
(3 -> 3.000 with d=3; 123.456 -> 120 with d=-1; zero-padding to d=10);
runtime variable dec works. Source-grounded transcription of hb_numRound
(src/common/hbstr.c): exact pow10 table for |d| <= 15, +/- 5 by sign,
HB_DBLFL_PREC_FACTOR = 1.0000000000000002 ulp lift (hbdefs.h:665, ACTIVE in
the pinned build - proven by 1.005 -> 1.01), trunc toward zero, back-scale.

Implementation: new runtime helper hbc_round (both targets) returning the
63zd f64 pair convention, plus hbc_round_range_error for runtime |d| > 15
(Harbour switches to pow(10,d) there - parked, named). Checker: numeric
first argument (else named rejection, Harbour's EG_ARG), integer dec
argument (hb_parni conversion is a named limit), literal |d| > 15 rejected
by name. `round`/`round_range_error` reserved as helper symbols. No Dyn
widening: the type model is untouched.

round.prg itself does NOT flip: its `value := -5` then `value += 0.001`
evolves a local from integer to double across loop iterations (the first
column prints "-5" then "-4.999" in Harbour). That mixed-evolution local is
the Dyn-hoja model parked to the user - the sweep error advances from
unknown function `round` (line 10) to the named type-mismatch (line 11).

Tests: t834/t835 positive (hk384/hk386 mirrors), t836/t837 negative.
Battery: 832 rows + ABI. New symbols get ABI canaries: hbc_round covered
by tests/abi_harness.sh (63zp iteration).

Runtime dec route (63zp addendum): `round` accepts a non-literal dec
(t835: `local d := 2`, byte-exact vs hk386). The hbc_round helper guards
BOTH signs before touching the pow10 table: `cmp $15,%rdi; jg` and
`cmp $-15,%rdi; jl` jump to hbc_round_range_error (linux + windows),
which prints "Error: round dec out of range" and exits 1. The table is
never indexed out of range and no out-of-range dec is silently computed.
Harbour itself falls back to pow(10,d) beyond +/-15 (hb_numPow10,
src/common/hbstr.c:400) - that zone stays a registered limit, same as
the compile-time literal rejection (t837). Runtime guards: t838 (d:=16),
t839 (d:=-16), both exit 1 with the named message on both targets.

round.prg verification (63zp addendum): the `value` local is declared
`value := -5` (integer) and then `value += 0.001` promotes it to double
inside the FOR loop - in Harbour it is one variant changing type across
iterations. That is exactly the Dyn-hoja model (order-dependent dynamic
local), not a static-typing gap the pinned-scalar representation can
absorb: hoisting the declaration to F64 would change the typing rule
itself (order-independent inference) and alter the first column's
integer-format print. So the line-11 named mismatch stays the documented
limit; it is a model boundary, not a pending user approval.

## 63zr - Native source callstack on controlled errors

Each generated function (including @ variants) and Eval block now links a
32-byte diagnostic record inside its native stack frame. It holds the prior
record and the current source location. Common returns unlink it without
clobbering scalar, string/array or float-pair return registers. There is no
HVM, evaluator, heap allocation, fixed-depth array or OS unwinder. Location
updates use scratch r11. WHILE/FOR EACH retests restore the header location.

The preprocessor records one original path/line per emitted line, preserving
include origins and the FIRST line of semicolon continuations. Parser and
checker line numbering is unchanged; only runtime diagnostics use this map.
Blocks report their definition location (not an expression column). Caller
frames keep the active call statement. Each controlled error still prints
its original message and exits 1, now followed by Callstack: and youngest-
first source frames. Normal runs emit no trace. All existing exit-1 terminal
sequences converge on hbc_panic_exit after printing the error; it realigns
rsp before hbc_print_trace. No internal runtime helpers are shown as .prg
functions. Text is a HarbourRust diagnostic, NOT Harbour dialog bytecompat.

Reference oracle hk388: Harbour ProcName/ProcLine reports LEAF line 2,
MIDDLE call-site 7, MAIN call-site 10. Our error probes are intentionally
headless controlled failures rather than a claimed replica of that dialog.

Tests t840-t848 cover nested calls, recursion, Eval + definition line,
include/directive/continuation origins, completed/early returns, byref
variants, WHILE + LOOP retest, nested expressions after a callee returns,
and block unlink. Existing 52 posx tests keep their previous output as an
exact prefix and add a hand-inspected diagnostic suffix. No successful
program expectation changed. Direct hbc_print_trace ABI canary covers an
empty chain, nonvolatile registers and stack balance (both targets).
Battery: 843 runner rows + ABI = 844, ALL GREEN Linux and Wine. Sweep
63zr identical to 63zq: 12/175. No additional original claimed.

Limits: controlled runtime errors only. No signal/SEH handler for arbitrary
SIGSEGV, access violation, integer CPU traps or OS stack exhaustion. No
thread-local chain for future threads or async callbacks. Codeblocks show
their definition line; continued expressions use the first statement line.
Source paths are embedded as supplied to the compiler (may be absolute).

Paired speed check, same sondas/bench_int.prg (10M additions) and
bench_float.prg (2M float additions), same output across Harbour and both
HarbourRust builds, Linux process wall time median of 7 interleaved runs:
integer before/trace/Harbour = 0.034172/0.026987/0.852758 seconds;
float before/trace/Harbour = 0.015791/0.015554/0.241109 seconds.
Includes process startup; short microbench and layout/noise sensitive.
Not an isolated engine speed claim and not proof that diagnostics improve
speed. Normal binaries pay location-store/frame overhead even without an
error; workload-specific cost needs measurement before extrapolation.

## 63zs - Chr()

Oracle hk387 and upstream src/rtl/chrasc.c:53 (byte-codepage branch) show
Chr(n) returns one byte, n &255, even for NUL or multiples of256. hk389
measures truncation of numeric fractions but this increment deliberately
rejects float arguments by name; no numeric-conversion model added.
Codepage Unicode selection is not implemented. hk390 is the exact output
oracle for t849: negative/wrapped bytes, runtime integer, arithmetic,
NUL length/equality and concatenation without displaying NUL directly.

hbc_chr uses existing owned-string header, hbc_strcpy and hbc_freestr.
No new representation, sharing or interpreter. Parameters used in Chr pin
to integer. Return values own their allocation; normal move/drop paths
apply. Len now frees an owned non-variable temporary after reading its
length (previously it leaked such an expression). t850 exercises returned
strings, reassignment, discarded Len temporaries and concatenation, then
checks hb_MemCheck()=0 AFTER the owned local's function has returned.
Direct hbc_chr ABI canary validates byte, length, header, nonvolatile
GPR/XMM sentinels and matching free on Linux and Windows via Wine.

Limits: floats/Dyn/non-numeric arguments rejected; no Unicode-codepage
mode. gtstd replaces NUL with a visible dot while HarbourRust print_str
writes raw bytes. That output difference is not hidden or called byte-
compatible. NUL semantics are checked using equality/length, not its
visible rendering. No Asc/LTrim/RTrim/AllTrim implemented by this change.

63zs checkpoint battery:848 runner rows+ABI=849 ALL GREEN on Linux and Wine.
Sweep:12/175 unchanged; test.prg advances from unknown chr on line3 to
unknown ltrim on line8. No original added to the executable count.
63zs and 63zt are delivered together; final battery is853rows+ABI=854.

## 63zt - Trim family (includes 63zs)

Oracles hk391/hk392 and src/rtl/trim.c / include/hbdefs.h HB_ISSPACE:
LTrim drops leading bytes9,10,13,32 only (NOT11/12); RTrim/Trim drop
trailing32 only; AllTrim combines those rules. Empty/all-space strings
stay valid; NUL/160 and interior bytes are preserved. One string argument
only; extra arguments/non-strings rejected by name, not silently ignored.

hbc_trim computes a borrowed range then tail-calls hbc_strcpy to produce
an independent owned result under existing string layout. Source is not
moved by these builtins; temporary owned arguments are freed after copying.
Ordinary user-defined calls still MOVE string parameters as documented;
t856 does not mistake clean(s) for a borrowing builtin. No aliasing model
or shared ownership added. t854/t855 mirror Harbour bytes; t856 covers
source preservation, nested temporaries, return through a function,
reassignment, empty outputs and memcheck0 after function cleanup. Direct
ABI canary covers helper+free on both targets.

Final combined battery853rows+ABI=854 ALL GREEN Linux/Wine. Sweep remains12/175;
test.prg advances from LTrim unknown at8 to FOR EACH over a string at18,
a representation boundary of existing iteration, not a completed original.
NUL print difference from63zs remains; not claimed bytecompatible output.
Combined change is based on30fe54808ec4f45a7364077a2ad75391cda87865 (63zr).


## 63zu - Asc first byte

Based on 2b148ad8354f61762c5b1a7948c2cbd6e5d71cd1. hk393 and
src/rtl/chrasc.c establish unsigned first-byte Asc(string): empty/NUL=0,
128/255 stay unsigned, later bytes ignored. Byte-codepage only, no Unicode
selection. hk394 measures Harbour error1107 for non-string inputs; here a
named static type rejection. Wrong arity is rejected by both compilers.

hbc_asc borrows ptr/len, returns an integer, and never reads empty input.
No new representation or allocation. Codegen frees an owned non-variable
argument exactly once after preserving the result. String variables remain
usable; ordinary user-function calls retain existing MOVE semantics.
t859 matches hk393 bytes; t860 covers nested Chr/Trim/IIf temporaries,
function results, repeated cleanup, source preservation and memcheck0 after
function return. t861 covers string parameter inference and function cleanup.
t862-t865 reject numeric/Dyn and wrong arity. The direct helper ABI canary
checks invalid-pointer/zero-length, unsigned255, nonvolatile GPR and XMM6/7
sentinels on Linux and Windows via Wine, plus matching free of test input.

63zu checkpoint battery860 runner rows+ABI=861 ALL GREEN Linux/Wine. Sweep unchanged
12/175; no new original. FOR EACH string and visible-NUL output remain
separate limits, not implemented by Asc.

hk395 microbenchmark:10million Asc(s), checksum2550000000. Seven alternating
paired Linux runs (uninstrumented): Harbour median0.632773s, HarbourRust
median0.033049s, ratio19.15x for this workload only, including process startup.
Both outputs byte-identical. Not an application-wide performance claim and
not a Windows speed measurement. Raw paired samples retained with checkpoint.


## 63zv - QOut/QQOut expression effects (after 63zu)

Asc and this change are published together after their separate checkpoints.
hk396-hk398 measure NIL return, evaluation effects and temporary strings.
QOut(args) emits a leading newline after all arguments evaluate left-to-right;
QQOut(args) omits it. Both reuse the exact Stmt::Print emission via
cg_print_items, including widths, separators, string cleanup and existing
line-end trim behavior. Result is the existing Dyn NIL pair tag1/payload0.
ValType(QOut/QQOut(...)) executes the call and returns U. No new runtime
helper, value model, sharing, output device or interpreter is introduced.

QOut/QQOut can be intermediate codeblock expressions when their NIL is
discarded and the final expression remains integer. A final print call is
rejected under the existing integer-block/Eval return contract. t1.prg
therefore advances from unknown QOut to the named integer-block restriction;
it is NOT a completed original. No fake integer return for a NIL result.
Print-only parameter inference through expression QOut is not expanded;
parameters need existing independent type evidence. Captures stay rejected.

Tests t866-t875 cover NIL/ValType, nested output, argument evaluation order,
float formatting, intermediate block effects, owned string temporaries,
memcheck0 after cleanup, collection borrowing, invalid collection/codeblock
arguments and use-after-MOVE rejections within/after the call. The checker
uses a sequential temporary environment for argument MOVE checks. Existing
print-only statement behavior and formatter limits remain unchanged.
The ABI canary calls generated QQOut() through qprobe and checks NIL pair,
stack/GPR/XMM6/7 preservation on Linux and Windows via Wine.

Combined battery870 runner rows+ABI=871 ALL GREEN Linux/Wine. Sweep12/175;
only t1.prg's first diagnostic changes, with no new compile success.
NUL rendering, output device routing/SET ALTERNATE, all-space trailing
separator edge and final-block NIL results remain named limits.

hk399 benchmark:1million empty QQOut()+NIL checks, seven alternating Linux
pairs, checksum1000000. Harbour median0.054402s, HarbourRust0.003688s,
ratio14.75x for this empty-call workload including startup, not console I/O
throughput or general application speed. Outputs match exactly. Raw samples
retained with checkpoint. No Windows speed claim.

## 63zw - expression print-only parameter evidence and temporary cleanup

Checkpoint based on 771e152. QOut/QQOut expressions now
record the same delayed weak print-only parameter evidence as ?/??. The
whole body is scanned before selecting the existing Dyn fallback: stronger
integer, float or string evidence wins regardless of statement order.
Nested calls and forwarding reuse the current inference pass. There is no
new value representation or interpreter. Copy-only parameter inference,
float-in-Dyn and static-array-to-Dyn boundaries remain named rejections.

The existing StrOwn-to-Dyn call boundary clones a string for the callee.
It now frees an owned input TEMPORARY after that copy; a named owned string
remains valid in its caller. This also fixes an old statement-print-only
case: the unmodified 771e152 compiler leaks two inputs in t883 (memcheck2),
whereas the local compiler returns memcheck0. No aliasing or MOVE rule is
changed, and no allocation is silently shared. Tests cover Chr, empty and
nonempty AllTrim, nested owned inputs and a preserved named source.

hk400-hk404 are byte-identical to Harbour on Linux. t876-t884 add nine
regressions; 879 manifest rows + separate ABI = 880 PASS, Linux and Windows
via Wine. ABI also calls generated dynshow(AllTrim(" ")) and checks its
NIL pair, stack/GPR and XMM sentinels. Sweep stays exactly 12/175 with no
new original or changed first diagnostic. Final-block NIL/Eval, FOR EACH
string, expression ++/-- and output limits from 63zv remain open.

Performance caveat: hk404 performs 1million show("") calls, each using the
existing copied-string Dyn parameter, QQOut and a NIL check. Seven alternating
uninstrumented Linux pairs give Harbour median 0.121516s and HarbourRust
10.904254s: HarbourRust is about 89.7x SLOWER on this workload, including
startup, checksum1000000 on both. This is not console throughput or a
Windows speed claim. The generated boundary copies and frees even an empty string. The
existing statement-print-only control has base median1.185059s versus
local1.137277s for100k calls (five alternating pairs); that does not show a
regression from this change or by itself isolate the cause. This newly compilable program has no old binary to
compare against; an existing statement-print-only boundary control and raw
paired samples are retained beside hk404. No performance fix is claimed.

## 63zx - bounded reuse of freed short-string blocks

Checkpoint after63zw. The unfavorable hk404 samples
from63zw remain intact. An eight-slot cache stores ONLY logically freed
string allocations with capacity <=256, indexed by capacity mod8. Reuse
requires exact capacity equality and removes the entry before returning it
as a fresh uniquely owned string. Miss, collision, occupied slot and >256
use the existing OS allocation/free paths. Capacity/length headers and
caller-to-Dyn copies are unchanged. No live storage is shared, no reference
count or immortal empty-string singleton is introduced. This is a bounded
free-block cache, not a general allocator or threading design. No concurrent
runtime is supported by the current compiler.

Each cache hit re-registers a live allocation and each logical free removes
it; alloc/free counters retain ownership meaning. Cached blocks are not
live leaks: normal _start completion flushes every cached mapping/heap
block, without modifying live-object registry/counters. Controlled error
exit relies on OS process cleanup, as before. At most eight blocks of up to
272requested bytes are retained during execution; Linux mmap rounding can
retain up to eight pages. Large strings and collision-heavy distributions
can still have the old OS cost. No general speed claim.

Tests885-887 cover empty simultaneous live values, named-source preservation,
short-capacity collisions, all eight buckets,256/257boundary and memcheck0.
ABI checks independent simultaneous copies, exact-pointer reuse only after
free, correct headers and bytes, flush preserving a live copy and GPR/stack
preservation. Separate cache_registry.sh, run by the battery, checks logical
balance, cache flush emptiness, and rejection of double-free or wrong-size
free even for cached entries on both Linux and Windows/Wine. No production
helper bypasses the instrumented live-pointer registry.

Same unchanged hk404 source,1million empty Dyn-copy calls+QQOut/NIL checks:
three alternating old/Harbour/candidate Linux triples, uninstrumented,
checksum1000000 and byte-identical outputs. Medians old6.888951s,
Harbour0.101726s,candidate0.137492s: about50.1x faster than old in these
paired runs, still about1.35x slower than Harbour. Earlier seven new
Harbour/candidate pairs give0.097530s/0.136159s. The original unfavorable
10.904254s baseline is retained, not substituted or used as the main
improvement ratio. These include process startup, not general application
speed or Windows speed measurements.

A1k-call strace control goes from1000mmap+1000munmap to1mmap+1munmap
(including normal-exit flush);1003write calls remain unchanged. Silent
Dyn-boundary controls hk405/hk406 improve8/256byte strings. The initial
257byte control is slower(candidate0.084571s vsold0.071420s/10k), so no
improvement is claimed outside the cache and a15-pair recheck is retained.

Long-output probes with Harbour gtstd inserted80-column wrapping absent
from BOTH old and candidate outputs. The failed hk408 long-output source
and all three outputs are retained as evidence; a distinct revised hk408
uses length/equality checks instead, and hk409 checks empty/multiple-live
copies. Those revised probes byte-match Harbour, not retroactive proof of
long-output equivalence. Console wrapping remains a named preexisting limit.

The257byte15-pair recheck medians are old0.071269s/candidate0.066542s,
in contrast to the smaller earlier sample. This is consistent with noise
rather than a stable large regression, but does not demonstrate benefit
for >256. Both complete sample sets are retained. Final checkpoint battery:
882manifest rows + ABI + cache registry harness =884PASS Linux/Wine.
Sweep12/175 unchanged; no syntax or original completion is claimed here.

## 63zy - integer variable prefix/postfix expressions

`x++`, `x--`, `++x`, `--x` now yield the old/new value in expressions,
respectively, for writable integer variables and integer parameters,
including existing by-reference integer calls and integer block parameters.
The lexer recognizes adjacent ++/-- as distinct tokens: `old + ++x` is
not misread as `old++ + x`. Spaced unary-plus remains a named rejection;
`x - -x` remains subtraction of a negation. Prior standalone statements
retain their existing assignment desugaring, not a new overflow policy.

hk410-hk414, hk416-hk417, hk419-hk420 are compiled Harbour -gtstd
byte-exact probes for mutation order, multiargument QOut, arithmetic,
comparisons, modulo/division, lazy IIF and short-circuit logic, WHILE,
LOOP/EXIT, block parameters, ordinary/by-reference parameters and array
assignment order (RHS before index, hk420). Regression rows t672-t674
become positive; their source names are retained for continuity and their
new expectations were checked directly with Harbour, not only the candidate.
New t888-t909 include successful behavior and explicit rejected boundaries.
The generated incprobe has an ABI canary on Linux and Windows/Wine.

This does NOT add arbitrary incrementable lvalues, floating-point/Dyn
increments, block captures or dynamic numeric promotion. Those boundaries
stay named. Harbour promotes signed overflow to double; expressions here
exit with `Limit: increment overflow needs numeric promotion` and native
callstack BEFORE updating the slot. Four max/min prefix/postfix cases
check exit text/status on both targets. An independent test-only overflow
exit in inc_overflow_store.sh verifies the original slot, old result and
wrapped scratch on both targets; it is not a returning runtime ABI claim.

Two experimental probes are retained as failures, not matches. hk415 is
accepted by Harbour but rejected for block capture by HarbourRust.
hk418 reaches a Harbour BASE/1133 array-assignment error, because RHS
mutation changes the index before assignment. Its partial output/error
dialog is retained; the process was timed out, not claimed successful.
Distinct hk419 removes that invalid assignment; hk420 explicitly verifies
valid RHS-before-index mutations byte-exactly. No failed source was silently
replaced or used as an oracle for a positive test.

Frozen175 sweep rises from12 to13 COMPILES: only while.prg is newly
accepted. The original while.prg at harbour/core694428e1c12f726675b19324d62167fa77d68185
is copied UNCHANGED into t907_original_while.hb, SHA256
81542a0a84c8ce27b7205a6c475ed811847b0dd913eac4a19e0f3dc62c40bf57.
All1000 printed numbers match compiled Harbour byte-for-byte on both
Linux and Windows/Wine. The other162 examples remain uncompiled, not
implicitly completed. Full sweep/errors are retained in sondas/sweep175-63zy.csv.

Linux, uninstrumented,9 alternating pairs, same source and exact outputs:
hk414 performs500000 postincrement additions within a nominal1M FOR range
(the expression also updates the FOR counter); checksum250000000000,
finalcounter1000001. Harbour median0.025000677s, HarbourRust0.002790662s,
about8.96x faster in this small case, including process startup. This is
not a universal or Windows speed claim. Unchanged hk4041M Dyn-copy control:
Harbour0.097710643s, HarbourRust0.134169195s, still about1.37x slower.
All pairs, outputs and the prior unfavorable baselines remain available.
Final local checkpoint:904 nonblank manifest rows + ABI + cache registry +
pre-store overflow harness =907 PASS on Linux and Windows/Wine. The manifest
has907 physical lines, including3 blank lines, not907 test cases.


## 63zz - unary plus preserves the operand

Harbour grammar (`src/compiler/harbour.y:932`) discards unary plus without
numeric coercion. The native parser now does the same: +x, + +x, x + +x,
+d, +NIL, +.T., +string, +array, and +(effectful expression) retain the
operand's type, order and ownership. Adjacent ++ remains a separate token;
x+++x is x++ + x (hk423). Parenthesized +x is the same writable lvalue as
x in Harbour (++(+x), (+x)++, hk425). Invalid literal/float increments and
moved string reuse remain rejected; no new mutable lvalue form or Dyn leaf.

hk421 is NOT called an exact match: Harbour accepts the return-only generic
parameter; HarbourRust keeps the preexisting inference rejection. hk422
adds independent arithmetic evidence and matches. hk422-hk425 and converted
t901 byte-match compiled Harbour -gtstd; successful test expectations run
on Linux and Windows/Wine. Seven new rows t910-t916 cover successful and
rejected boundaries. Final checkpoint911 actual manifest rows +3harness
=914 PASS both targets. Frozen175 sweep remains13COMPILES, byte-identical
to63zy, no new original completion.

hk424 uses the same source on both compilers,1M additions with unary plus,
checksum500000500000,finalcounter1000001. Nine alternating uninstrumented
Linux pairs including process startup: Harbour median0.044575464s,
HarbourRust0.003473755s, about12.83x faster
for this workload only. Full pairs and exact output are retained in
sondas/hk424-linux-benchmark.json. No Windows/general performance claim.


## 64aa - parenthesized expression statements

A parenthesized expression can now run as a statement, including the exact
HB_SYMBOL_UNUSED(symbol) expansion ((symbol)) from Harbour std.ch. A bare
variable is type-checked and borrowed, never moved or freed. Calls and
computed expressions retain effects; a discarded owned string/array uses
the existing release discipline. Scalar/Dyn/F64 channels stay distinct;
a float discarded expression uses cg_f64_load instead of the integer path.
The call-statement path now frees a discarded owned tag4 Dyn string when
present, and uses cg_value for literal strings. No ownership representation
change, evaluator or class architecture is introduced.

Probes hk427/hk428/hk430/hk431 byte-match compiled Harbour -gtstd. Coverage
includes variables of scalar/string/array/hash/block types, literal values,
float calls with increment effects, string temporaries, Eval and NIL array
cells, ordinary calls/void statements and mutation-only statements. The
first candidate float-literal panic is fixed by the typed discard path;
that path is exercised on both targets. t925 repeats3000 string-producing
discards under instrumentation and checks zero logical live allocations.
t928 checks tagged Dyn string returns, string-index temporaries and
dynamic-array temporaries leave no logical live allocations.
Invalid temporary hash/block/static-array discard, undefined/moved variables
and existing FOR EACH borrowed-variable restrictions stay named rejections.

Do not overread the macro result: hk426 with the WHOLE std.ch still fails
on unsupported <*x*> preprocessor markers; hk427 uses ONLY the verbatim
macro definition, not an adapted success claimed for the whole header.
hk429 succeeds in Harbour but keeps the FOR EACH escape/read restriction
in HarbourRust. Seven upstream examples advance from generic LParen errors
to `missing )` (still unsupported parenthesized comma expressions).
Frozen175 remains13COMPILES, no new original completion. New t917-t928:
923 actual manifest rows +3harness =926 PASS Linux and Windows/Wine.

hk430:1M parenthesized postincrements, exact checksum1000000 and finalFOR
counter1000001. Nine alternating uninstrumented Linux pairs, startup
included: Harbour median0.027322761s,
HarbourRust0.002888720s, about9.46x faster
for this workload only. Raw pairs/output retained in sondas/hk430-linux-benchmark.json.
No general or Windows speed claim.


## 64ab - numeric/logical parenthesized comma expressions

`(e1, e2, ..., last)` evaluates in order and produces the LAST value. The
native AST/codegen now supports numeric/logical items only (I64/F64/Bool),
with a named rejection for Dyn, strings, arrays and block values in the
list. No assignment expressions, generalized lvalues, evaluator, RC or new
storage model. Ownership effects inside numeric-returning calls still
apply: a consumed string cannot be used later in the list or afterward.
The checker uses a sequential temporary move environment to detect this.

hk433/hk435/hk436/hk438/hk440/hk441/hk442 byte-match compiled Harbour -gtstd.
They cover arithmetic/float channels, comparisons, lazy IIF, short-circuit
logic, WHILE, ordinary/byref parameters, numeric calls consuming a string,
blocks/nested Eval, index expressions and list statements. Earlier effects
are NOT constant-folded away: fold_int records only final numeric print
provenance, so `(x++,12345678901)` retains both the mutation and Harbour's
literal-width output. Float inference follows the final item, not prefixes.
Nested block collection recurses through body expressions; the discovered
missing-label regression is pinned by t948.

hk432 strings/Dyn, hk434 mixed parameter pinning, hk437 unpinned parameter
and hk439 Len-only string expectation remain rejected, not marked exact.
Distinct successful probes and all initial outputs remain in sondas.
New t929-t948 add20 cases:943 actual manifest rows +3harness =946 PASS on
Linux and Windows/Wine. Frozen175 remains13COMPILES. Seven originals move
past comma parsing to their next real type/function/subsystem limits;
no new original completion is claimed.

hk441:1M list statements with two postincrements, exact checksum2000000,
finalFORcounter1000001. Nine alternating uninstrumented Linux pairs,
including startup: Harbour median0.030397646s,
HarbourRust0.002380184s, about12.77x faster
in this workload only. Raw pairs/output in sondas/hk441-linux-benchmark.json;
no universal or Windows performance claim.

## 64ac - sequence move effects reach following sibling expressions

Post-64ab audit found a real ownership bug: the sequence checker rejected
use-after-move INSIDE its temporary environment, but failed to propagate
that environment's moved flags to following sibling expressions. Thus
`(consume(s),1) + Len(s)` could be accepted after consume freed s. No live
sharing or representation change fixes this: the checker must keep the
ownership effect at the enclosing expression boundary. Six lines now OR
the sequence-local moved flags back into the caller's environment. Three
regressions t949-t951 reject the arithmetic sibling, later print argument
and nested-list forms on both targets. This is a correctness repair, not
a claimed Harbour behavior match (Harbour has shared dynamic lifetimes).
946 actual manifest cases +3harness =949 PASS Linux and Windows/Wine.
Sweep stays13/175. No new original completion or speed benefit is claimed;
the previous identical-workload benchmark remains the relevant measurement
because this changes only compile-time ownership analysis, not emitted code.

## 64ad - ownership branch/sibling regression audit after 64ac

No compiler changes in this checkpoint. Twelve tests t952-t963 exercise
sequence moves through IIF conditions/taken arms, arithmetic siblings,
AND/OR siblings, IF joins, loop-back edges, nesting and double consumption.
They confirm the 64ac checker repair covers those tested shapes only, not
a general memory-safety proof. Lazy untaken-arm moves remain conservatively
rejected at the statement join (same static ownership policy, not Harbour
sharing). A positive compiled Harbour probe hk443 checks taken IIF arms,
explicit source reassignment and short-circuit counter effects byte-exactly;
Linux/Wine instrumentation checks balanced frees on that positive path.
All11 negative cases are OURS/MODEL compile-time restrictions, not Harbour
output comparisons. 958 actual manifest cases +3harness =961 PASS on both
targets. Frozen175 remains13COMPILES. No speed change is claimed: compiler
and generated runtime are byte-identical to64ac; the prior identical-source
benchmark remains in the repository. No new original completion.

## 64ae - output-expression move effects reach result siblings

Extending the ownership audit found the same temporary-environment hole
in expression QOut/QQOut: its items were checked in item_env, but effects
were not propagated to the caller's environment. The published d7e4060
accepted `IIF(QQOut((take(s),1)) = NIL, Len(s), 0)` after take consumed s.
The invalid read was not executed. The hole also existed without sequence,
using QQOut(take(s)); it is not only a new comma-expression behavior.
Four lines merge item_env moved flags back into env. Four negative cases
t964-t967 cover IIF sibling, nested output, following print item and the
non-sequence call variant on both targets. No runtime or ownership model
change: only compile-time effect propagation. 962 manifest +3harness =965
PASS Linux and Windows/Wine. Frozen175 stays13COMPILES. No new original
or speed claim; successful hk441 emits byte-identical assembly to64ad.
This audit fixes tested holes, not a general memory-safety proof.

## 64af - checker environment-copy pattern audit

No compiler changes. Reviewed ALL ownership-checker Local environment
copies in current source (not only discovered repros):

- Sequence env.to_vec: sequential effects, merged moved flags (64ac).
- QOut/QQOut item_env.to_vec: item order, merged moved flags (64ae).
- IF then/else env.clone: both branches share the post-condition seed;
  post-branch state ORs moved flags for all outer variables. Conservatively
  includes returning branches; over-rejection is not a lifetime hole.
- WHILE/FOR/FOR EACH env.clone: back-edge move checks, exit move snapshots,
  and post-loop joins include pre/body/exit states. Reassignment restores
  a live owner. FOR EACH restores the borrowed variable's type/ro fields.
- Block benv is constructed only from integer parameters: enclosing captures
  are explicitly rejected. There is no outer owner state to merge.
- Codegen CgLocal clones, prescan name sets and individual Ty clones carry
  no checker ownership flags; they are not alternate Local effect states.

Eight new t968-t975 cases pin IF else joins, WHILE/FOR/FOR EACH exit joins,
LOOP back edges, nested output and rejected captures. Positive hk445 uses
explicit reassignment through IF, FOR, WHILE exit and FOR EACH paths and
byte-matches compiled Harbour -gtstd with instrumentation on both targets.
970 actual manifest cases +3harness =973 PASS Linux and Windows/Wine.
Frozen175 stays13COMPILES. This is a bounded copy/merge-pattern audit, NOT
a claim that all ownership, aliasing or memory-safety bugs are excluded.
hk444 using a static array as the FOR EACH collection exposed a separate
preexisting codegen panic (whole-array value through scalar emitter).
Its source/output are retained as a failed probe, not a match. Distinct
hk445 uses Array(2), the supported dynamic-collection route. The static
FOR EACH panic remains OPEN for follow-up, not hidden by this audit.
No new original or performance claim: source/runtime unchanged from64ae.

## 64ag - fail closed instead of fixed-array FOR EACH compiler panic

The checker previously accepted fixed-size stack arrays as FOR EACH
collections, but native iteration reads tagged heap cells; passing the
fixed-array variable through cg_expr panicked (hk444). This checkpoint
adds a named compile-time rejection before codegen. It does NOT implement
fixed-array iteration or choose copy/sharing/conversion semantics. Dynamic
Array(n), supported array-returning calls, nested collection borrows and
hash paths retain their established behavior. Four new regressions
(t976-t979, including the unchanged failed hk444 source) check a diagnostic,
not a compiler panic, on both targets. Earlier negative tests t899/t926/t971
now use dynamic Array(n) so their original readonly/borrow/move checks stay
reachable; their expected diagnostic was NOT weakened to the new early
rejection. Original probes remain unchanged. 974 actual manifest cases
+3harness =977 PASS Linux and Windows/Wine. Frozen175 remains13COMPILES,
byte-identical to64ab. No new original completion or speed claim: this
changes rejected inputs only, not successful generated code.


## 64ah - bounded expression-shape compile/link matrix

A new standalone harness crosses 25 expression shapes with eight contexts
on Linux and Windows: 400 target checks. Each cell pins success or named
rejection independently, so replacing an accepted shape with a rejection
cannot silently pass. All 196 accepted target cases assemble and link;
204 reject with ordinary compiler diagnostics, not a Rust panic. This
checks integer/float/string/array/hash/block/NIL shapes under expression
statements, print, Len, ValType, IIF, equality, Round and Eval wrappers.
It never executes these synthetic probes: some intentionally contain
uninitialized array elements, moves or invalid runtime operands. Existing
manifest tests remain responsible for runtime semantics and Harbour
oracles. The matrix is a bounded compiler/linker regression, NOT a memory
safety proof, new compatibility or exhaustive compiler-panic audit.
974 actual manifest cases +4 standalone harnesses =978 PASS. The matrix
adds 400 target compile/link checks, NOT 400 runtime test cases. Compiler
and runtime source are byte-identical to64ag, frozen175 stays13COMPILES,
and existing performance measurements are unchanged (no new speed claim).
Python3 is required by this standalone harness.


## 64aj - deterministic parser mutation regression matrix

Nine small syntax seeds receive deletion/duplication of delimiters and
trailing-token mutations. The deduplicated 136 sources run through both
target compiler frontends: 272 checks, 16 accepted and 256 ordinary named
rejections. Every source pins its acceptance independently. Abnormal exit,
timeout, non-diagnostic error and acceptance drift fail the harness.
The 8 accepted sources include original seeds and legal trailing forms;
this is not a claim that every mutation must reject. The generated probes
are never executed, and these counts are not runtime/Harbour equivalence
cases. This is a bounded parser regression, not exhaustive fuzzing or a
compiler safety proof. 974 manifest cases +5 standalone harnesses =979
PASS Linux and Windows/Wine. Compiler/runtime source remains unchanged,
frozen175 remains13COMPILES and no new speed claim is made. Python3 is
already required by the expression-shape harness from64ah.


## 64ak - inline IF alias, empty IIF branches and NIL-only arms

Harbour's IF(condition,a,b) alias now parses to the existing lazy IIF
node in expressions and bare statements. Block IF(condition) retains its
normal path, including nested parenthesized conditions. Empty SECOND or
THIRD inline-IF arguments parse as NIL (harbour.y IfInline/Argument);
the condition is still required. Ordinary calls do not acquire omitted
argument support. Existing lazy scalar/float/owned-string paths are reused.

Only NIL-producing Dyn arms are newly admitted: literal NIL or QOut/QQOut
calls on both sides, with a common existing tag/payload convention. Generic
Dyn variables, array cells or user-call returns stay rejected even when a
particular run might return NIL: this does NOT establish a new owned-Dyn
transfer policy. Numeric/NIL mixed branches stay rejected. QOut side effects
run only in the selected arm; omitted/dead arms produce no output. Existing
move checks and owned-string cleanup remain in force, with consume/later-use
negative tests and2000 discarded owned-string IIFs under hb_memcheck.

The upstream tests/ifinline.prg is copied UNCHANGED as t982, SHA256
cef71077a08117c32e49ec468be7f38a5ca5817aa2a6175136ba4ed5cf3afa08.
Its output matches compiled Harbour -gtstd byte-for-byte on Linux and Wine.
Frozen175 gains ONLY ifinline.prg, from13 to14COMPILES. Seventeen new
manifest regressions t980-t996 produce991 actual cases +5harness =996PASS.
The compile-shape harness intentionally changes ONLY the NIL/NIL IIF cell:
198 accepted target cases now link and202 reject; still400 checks, not
400 runtime cases. Parser matrix272 checks stays unchanged.

hk446/hk447 oracles retain alias/laziness/NIL/float/string coverage. hk448
uses the same unmodified source on Harbour and HarbourRust,1M alternating
inline-IF numeric selections, checksum2000000/finalcounter1000001. Nine
alternating uninstrumented Linux pairs including startup: Harbour median
0.065851097s, HarbourRust0.016498614s, about3.99x
faster for THIS workload only. Raw pairs/output retained. No Windows speed
claim, no general Harbour claim and no comparison to Rust/LLVM performance.


## 64al - literal base-case anchors for recursive inline-IF returns

Stock recursiv.prg has a single RETURN IIF(a<2,1,a*f(a-1)). Its
signature previously stayed void because checking the recursive call
failed before the return type could be learned. The existing signature
fixpoint now accepts a provisional literal scalar anchor from one inline-IF
return: integer, float, logical or borrowed string. This only seeds the
initial signature table. All arms, parameter uses and calls still undergo
the ordinary converged-table check before codegen. Multiple return sites
use the previous inference path; mixed/unknown/owned arms are not guessed.
A recursion with no literal anchor remains a named rejection. No new VM,
representation or runtime mechanism is introduced.

Original recursiv.prg is unchanged as t997, SHA256
48239c4d3d37cc414d4a6fca7ee7ba3c302b7bc210247792a8e83db9de0f8e5f.
Its complete output byte-matches Harbour -gtstd on Linux and Wine. Sweep175
gains ONLY recursiv.prg from14 to15COMPILES. Ten regressions t997-t1006 cover
original factorial, mutual recursion, float/logical/string return channels,
wrong argument and mixed-arm errors, no-anchor limits, and unchanged
multiple-return inference.1001 manifest cases +5harness =1006PASS.

hk449 measures100000 recursive factorial(10) calls from the SAME source
on Harbour and HarbourRust, checksum362880000000/finalcounter100001.
Nine alternating uninstrumented Linux startup-inclusive pairs: Harbour
median0.073611097s, HarbourRust0.007593844s,
about9.69x faster ONLY for this workload.
Raw pairs/output retained. Not Windows/general speed or Rust/LLVM parity.


## 64am - accept #warning at the established default warning level

Harbour accepts #warning and continues compiling. At its default warning
level0 the directive is silent; -w3 emits W0001 with the unexpanded text
(hk451, including case-insensitive spelling and an inactive branch).
HarbourRust already fixes __pragma(WARNINGLEVEL) at0 (hk320), so #warning
now follows that same contract: accept/ignore the payload, never expand
its macros or treat it as source. No -w option or nonzero level is added.
#error and unknown directives remain fatal. This is not full diagnostic
format or configurable-warning compatibility.

Upstream define.prg is unchanged as t1007, SHA256
5f474e3a31544a0c390dda8f0bf461e6e59bfa9593b36310bbf078c31ca23869.
Complete default output byte-matches Harbour -gtstd on Linux and Wine.
Frozen175 gains ONLY define.prg,15 to16COMPILES. Eight new regressions
(t1007-t1014) cover original/defaultlevel, payload inertness, error after
warning, unknown directive, and preserved runtime callstack source line.
Compile-time semantic diagnostics still use the existing flattened line
numbers (t1011 pins line3 after a stripped directive); this checkpoint
does not fix or claim original-source line remapping for all diagnostics.
1009 manifest cases +5harness =1014PASS. Both compile matrices unchanged.
No runtime/codegen change: existing hk449 assembly is byte-identical,
so its retained Harbour/HarbourRust measurement is unchanged, with no new
speed claim for a preprocessing-only change.


## 64an - ProcLine for the current native frame

ProcLine() and ProcLine(0) now return the original source line of the
current statement. Ancestor levels, variable levels, side-effecting level
expressions and extra arguments remain named rejections: this is NOT full
stack introspection. No runtime frame representation is changed. The
current-frame result is emitted as a constant, including native codeblock
source lines. The preprocessor retains a separate final-line map for
ProcLine while preserving the existing FIRST-line origin used by diagnostic
callstacks. Oracle hk453 showed why these maps differ: a semicolon-continued
statement returns its FINAL physical line in Harbour. Includes, stripped
directives, block bodies and nested functions retain their own source map.

Original procline.prg is unchanged as t1015, SHA256
8bdaa18da5476c96b1c76688c013673ccb82049470606fba3367e93c125b5121.
Its complete output matches compiled Harbour -gtstd on Linux and Wine.
Do not repair the original's stale Expected text (8/10/12): actual lines
are3/5/7, and both compilers print the unchanged text. Frozen175 gains ONLY
procline.prg,16 to17COMPILES. Nine regressions t1015-t1023 give1018 manifest
cases +5harness =1023PASS. Prior diagnostic callstack/origin tests remain.

hk455 sums1M current-frame ProcLine calls, SAME source/output,checksum
5000000/finalcounter1000001. Nine alternating Linux startup-inclusive pairs:
Harbour median0.059524770s, HarbourRust0.004037724s,
about14.74x faster for THIS constant-lowered
shape only. This does not measure generic stack inspection, Windows speed,
overall Harbour compatibility or Rust/LLVM parity. Raw pairs/output retained.


## 64ap - default HB_SYMBOL_UNUSED standard macro

The default preprocessor environment now supplies ONLY the exact
HB_SYMBOL_UNUSED(symbol) -> ((symbol)) definition from std.ch:55.
The existing parenthesized statement implementation evaluates expressions
and borrows bare variables; this adds the default macro availability
seen in Harbour without loading the entire unsupported std.ch command set.
#undef and user redefinition still work. No lowercase alias, wildcard
header support, deleted argument effects or unchecked undefined variables
are introduced. hk458 matches Harbour for postfix effects and overriding
this macro with QOut; moved/undefined variables remain rejected.

Original mem.prg is unchanged as t1024, SHA256
1bf2e483a27bedd1cbb93f4b5df5ed896c10b9fe9afa052247e8cf7721ed0078.
It compiles and exits with the same EMPTY output as Harbour on Linux and
Wine. Six new tests t1024-t1029 give1024 manifest cases +5harness=1029PASS.
Frozen175 compilation sweep rises17 to19: mem.prg AND errsys.prg compile.
Do NOT count errsys.prg as a new working/byte-equivalent original: it
intentionally increments an uninitialized NIL to test the Harbour error
system, which this checkpoint does not implement or validate. The new
runtime-verified original here is ONLY mem.prg. Compilation acceptance is
not an original runtime compatibility percentage.
No successful generated code changes for existing sources without this
macro: hk455 assembly byte-identical; retained speed measurements unchanged.


## 64aq - classify original errsys as a registered error-mode case

The default macro from64ap also makes stock errsys.prg compile. This is
not a successful Harbour-equivalent run: the original deliberately applies
n++ to an uninitialized NIL. A bounded3second Harbour -gtstd run shows
Error BASE/1086 Argument error: ++ and an interactive Quit dialog, then
hits timeout124; that is NOT a successful oracle. HarbourRust takes the
existing clean error path, exits1, and prints Type error: NIL used as a
number with main's original line13. The input is now a permanent posx
regression t1030, UNCHANGED original SHA256
1061bef9a0d5ea39694f7d2b25928faa44d3d78a5f05cc6aee3bdb28dc56bb73.
No compiler/runtime source changed. This records the established failure
mode, not a new fix or interactive error-system implementation. Frozen175
stays19COMPILES; only18 under the prior accumulated successful-original
count, plus this explicitly DIFFERENT error-mode original.1025 manifest
cases +5harness=1030PASS Linux and Windows/Wine. No new speed claim.


## 64ar - ordinary double-quoted strings are raw Harbour strings

Oracle hk459 confirms ordinary double-quoted strings preserve backslashes:
paths, literal backslash-n/r/t and doubled backslashes all remain data,
and a backslash before the closing quote does not escape that quote.
The old C-like escape interpretation was a registered divergence; it is
now removed. Escaped e"..." strings remain a separate unsupported syntax,
not silently confused with ordinary strings. Single-quote behavior stays
unchanged. Macro/comment passes already treat ordinary quotes as raw,
so this aligns the lexer with the complete existing quote pipeline.

Four regressions t1031-t1034 cover exact output, quoted macro/comment
markers, final backslash and malformed/unclosed quotes.1029 manifest cases
+5harness=1034PASS Linux and Windows/Wine. Sweep175 remains19COMPILES
(18successful originals +1registered errsys failure-mode). iotcp.prg and
longstr.prg move past quote errors to later unsupported statements/OutStd;
NEITHER is claimed as a newly working original. No runtime helper or
ownership change. Existing hk455 assembly is byte-identical and retained
performance measurements are unchanged, with no new speed claim.


## 64as - OutStd, native hb_eol and unchanged original longstr

OutStd reuses the existing evaluated-item emitter with a raw-output flag:
no leading newline, no right trim, one separator between EVERY argument,
including empty-rendering arrays/hashes. Zero arguments print nothing;
the result is NIL. hk460/hk461 byte-match Harbour -gtstd for scalar values,
trailing spaces, empty values, side-effect order, temporaries, string-array
items, NIL result inspection, discarded block output and lazy IF arms.
Existing QOut/QQOut trimming is unchanged. OutErr/output routing remain
unsupported. Existing codeblock, temporary-array and ownership limits still
apply; this does not add general dynamic argument support.

hb_eol() returns a borrowed constant: LF on Linux, CRLF on Windows, following
Harbour src/rtl/console.c's native platform branch. Arguments are a named
rejection. Direct output calls are now permitted in parenthesized comma
lists (needed by simpleio.ch); only their payload-free NIL is added. Generic
Dyn variables/calls, strings, arrays and blocks remain rejected there.
No new runtime helper, allocation scheme, interpreter or shared storage.
The ABI harness exercises OutStd's NIL pair and hb_eol length under its
nonvolatile-register/stack canaries on both targets.

Original longstr.prg is UNCHANGED as t1041, SHA256
ccc83f05e2f8f0aa89dc2f90807586c9cbf584066a41177dd7457d9f914bbdb1.
Its exact simpleio.ch is copied unchanged into tests. The longstr Linux
output byte-matches a live Harbour oracle. Native Windows hb_eol adds one
CR before the leading LF; internal explicit CR/LF strings stay unchanged.
The new pos2 runner compares separate binary expectation files with cmp,
including all trailing bytes, instead of shell substitution. The Windows
expectation is source-derived from Harbour's CRLF platform branch, not
claimed as a live Windows Harbour oracle. Linux/Wine both exit0 and match
these exact expectations. No normalization of either output is performed.

Seven new cases t1035-t1041 give1036manifest +5harness=1041PASS. Frozen175
compilation sweep rises19 to20; accumulated successful originals19 plus
one explicitly DIFFERENT errsys failure-mode original. Do not call that
20 working originals. longstr2 still stops at OutErr. Existing performance
measurements are retained; hk455 assembly remains unchanged, with no new
speed claim for stream output or platform line endings.


## 64at - OutErr with isolated native stderr rendering

OutErr shares OutStd's checked value shapes and raw formatting: all arguments
evaluate before rendering, one separator per argument, no trim/newline, NIL
result. hk462 compares stdout AND stderr separately with Harbour -gtstd;
the Linux/Wine results match every byte, including trailing spaces, nested
OutStd argument effects, scalar fields, empty arrays/hashes and temporaries.
The streams manifest kind uses file comparisons and checks exit0, keeping
stderr evidence separate instead of merging it or dropping it.

Only the rendering fragment routes to private hbc_eprint_* helpers. Native
stdout helper bodies are reused with destination fd2 on Linux and
STD_ERROR_HANDLE (-12) on Windows. Float local labels get their own
namespace. These helpers are emitted only when stderr rendering is used;
no mutable routing state means nested output/controlled diagnostics do not
inherit a destination. No value representation, ownership rule or shared
storage changed. The ABI harness calls each of str/sep/i64/i64c/dyn/f64
stderr helpers directly under GPR/XMM/stack canaries and compares both
stderr files. OutErr's NIL pair is checked too. Existing I/O error handling
limits remain: no partial-write retry or error result is added.

Original longstr2.prg is now an unchanged negative t1043 (SHA256
 e6988e6f3320bfc5ac75b66f7c8e51c4d2868f03a284dfe439976687f5f0504a):
it passes the missing-function frontier but rejects its use of moved short.
Do not call it a working original or weaken ownership to accept it. t1044
keeps moved use after an OutErr argument rejected. Three new cases give
1039manifest +5harness=1044PASS Linux/Wine. Frozen175 stays20COMPILES,
19 accumulated successful originals plus DIFFERENT errsys failure-mode.
Existing no-OutErr hk455 assembly is byte-identical; no new speed claim.


## 64au - Empty for existing statically known value shapes

hk463/hk464 match Harbour -gtstd for zero/nonzero integer and floating
values (including negative zero), logicals, literal NIL, codeblocks,
strings, fixed/dynamic array variables and hash variables. Empty strings
contain only space, tab, LF or CR; vertical tab, form feed, NUL and 0xA0
are NOT empty. This matches hb_strEmpty/HB_ISSPACE, not a guessed C or
Unicode whitespace class. The emitted byte loop borrows string variables
and frees an owned temporary after reading it. Side effects execute once;
returned numeric/string values and byref effects are covered too.

No new helper or tagged representation. Generic Dyn values, borrowed
nested-array views and temporary arrays/hashes remain named rejections.
Existing moved-value checks apply. This is not a claim to all Harbour
Empty types: dates, timestamps, object/pointer/symbol types and generic
Dyn dispatch remain outside this increment. Arity is exactly one here,
rather than silently discarding extra arguments.

Six new cases t1045-t1050 give1045manifest +5harness=1050PASS Linux/Wine.
Frozen175 remains20COMPILES:19 accumulated successful originals and the
separate errsys failure-mode original. No new complete original is claimed;
procname.prg passes Empty but stops at unsupported ProcName. Existing
hk455 assembly is byte-identical; no new speed claim or general safety
proof follows from these bounded checks.


## 64av - ProcName current frame, including lexical block owner

ProcName()/ProcName(0) return a borrowed compile-time string for the current
function, uppercased like Harbour. A codeblock reports (b) plus the function
where the block was DEFINED, not the function calling Eval; hk465/hk466
measure MAIN/MIXCASE, (b)MAIN/(b)OTHER, nested call output and returned
names. hk467 verifies a byref-specialized function still reports its source
name SPECIAL, without an internal specialization suffix. The existing
integer-result block limit stays: a block can print the name as an
intermediate output argument, but cannot newly return strings through Eval.

No new runtime helper, stack walker or allocation. The codegen context
records the lexical function/block owner without changing diagnostic names.
Ancestor/dynamic levels and side-effecting level arguments remain named
rejections, consistent with ProcLine's current-frame-only limit. This does
NOT complete stock procname.prg: its variable-level loop still rejects.

Five new cases t1051-t1055 give1050manifest +5harness=1055PASS Linux/Wine.
Frozen175 stays20COMPILES (19 accumulated successful originals plus the
separate errsys failure-mode original). hk455 assembly remains byte-identical;
no new speed claim, general stack introspection or Harbour-complete claim.


## 64aw - statement-level indexed assignment with single equals

Harbour permits a[i] = value as a statement, like existing a[i] := value.
The five assignment-token checks now accept single equals for flat/hash,
two-, three-, four-level and comma-index statement lvalues. These become
the SAME checked ArrSet nodes and emitted code as colon-equals. No new
representation, ownership rule, helper or expression assignment is added.

hk468-hk470 match Harbour for array/hash writes, side-effecting indices,
all supported nested spellings and a comparison on the RHS. Single equals
INSIDE expressions remains comparison, including indexed comparisons;
== is never accepted as a statement assignment token. Moved-array checks
remain in force. Five cases t1056-t1060 give1055manifest+5harness=1060PASS
Linux/Wine. Frozen175 stays20COMPILES (19 accumulated successful originals
plus the separate errsys failure-mode original); arrayidx.prg needs
expression compound assignment, which this does NOT add. hk455 assembly
is unchanged; no new speed claim.


## 64ax - generic END closes the innermost supported block

hk471/hk472 confirm Harbour's bare END closes IF, WHILE/DO WHILE,
FOR and FOR EACH, including nesting and ELSEIF/ELSE. DO CASE already
supported END. Five closing-token checks now accept this alias through one
predicate; the parser's existing terminator recognition and identifier
assignment disambiguation stay in place. A local called end can still be
read or assigned. Stray END, an END with payload, and a mismatched NEXT
inside IF remain compile errors. No runtime/type/ownership changes.

Five cases t1061-t1065 give1060manifest+5harness=1065PASS Linux/Wine.
The nested FOR EACH oracle uses a declared iterator and dynamic array,
preserving the existing fixed-stack-array iteration rejection. Frozen175
stays20COMPILES (19 accumulated successful originals plus the separate
errsys failure-mode original); no new complete original is claimed.
hk455 assembly is byte-identical; no new speed claim.


## 64ay - same-type scalar Min/Max with first-item tie metadata

hk473/hk474 match Harbour for pairs of integers, floats or logicals.
Both arguments evaluate once, left to right (including nested/byref calls).
Float selection preserves BOTH the value and its decimal/width metadata;
ties select the FIRST item, as minmax.c specifies. Integer literal-only
selection keeps literal print provenance, including >10-digit values;
runtime results keep the existing computed-integer field convention.
The provenance classifier does not skip evaluation of argument effects.
No helper, tagged return union, allocation or ownership change is added.

Mixed integer/float pairs remain a named rejection: Harbour returns the
actual selected item's type, so blindly converting both sides to float
would change its formatting/type. Dyn, strings, dates and timestamps are
also outside this increment. Exactly two arguments are required here.
Five cases t1066-t1070 give1065manifest+5harness=1070PASS Linux/Wine.
Frozen175 stays20COMPILES (19 accumulated successful originals plus the
separate errsys failure-mode original); no new complete original claimed.
hk455 assembly is unchanged; no new speed claim.


## 64az - integer hb_bitAnd/Or/Xor/Not

hk475/hk476 match Harbour for 64-bit signed integer bit operations,
variadic And/Or/Xor (at least two arguments), unary Not, negative values,
large values, double Not and nested/effectful calls. Argument order is
left to right, once per argument, including byref mutations. Bit patterns
use native x86-64 AND/OR/XOR/NOT; no shift-range semantics are inferred.
Literal-only results retain literal integer print provenance; runtime
results retain the existing computed field width. Provenance classification
does not remove effects from generated evaluation.

Float/Dyn conversions are a named rejection, not a guessed truncation.
Not requires exactly one argument here. No runtime helper, representation,
allocation or ownership change. Five cases t1071-t1075 give1070manifest
+5harness=1075PASS Linux/Wine. Frozen175 stays20COMPILES (19 accumulated
successful originals plus the separate errsys failure-mode original).
No new complete original is claimed. hk455 assembly stays byte-identical;
no new speed claim.


## 64ba - hb_bitTest/Set/Reset with literal 0..63 indices

hk477 matches Harbour for integer bit tests and set/reset operations,
including bit63/sign bit, negative inputs, byref effects and literal versus
runtime print provenance. Test returns logical; Set/Reset return integer.
Native BT/BTS/BTR operate on the existing 64-bit value. The first argument
evaluates once; the index is a required literal in this bounded increment.
No helper, allocation, representation or ownership change.

Dynamic, negative and >=64 indices remain named rejections; no C undefined
shift behavior or machine masking is assumed as Harbour semantics. Float
values are rejected too. Exactly two arguments are required, rather than
silently ignoring extras as Harbour's current hbbit.c does. Shift is still
unsupported. Five cases t1076-t1080 give1075manifest+5harness=1080PASS
Linux/Wine. Frozen175 stays20COMPILES (19 accumulated successful originals
plus the separate errsys failure-mode original). No new complete original
or speed claim. Existing hk455 assembly remains byte-identical.


### 64bb: semicolon-separated statements (hk478-hk482)

Complete statements may share a physical line with an unquoted `;` between
statements. Each source statement matches preprocessor commands separately;
expanded macro/command results may also contain statement separators. Ordinary
single/double quoted strings keep embedded semicolons as data. Physical trailing
semicolons still join the next physical line before statement splitting.
ProcLine retains the physical line, including the final line of a continuation.

The old hk368/t112/t820 probes have an incomplete expression before the separator;
they remain rejected, now with an incomplete-expression diagnostic rather than a
blanket rejection of the separator. t03 remains rejected for trailing expression
tokens. Unbalanced expressions remain errors. A complete statement followed by a final
semicolon at EOF is accepted, as measured by hk482.
This does not add bracket strings, escape strings, new storage or runtime helpers.

Six new manifest cases (t1081-t1086), checked against Harbour hk478-hk482, bring
the full Linux/Wine battery to 1081 manifest cases plus five harness checks.
The frozen 175-original sweep stays at 20 COMPILES, including errsys's separately
registered different failure mode; no new original execution success is claimed.
The hk455 no-feature assembly is unchanged; no new timing claim is made.

### 64bc: the date type, part 1 - Date(), CToD(+), comparisons and Empty

hk483-hk485 match compiled Harbour for the first date slice: a DOUBLE
Ty::Date scalar whose 8-byte payload is the Harbour julian long (the
FLIEGEL/Van-Flandern encode and decode formulas, hb_date.c) with the
EMPTY date pinned to payload 0. DATE() returns today through the
runtime utc-clock path on Linux (clock_gettime) and GetLocalTime on
Windows; a local-TZ loader is a registered limit. CToD ports
hb_dateUnformatRaw over the default MM/DD/YY format: digit runs per
field with one-or-more non-digit separators (the third separator stops
the parse), and a year value below 100 maps +1900 through
hb_setUpdateEpoch at default SET EPOCH 1900 (leading zeros irrelevant,
set.c:1130, measured through Year()); anything else - m>12, day>month
limit, bogus leading garbage, a 5-digit year, February 29 on a
non-leap year - encodes the EMPTY date, which renders `  /  /  ` (8
bytes, 6 at a QOut line end, probe d7). Real dates render mm/dd/yy.

Comparisons run the julian payload through the existing integer
COMPARE machinery; mixed date/number or date/mail comparisons are
Harbour's BASE/1071 argument error (headless hang, hk485) - a
compile-time named rejection here. Date arithmetic (date +/- integer,
date - date) is measured (d1) but parked for the NEXT date increment.
Date params and date-in-hash/tag-5-Dyn surfaces stay outside this
increment: an uninferable date parameter is the named
"cannot infer the type of parameter" rejection, and a date argument
into a Dyn parameter names "must be a dynamic value, got a date"
(t1092). CTO() rejects non-strings by name; date() rejects any
argument count. ValType(date)=D and Empty(date) are HK-STYLE POSITIVE
cases (Empty is the payload==0 test, hk483).

Runtime helpers hbc_date_encode/hbc_ctod/hbc_today/hbc_print_date land
in both blobs; a manual code-page Windows-4-byte -vs- 8-byte STACK
STORE mismatch in hbc_date_encode's scratch slots (the upper dword of
every 32-bit store stayed stack-garbage under Wine: the 4th call
returned 2^32+payload) is FIXED to 64-bit stores after a hand probe;
the 4-per-call probe now returns the same payload four times (mp8).

11 manifest cases (t1087-t1093) and 8 named rejections
(t1094-t1102, including t1092's date-parameter pin limit) bring the
full battery to 1100 manifest cases plus five harness checks: ALL
GREEN on Linux x86-64 and Wine 10.20. The frozen 175-original sweep
stays at 20 COMPILES (sondas/sweep175-64bc.csv). hk483/hk484
.byte-match compiled Harbour on both targets. No speed claim; hk455
assembly is unchanged.
