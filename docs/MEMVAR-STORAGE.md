# Isolated MEMVAR storage core (stage 2a)

This adds `runtime/hrmemvar.h` and `runtime/hrmemvar.c`, an own-code storage
module. It is NOT wired to the PRG parser, checker, macro evaluator, generated
runtime blobs or application entry/unwind code. Existing `hrmacro.*` is intact.
No new PRG syntax or dynamic macro support is claimed by this storage unit.

## ABI and admitted values

`hrv_cell` remains the existing 16-byte `{tag,payload}` cell. This first gate
admits I64 (tags 0/9), NIL (1), logical (3), and strings (borrowed input 2 or
owned input 4). Output strings from `hrmv_get_copy` are always owned tag 4.
String payload points to bytes with an aligned uint64 length immediately
before them. Empty strings still have valid storage/header and type C.

D (dates), floats/field decimal numeric, arrays, hashes, objects, blocks and
references return `HRMV_TYPE_UNSUPPORTED`. Dates await their own oracle gate.
Unsupported metadata bits and invalid logical/NIL payloads are also rejected.
No implicit numeric conversion, deep copy of shared objects, or raw tag
reinterpretation is allowed. String pointer/header validity is the trusted
native caller's responsibility; this is not a sandbox for arbitrary pointers.

The allocator must return storage aligned for uint64 and pointer-containing
structures. Caller supplies allocation/free callbacks with an opaque user
pointer. No global storage, libc calls, OS API or hidden allocator is used by
the core. The supplied context belongs to one execution/thread at a time;
sharing it concurrently requires caller synchronization and has no Harbour
thread-semantics claim. Separate contexts have independent bindings.

## API contract

Initialize fresh context storage with `hrmv_init`. Do not initialize a live
context again without destroying its bindings/frames. `hrmv_destroy` releases
all context-owned values and nodes; calling destroy again is harmless. Copies
already returned to the caller are caller-owned and must be released with
`hrmv_value_free` while the context/callback user data remain valid.

- `frame_enter` allocates a frame and returns a context-scoped, monotonic ID.
  `frame_leave` accepts only the current ID. Out-of-order, zero and stale IDs
  return BAD_FRAME without mutation. Caller performs multi-frame unwind in
  LIFO order. No C setjmp, PRG ErrorBlock or automatic unwind is installed.
- `declare_public` creates a missing visible symbol as .F.; HARBOUR/CLIPPER
  default .T. Existing visible binding is preserved. Public declarations do
  not require an entered function frame and survive frame leave.
- `declare_private` requires an entered frame. First declaration in that frame
  creates a new NIL binding hiding an inherited/public binding. Redeclaring
  PRIVATE in that same frame is a no-op, preserving its value.
- Explicit declaration initializers are a separate subsequent `put_copy`, as
  measured in Harbour. Thus `PUBLIC v := value` with a visible PRIVATE v
  assigns that visible binding, not a secret independent PUBLIC value.
- `put_copy` changes the visible binding; missing symbol creates PRIVATE in
  the current frame. Missing symbol outside an entered frame gives BAD_FRAME.
  Inputs are borrowed, not consumed. Copy/allocate before commit; failure
  preserves the old value and does not leave a partially created binding.
- `get_copy` returns an independent scalar copy, or UNDEFINED. On failure
  the caller's output is unchanged. It never lends storage that a consumer
  might free and leave dangling in the table.
- `release_name` is named RELEASE, not masks/RELEASE ALL. Visible PRIVATE is
  cleared to NIL without exposing the previous binding. PUBLIC is removed.
  Missing symbol is a successful no-op. Hidden binding returns only when its
  owning PRIVATE frame leaves.
- `exists` distinguishes a NIL-valued binding from no binding at all.
- `value_free` frees only an owned output string and replaces the cell with NIL.

Names in this gate are ASCII identifiers (letter/underscore first, then
letters/digits/underscore), case-insensitive, truncated to 63 bytes after
validation. This is measured for long valid ASCII names sharing a prefix.
NUL, non-ASCII, punctuation and invalid spelling are BAD_NAME; unsupported
suffix spelling is rejected even after the 63-byte prefix. No codepage or
arbitrary dynamic-name compatibility is claimed by this initial gate.

