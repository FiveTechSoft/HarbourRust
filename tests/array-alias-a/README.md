# A1: scoped mutable optional alias and LEN-only received-cell borrow

Own MIT implementation, no code copied from Julio Ponce. Julio contributed
p05/p10/v05/v10 programs and Harbour 3.2 outputs used here byte for byte.
The other expectations are ours, not new Harbour measurements.

This is a bounded step toward array sharing, not general shared arrays.
For the proven IIf(p == NIL, {}, p) local-selection body, adding literal
integer/logical/NIL cells can borrow the caller's flat tagged-array slot.
Growth changes that original slot, so the caller sees both new length and
new cells. No boundary copy and no registry-owned local heap are used.
A NIL selection owns a frame-local empty fallback; its buffer is cleaned by
the existing function unwind/epilogue, including Break. Caller arrays remain
owned by their caller. A private AView header kind 8 points at the live slot.
The existing read-only view rules do not grant mutation to other bodies.

The received-cell LEN proof now admits scalar locals, return arithmetic,
extra parameters, control flow and exceptions if every use of the cell is
under Len. No cell escapes or owner transfers. A structural fixed point
keeps this separate from general view-parameter inference. The real function
call remains present; no source specialization/inlining of the computation.

Limits: ordinary Linux without threads/macros/extensions; direct functions,
no indirect function references or methods. Optional mutable callers provide
only a local flat DArr/DArrU variable or NIL. Appended values are scalar
literals only; no strings, nested arrays, owned payloads or arbitrary aliases.
The owner stays frozen against mentions in other call arguments. Unknown
empty-array element type after a mutable call still needs a local AAdd pin
before indexing. The proof does not cover every IIf shape or generic mutation.
VAS is disabled for a program with this mutable optional proof so the slot
and its growth always use the same allocator family. Existing unaffected
programs retain their allocator selection.

Not done: complete e12/e13 (mixed arrays/general append/alias lifetime),
reference-counted or cycle-collected heap sharing, escaping local aliases,
module shared-array lifetime changes, all v10 variants, B method results.
Non-Linux forms keep named rejections, not runtime claims. Partial e13-like
checks are our separate tests, not claims that the complete e13 passes.

check.py:18 exact executions (native/external-as/no-vas),6 strict final
DELTA=0 guards,2 limits,6 non-Linux profile rejections. The ownership tests
repeat 100 calls each, including NIL-owned fallback and caller mutation,
Break after append, and received string-cell LEN raising under CATCH.
Delta zero is measured evidence, not a general memory-safety proof.
