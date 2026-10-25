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