Lookup is linear over active binding nodes. It is not the old silent fixed
256-slot table: 600 distinct simultaneously-live bindings are tested. Storage
allocation failure is explicit. There is no separate permanent intern cache;
node memory is returned on release/leave/destroy. PUBLIC bindings created
while PRIVATE frames are active remain until released/destroyed.

## Integration boundary for Anto's frontend/evaluator work

All generated PUBLIC/PRIVATE operations and future `hrmacro` lookup must use
one storage core, not parallel tables. Current integration source was re-read
at bcd20b0d61366a2cd85f8b041df03ffded03ca28: `hrmacro.h` now returns Dyn16
`hrm_cell` from `hrmacro_eval(text,len)`, with tag4 strings allocated by
`hrm_alloc`/hbc_stralloc and tag5 heap floats. The earlier four-word hrc_value
interface is obsolete and must not guide integration.

The two-word shape matches but does NOT establish allocator interoperability.
Core get_copy outputs must use hrmv_value_free, not blindly hbc_freestr. The
bridge must either share an exactly compatible allocation/registration scheme
or copy into an hbc-owned string and free the core copy. Preserve internal
callee-saved registers around callbacks and agree SysV-internal aggregate
returns even on PE; the test's host-C ABI is not that generated-code bridge.
Tag5 floats remain TYPE_UNSUPPORTED here, so do not pass every hrm_cell into
storage without checking status. Identifier lookup in bcd20b0d still creates a
deferred V_ERR/BASE1003 path; replace that through an agreed lookup/status
hook, retaining deferred-error and field-first rules, not a direct unguarded
get. No edits to that evaluator or its generated assembly are in this unit.

MEMVAR declaration alone creates no binding. LOCAL/STATIC names are NOT added
here. The lexical expression that produces macro text may read a LOCAL; the
expanded text cannot resolve caller LOCAL/STATIC. `M->` forces MEMVAR lookup.
Field-first unqualified reads, FIELD->/alias selection and field copies are
another layer over this storage. This module does not implement them or
silently widen the current one-workarea read-only RDD. Missing-name errors
must be mapped through a future Harbour-compatible recoverable error bridge;
returning UNDEFINED is not itself BASE/1003 compatibility.

Wire `frame_leave` to all real function exits/unwinds before claiming PRIVATE
scope integration. A PRIVATE inside IF/SEQUENCE belongs to its function frame,
not a block frame. Callbacks/reentrancy, threads, escaped references and complex
values need separate integration gates. A later bytecode cache must cache
programs, not freeze storage bindings, values or workarea field ordinals.

## Verification and honest evidence labels

`tests/memvar/check_storage.py --help` builds a C API client and official
Harbour PRG oracle. It compares raw stdout/stderr/exit separately on Linux ELF
and Windows PE. This is API-level C-vs-PRG evidence, not same-source compilation
and not frontend support. The PE developer harness uses the CRT; the storage
object itself is freestanding, with zero undefined symbols in both targets.
No runtime blob is regenerated or enabled.

The PRG oracle writes explicit LF with OutStd/Chr(10). The Windows C client
sets stdout binary mode before printing to avoid CRT translation at the
output boundary. Captured bytes are never normalized for the primary gate.

A separate fault/resource run checks transactional allocation failures,
frame errors, independent contexts, unsupported D/type gates, direct RELEASE,
600 simultaneous names and 1000 enter/assign/release/leave cycles. Allocation
and free counts balance, live bytes return to 0. Linux ASAN/UBSAN/leak checks
also run. These counters are NOT the compiler's `hb_memcheck`: an unintegrated
C module cannot honestly claim that PRG instrumentation sees its allocations.
Windows evidence is PE under Wine 11, not native Windows certification.

## Limits

No PRG integration or runtime macro evaluator change. No automatic unwind,
LOCAL/STATIC exposure, field lookup/write, aliases, multiworkarea, codepages,
RELEASE masks, __mvSetBase, arrays/hash/objects/blocks/refs or dates. No general
Harbour memvar parity or full application-compatibility claim. Full macro
parity remains the goal of later coordinated integration and testing.
