# NIL as a true tag (v2c repair) - design, as built

Supersedes the i64::MIN sentinel (published at cd8cf17, declared an
experimental regression: it collided with a valid integer and evaluated
NIL-held-in-a-variable operations numerically). The representation
uses a separate tag/payload pair: a real tag, no reserved integer, no
hardcoding to print/compare paths only. Oracles: probes n1, n2, n3
(+ e1 grown slots) against compiled Harbour (`hbmk2 -gtstd`).

## One representation: the tagged union `Ty::Dyn` (16 bytes)

`{tag, payload}`: tag 1 = NIL (payload 0), tag 0 = an i64 payload.
Registers: rax = tag, rdx = payload. Stack slots and array elements
store the pair (tag word first). Pure i64 code keeps its efficient
8-byte path; only the routes that can hold NIL widen.

Widening is decided per variable by `prescan_dyn` (a fixpoint over the
function body): seeds are NIL-literal assignments, reads `a[i]` /
`a[i][j]` of dynamic arrays, calls returning Dyn, and parameters
pinned Dyn; it propagates through assignments (`x := y`). A widened
local gets the 16-byte slot in BOTH the layout pass and codegen
(layout_locals and cg_stmts apply the same rule; an i64 initializer
is tagged in as {0, v}).

Parameters: the pin pass widens a parameter used numerically in one
place and as NIL in another (I64 + Dyn -> Dyn; Str + Dyn stays a
compile error). Comparing against a NIL literal pins Dyn; `x := NIL`
pins Dyn; when the function has any bare/nil return, returned
parameter expressions pin Dyn (mixed return).

Returns: `unify_ret` unifies the returns of one function (I64 + Dyn ->
Dyn). `return nil` / bare `return` emit the NIL pair; a value return
in a Dyn function tags the expression. An early `return nil` inside a
block is an ordinary value return since this repair (n2 order-
independence: nil branch first or last, t217/t219). `main` stays
void (its return value is unused).

## Array elements

Dynamic array elements are tagged pairs (element size 16): reads are
Dyn, writes tag an i64 in as {0, v} and copy a Dyn pair. `ASize`
grows a flat dynamic array with NIL {1, 0} (probe e1); a DArr2 grows
with the empty (null, 0) child (m-probes) - the hbc_asize deep flag
selects the fill. Fixed-size arrays stay tagless [i64; N] (Rust
model; t222 pins i64::MIN exactness there). Inserted subarrays
(AAdd(a, b)) still MOVE the child (16-byte child slots, unchanged
ownership rules).

## Runtime helpers (both targets: Linux syscalls, Windows kernel32)

- `hbc_print_dyn`: tag 1 prints "NIL" with no field width (probe n1);
  tag 0 prints the payload via hbc_print_i64.
- `hbc_dyn_to_i64`: extracts the payload; tag 1 is a Harbour type
  error (arithmetic/ordering/indexing on NIL) - Harbour raises its
  interactive dialog (not probeable headless), so the PoC prints
  "Type error: NIL used as a number" and exits 1. Registered
  failure-mode difference, same error condition - like hbc_bound_error,
  NOT a compat success.
- `hbc_dyn_eq`: NIL = NIL is .T.; NIL against a payload is .F.;
  two payloads compare numerically (probes n1-n3).

## Comparisons and effects

- Dyn vs Dyn / Dyn vs i64, `=` / `#`: tag dispatch via hbc_dyn_eq.
- Ordering with a Dyn side: both sides extract via hbc_dyn_to_i64
  (NIL raises the registered type error at runtime).
- Dyn vs string: `=` folds to .F., `#` to .T. (probe n1) - but BOTH
  operands still evaluate left to right; only the comparison is
  folded, so calls and their effects run (t223).
- A NIL LITERAL in an ordering comparison stays a compile error
  (t212); ordering a NIL held in a variable is the runtime type
  error (t220).

## Tests

- Unchanged expectations: t35/t104/t165 (oracle behaviour, not
  representation), t208-t210, t212.
- Rewritten: t211 (was sentinel-era, not oracle-backed: its `p + 0`
  on NIL is Harbour's type error) - now probe n1c verbatim shape.
- New: t213 i64::MIN/NIL coexistence, t214 mixed branch, t215
  reassignment, t216 forward call of a[i], t217 mixed return,
  t218/t220 runtime type errors (posx, exit 1 both targets),
  t219 nil-branch-first mixed return + `NIL !=`, t221 loop joins,
  t222 fixed arrays stay tagless, t223 folded comparisons evaluate
  both operands.
- Battery: 225/225 green on Linux x86-64 and Wine (WoW64).
