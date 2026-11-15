# MEMVAR integration design, 2026-11-15

Design only. No change to hrmacro, compiler, generated assembly, manifests or storage implementation.

## Pinned evidence

Remote HEAD was ff00ccb4438015d8785851949e86a5feaa4b65ed at 14:11 CET, read with git ls-remote. Its runtime/hrmacro.c and .h are byte-identical to bcd20b0d. Relevant source snapshots accompany this review for reproducibility, not as proposed replacements. Official oracle: Harbour core 694428e1c12f726675b19324d62167fa77d68185, Linux gcc and Windows mingw64 through Wine. Parent owns publication.

## Decision: explicit ownership boundary, not a cell cast

Storage's owned strings have a length header at -8 and allocate n+9 bytes. Compiler-owned strings additionally require capacity at -16 and use registry/cache accounting. hrm_alloc calls hbc_stralloc; hrm_free calls hbc_freestr. Directly handing a storage pointer to either hrm_free or a generated Dyn consumer that takes ownership is invalid. Equal Dyn16 layouts do not imply allocator compatibility.

Recommended first bridge keeps storage on a separate raw allocator with matching sized free callbacks. Binding nodes, frame nodes and strings are all raw allocations; do not implement those callbacks by casting hrm_alloc/hrm_free. Define an adapter-level result type carrying status and value, not a fake Dyn tag for failures. For each successful lookup:

1. hrmv_get_copy returns a storage-owned cell.
2. Scalars are decoded without changing their runtime provenance. For string, read its length, allocate an hrm_alloc buffer, copy bytes, and release the original via hrmv_value_free on every exit.
3. Only the hrm allocation crosses into hrmacro's existing owned-string path. Its drop uses hrm_free. Exported values retain that same compiler ownership.
4. Put does the reverse through hrmv_put_copy: compiler input remains borrowed, storage takes its own deep copy. On failure the old binding survives and the caller still owns its input.

The adapter must check allocation and size failures without raising before temporary cleanup. A future move/adopt API can remove the double copy only after it encodes destructor identity and registry transitions explicitly. Do not change the storage allocator contract merely to save a copy.

## Decision: parse/fold separately from runtime name evaluation

Do not replace T_IDENT's deferred error with an eager value and leave M1 arithmetic untouched. Literal-only folding and runtime operators are different. The same oracle prints these exact bodies:

    Str(&("10/2")) -> "         5"
    PRIVATE v:=10; Str(&("v/2")) -> "         5.00"

This was observed on ELF and PE/Wine. Hence a tag9 value read from a binding is not a source literal. Copying its tag into the current V_INT path would erase the distinction. Division-by-zero, boolean folding and metadata need independent mixed-expression gates, not extrapolation from this single division probe.

Recommended design is a small expression representation with literal, lookup, nested macro, operator and future call nodes. Parse the complete expression first; syntax errors must not be hidden by a lookup failure. Fold only literal-provenance subtrees using the current M1 folding rules. Runtime evaluation then resolves surviving lookup nodes and applies runtime operators. Preserve current V_ERR semantics for deferred failures: folding may eliminate an unreachable lookup/error; a surviving failure retains the first applicable evaluation-order error and its exact diagnostic. Never call hrm_fail from the storage callback. Raise only after owned temporaries are released at the top boundary selected by the error-route owner.

Nested macro text must live until parsing/evaluation has finished with its spans. A scratch arena can own nodes and normalized name copies, but not borrowed strings from already-dropped operands. Free that arena on syntax failure, runtime failure and normal return. A source-provenance bit alone is not enough to fix eager name lookup in expressions that fold away a subtree.

This is a design choice, not a claim that Harbour internals must be reimplemented identically. A two-pass evaluator is an alternative if it proves the same ordering, no-side-effect parsing and lifetime invariants. Unknown runtime operators must fail closed with a named limit rather than reuse a known-wrong literal rule.

## Name resolution and error separation

Use a host resolver interface that can distinguish explicit M-> lookup from an unqualified name. Explicit M-> consults MEMVAR only. Unqualified field-vs-MEMVAR precedence remains the work-area resolver's responsibility. With no field subsystem, document a MEMVAR-only stage rather than claiming complete Harbour lookup. LOCAL/STATIC remain invisible to macro-expanded names; the LOCAL string that produces macro text is separate.

HRMV_UNDEFINED can become the existing BASE/1003 deferred lookup error. TYPE_UNSUPPORTED, BAD_NAME, MEMORY and BAD_FRAME must not masquerade as undefined variables. The evaluator must resolve using the key truncated to 63 bytes, matching storage and Harbour. Preserve the original long spelling only for diagnostics, never as an alternate lookup key. Existing ASCII validation is an explicit stage limit. The UTF8 oracle shows that __mvPut("árbol",31) and __mvPut("ÁRBOL",42) are distinct in this configuration; do not apply Unicode uppercase indiscriminately. This does not prove all Harbour codepages or macro lexer acceptance of these names.

