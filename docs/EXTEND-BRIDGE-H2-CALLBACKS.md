# H2.5 callbacks: codeblocks across the Extend bridge (proposal)

Status: IMPLEMENTED (milestone 2.5, 2026-11-13) with the decisions
taken in review: the Harbour-mirrored hb_eval* FAMILY (decision 1),
hb_evalPutParam over a non-integer item is a runtime named rejection
(decision 2), NIL-returning blocks are a compile-time named rejection
(decision 3). One header correction against the pin: HB_EVALINFO is a
caller-allocated struct { HB_USHORT paramCount; PHB_ITEM pItems[10]; }
(hbapiitm.h:57-68), not an opaque pointer - the family is
hb_evalNew(PHB_EVALINFO, PHB_ITEM) -> HB_BOOL etc. The proposal text
below kept for the record. See docs/EXTEND-BRIDGE.md for the shipped
contract.

## What exists today

- .prg side: codeblock literals `{|p1, p2| e1, e2}` are statically typed
  (`Block(arity, BRet)`), the block VALUE is its 8-byte code pointer
  (Copy, no captures, no environment in this increment).
- `eval(b, a1..an)`: integer arguments only, arity checked at compile
  time, last body expression is the result (integer, or NIL when the
  body is statement-like). Calling convention: args pushed left to
  right in 16-byte slots {value, meta}; the block reads param k of n
  at `16*(n-k)(%rbp)` with the meta word at `+8`, result in %rax
  (integer) or the NIL Dyn pair {1, 0}.
- C boundary: codeblocks are a compile-time named rejection today.

## Proposed slice

- Marshal: a codeblock argument crosses as a tag-7 Dyn casilla
  {HBC_TAG_BLOCK, codeptr}. `hb_itemType`/`hb_parinfo` report
  HB_IT_BLOCK (0x1000).
- Checker: `Ty::Block` joins the marshallable set for EXTERNAL calls.
  Only blocks whose body returns an INTEGER cross in this slice (a
  NIL-returning block is a named rejection): the C side cannot tell
  raw-i64 %rax from the NIL pair without compile-time knowledge, so the
  boundary enforces BRet::Int. Extra `eval` arguments being ignored is
  Harbour behavior; the C API passes exactly the declared arity.
- C API (mirrors Harbour's hb_eval* family):
  - `PHB_ITEM hb_evalNew(PHB_ITEM pBlock)` - prepares an eval frame.
  - `void hb_evalPutParam(PHB_ITEM pEval, PHB_ITEM pParam)` - appends
    one parameter; INTEGER items only in this slice (others named
    rejection / clamped like hb_itemGetNL, decide below).
  - `PHB_ITEM hb_evalLaunch(PHB_ITEM pEval)` - runs the block through a
    small trampoline that lays out the 16-byte slots and calls the
    code pointer; returns the integer result as a new owned item.
  - `void hb_evalRelease(PHB_ITEM pEval)`.
  Simpler alternative (B): a single
  `long hb_evalBlockNI(PHB_ITEM pBlock, int nArgs, const long * args)`
  without the eval-frame machinery. Less Harbour-shaped, less code.
- Read-only like the rest: the block runs with the C function's
  lifetime; no state persists after return.

## Open decisions

1. API shape: Harbour-mirrored hb_evalNew/PutParam/Launch/Release vs
   the single-call hb_evalBlockNI. (Harbour parity argues for the
   family; the slice's integer-only restriction argues for the single
   call.)
2. hb_evalPutParam with a non-integer item: named rejection vs
   clamp-via-hb_itemGetNL (Harbour would pass the value; our block ABI
   is integer-only, so this is really "what error do we give").
3. NIL-returning blocks: named rejection at the boundary (my
   recommendation) vs tagging the casilla with the return kind
   (24-byte casilla; more marshal surface).

## Oracle pins to request once decided

- hb_itemType(block) = "B" (HB_IT_BLOCK 0x1000) over a codeblock arg.
- hb_evalNew/Launch on a 2-integer block: exact result value.
- Harbour behavior of hb_evalPutParam type mismatch (for decision 2).
