# Dyn-element array design for ains (internal design record, 2026-10-31)

AUTHORITY: Anto's WhatsApp originals only - 25Oct 11:43:50 "los arrays
tienen que ser dinamicos y multidimensionales", 25Oct 12:46:55 "Ve
comparando con comportamiento con Harbour", 25Oct 13:14:36 "hay que
conseguir resolver esas diferencias", 31Oct 07:35:54 build the
originals one by one + 07:44:46 dedicated fixing agent (recoverable
wamids in the task record). The 16:16 main-agent message is INTERNAL
COORDINATION delimiting implementation within that commission - it is
not, and does not cite itself as, a new authenticated user approval of
any layout. No RC/alias/cycles/captures/float authorization exists.

STATUS SEPARATION: sections "Oracle-pinned Harbour contract" and
"Existing runtime model" are verified facts (probes/code reads dated
2026-10-31). Everything under "New piece" and "Sequence" is a CHOSEN
DESIGN, not yet accredited: the Ty::DArrDyn scaffolding compiles but
proves nothing about semantics or memory; oracle byte-exactness,
memcheck balance and the named rejections are PENDING validation per
step.

Design boundaries: heterogeneous/nested arrays with EXCLUSIVE OWNERSHIP
for ains. Preserve homogeneous paths; reserve the float tag (5). Named
rejections for unsupported forms; never a silent copy where Harbour
shares (shared assignment/ACopy/param-mutation stay OUT).

## Oracle-pinned Harbour contract (probes acl1-acl4, 2026-10-31)

- AClone = DEEP copy (nested included; clone mutation invisible in
  original). Deep implementation is Harbour-exact - no divergence.
- b := a SHARES (reference semantics). OUT of scope -> named rejection
  on second live binding of a Dyn-element array (move discipline, same
  as existing HR: the source is invalidated, never silently shared or
  silently deep-copied).
- ACopy = top-level only (nested shared). OUT of scope for now.
- Function params pass arrays BY REFERENCE. In scope only as read-only
  exclusive borrow (aDump pattern); mutation through a parameter stays
  a named rejection.

## Existing runtime model (verified in src/hbc.rs)

- Heap blocks: 8-byte capacity header at -8, hbc_alloc/hbc_free
  (munmap with cap*elemsize+8), hbc_oom on failure; memcheck counts
  must balance (verifier checks).
- Ty::DArr: 16-byte tagged cells - tags 0=i64, 1=NIL, 3=logical.
  Free = hbc_free(ptr, 16) (no owned payloads).
- Ty::DArrS: owned-string cells; free walks cells (hbc_sfree).
- Ty::DArr2/3/4: fixed-depth nested int arrays; free recurses
  (hbc_free2). Dyn (tag 4 = owned str) exists for scalars; freeing
  walks the tag.

## New piece: Ty::DArrDyn (working name in code: decided at impl)

Cells = existing 16-byte Dyn layout, tags:
  0=i64, 1=NIL, 3=logical, 4=owned str (as existing Dyn),
  6=owned subarray (pointer to a cell block with the same -8 cap
  header). Tag 5 RESERVED for the pending float decision - not used.
  Tag 2 (borrowed str) never stored in a cell: rodata strings are
  copied to owned on store (DArrS precedent), avoiding borrowed
  lifetimes inside arrays.

Freeing: new helper hbc_dfree walks cells: tag 4 -> hbc_freestr,
tag 6 -> recursive free of the child block, then hbc_free(ptr,16).
Recursive depth bounded by construction (owned tree, no cycles).

Construction: array literals where any element is a string literal,
a nested literal, or NIL in a dynamic context materialize as DArrDyn;
homogeneous int literals keep today's Arr/DArr paths (preserved).

Indexing: a[i] on DArrDyn yields the cell's Dyn pair (tag+payload) -
reading an int/logical/NIL cell as i64-compatible follows the existing
Dyn scalar rules; reading a subarray cell as a value for a[i][j]
indexing borrows the child. Stores a[i] := e: cell overwritten, old
owned payload freed, new value moved in (strings copied from rodata,
subarrays moved - source invalidated).

Builtins (statement variants, AAdd pattern): AIns (insert NIL at pos,
shift right, LAST DROPPED - oracle), ADel (shift left, last := NIL,
length unchanged), AFill(val [,start [,count]]), ASize grow=NIL-fill
(exists for DArr; Dyn variant), AClone (deep, oracle-exact).
ValType(cell): "N"/"C"/"U"/"A"/"L" from the tag. HB_ISARRAY(cell),
HB_ISNUMERIC(cell): tag tests.

## Sequence (each commit battery-validated, oracle-pinned)

1a. DArrDyn storage + mixed-scalar literals/stores/reads + ValType/
    HB_ISNUMERIC + free helper + guardrails (memcheck clean).
1b. Subarray cells (tag 6) + nested literals + HB_ISARRAY + recursive
    aDump-style borrow + deeper free tests.
2. AIns/ADel/AFill/ASize/AFill-bounds statements (edge semantics from
    oracle: drop-last, NIL-fill, start/count bounds).
3. AClone deep + array-typed user-fn params (statement-position
    evidence-flow fix as needed).
4. ains original byte-exact linux+wine; evidence package; verifier.

## Explicitly out (named rejections, registered)

Shared assignment, ACopy, mutable array params, float elements (tag 5
pending), captures, GT, SET, dates. sha2/vmasort/clasname need further
pending pieces (hb_sha2 family, SET+dates, sends+classes).