## Context and unwind

Own one context per appropriate VM execution context, not a process-global singleton. Enter a frame at the real Harbour-compatible function boundary, not at every C helper. Normal return, error unwind, BREAK/RECOVER and early return must leave exactly the frames they entered. Initialize and destroy once; destroy must occur before the allocator disappears. Existing hrm_fail is currently process-exiting, not evidence that recoverable unwinds work.

__mvSetBase is NOT equivalent to disabling frame_leave. The oracle declares promoted, calls __mvSetBase, then declares later: promoted survives in the caller, later is removed. The official implementation moves the private-base marker to the current stack count. A future storage API must transfer only the pre-marker PRIVATE lifetime segment to the caller, preserving order, hidden bindings and subsequent redeclarations. Current owner-id-only storage has no implementation of this operation; design it separately with nested and same-name tests before coding.

RELEASE masks similarly are NOT repeated release_name calls over visible names. In the oracle, RELEASE ALL in the child clears its PRIVATE values to NIL but leaves the parent's PRIVATE unchanged; PUBLIC also remains unchanged. RELEASE ALL LIKE a* clears matching current-scope PRIVATE, EXCEPT bb preserves bb and clears the other current-scope PRIVATE values. Hidden/duplicate bindings, wildcard semantics, case, ? and direct helper arity still need their own cases. Keep named RELEASE separate.

## ABI and registry gates

Current macro C is compiled to internal SysV x86-64 on ELF/PE/Mach-O. A new C bridge compiled with native Win64 cannot be called through this convention without an adapter. Choose internal SysV for the bridge and provide explicit native callback wrappers, or keep it native and add entry wrappers. Preserve SysV nonvolatiles across compiler helper calls. When returning through a Win64 boundary, also preserve Win64 nonvolatiles including rdi/rsi and applicable XMM registers. Stack alignment and Win64 shadow space need executable tests, not comments.

Track raw storage allocations separately or integrate them into the runtime logical registry with the correct raw base/size. Compiler string registry/cache counts must see only compiler allocations. Final hb_memcheck=0, balanced raw counters and zero live bindings/frames are independent gates. No pointer may be logically freed twice because it appears in both registries.

## Suggested review sequence

Prerequisite before B or C: the error-contract fix owned by Anto must pass its three posx cases, including recoverability and the correct output channel. That review is currently FAIL/open. Today there is no implemented top-level recoverable raise boundary to call; references above to such a boundary describe a required interface, not an existing capability. Do not start evaluator or bridge wiring against the current process-exiting hrm_fail and call it recoverable. Isolated probes and a non-integrated harness may proceed without that wiring.

A. Extend storage alone with measured RELEASE masks and private-base semantics; new API and tests require approval. Keep non-ASCII names unsupported until a measured canonicalization contract is chosen.
B. Add an isolated bridge harness: scalar/string roundtrip, embedded NUL, zero length, long strings, all allocation failures, unsupported Dyn tags, child scope, unwind and two contexts. No evaluator or frontend change yet.
C. Owner of hrmacro adds parse/fold/runtime separation, with this bridge behind an explicit context interface. Keep V_ERR and error-route contract in that owner's lane.
D. Wire declarations, calls and unwind only after isolated gates pass. Check actual emitted ABI and registry, then compile same-source PRGs on both implementations.

Required mixed-expression oracle matrix: literal versus MEMVAR int division (exact/inexact/zero), float metadata, overflow, string comparisons, errors on both sides, constant .AND./.OR. eliminating missing names, dynamic boolean operands, nested macros, full-source syntax after a missing name, fields versus M->, frame restoration and supported recovery. Compare stdout/stderr/exit raw; CRLF-normalized results are secondary. This proposal does not claim those unrun gates passed.

## Limits

This is design plus official-Harbour probes, not integration or new storage functionality. Dates, float/decimal storage, references, arrays, hashes, objects, calls and work areas remain outside the existing storage stage. Current stage is not full macro parity. The prior PUBLIC HARBOUR/CLIPPER defaults are already covered by the delivered storage oracle and were not rerun here. Error-route formatting/handler choice remains the other owner's decision.

Amendment 2026-11-15 (M0): the recoverable-raise prerequisite is narrowed for M0 to fatal-channel PASS (f13158c6: terminal diagnostics, correct channel/EOL/exit1). ErrorBlock, BREAK/RECOVER and any recoverable raise remain OUTSIDE M0 as named limits; 'supported recovery' in the mixed matrix is declared unrun. A recoverable top-level boundary remains required before any unit claiming recoverable semantics. Cleanup-before-raise at the fatal boundary and deferred V_ERR are M0 gates.
