# Hybrid design: mechanisms from Goose's memory model applied to HarbourRust

Design document, translated from the original Spanish proposal. This is not a statement of current implementation or performance. Each increment is independent, reversible by a flag, and can be integrated only after passing the current acceptance gate: a byte-exact oracle against real Harbour and Linux/Wine regression tests.

**Status when publishing the I1 port:** I1 is classification-only. It does not change allocation, codegen, layouts or runtime ownership. Increments 2-4 below remain proposals. The original proposal's suggested README wording is retained as historical design text, not approved capability claims. In particular, I1 does not yet use its classifications to choose allocation. Claims of permanently stable array references would also need to exclude any moving fallback described under I3. Existing bounded refcount support makes an unqualified "no counters" claim incorrect.

## 0. Hard constraints

1. **Preserve Harbour semantics.** The target semantics include shared array/hash assignment (`a := b` aliases), dynamic `Dyn{tag,payload}`, capturing codeblocks, by-reference `@` arguments and `hb_stor*`. No increment may change an observable result. This is a compatibility requirement, not a claim that every feature is currently supported.
2. **Byte-exact against Harbour.** This is every increment's gate. A change that alters output does not land, even if it is faster.
3. **No tracing GC or pauses.** Preserve that property of the current runtime.
4. **Truthful README.** Every public statement must follow from a mechanism that is implemented and measured, never from an aspiration.

Starting runtime as recorded in the proposal: an inline `Ty` enum and `Dyn{tag,payload}`; a checker that proves ownership/moves at compile time; deterministic frees when an owner dies; mmap/HeapAlloc as general allocation; a bounded refcount path for persistent roots.

Goose model as recorded against the aardappel/goose v4 specification: no general malloc; dynamic data on bump-pointer data stacks in reserved virtual address space (VAS); bulk reclamation by rewinding at scope exit; values that do not move, giving stable references by construction; compile-time inferred reference roots without explicit lifetimes; structural restrictions such as one resizable member per struct and no shared references.

The underlying mismatch: Goose forbids what Harbour needs, including shared array/hash aliasing and dynamic capture. This design adopts **mechanisms**, not the whole model.

## Increment 1: escape analysis in the checker

### Definition

A pass after ownership checking classifies each `Dyn` allocation and each local holding it:

- **Escapes:** its value may outlive the scope that created it.
- **Does not escape:** it is proved to die within that scope.
- **Unknown:** the analysis cannot decide. Treat as escaping, conservative toward safety.

The I1 implementation refines this proposal into frame escape plus per-name `crosses-scope` and `loop-local` annotations. Container/assignment unions preserve required lifetimes. Clone boundaries are distinguished from ownership transfer. These classifications have no allocation consumer yet.

### Proposed escape rules

A value escapes if any applies:

1. It is returned, directly or inside a returned expression.
2. It is stored in an array/hash (`a[i] := x`, `AAdd(a,x)`, `h["k"] := x`), since the container can outlive its creating scope.
3. It is assigned to a longer-lived outer variable, including PUBLIC/PRIVATE/STATIC, which always escape.
4. A codeblock captures it, since the block can run later.
5. It is passed by reference (`@x`) or to an Extend API that may retain it through `hb_stor*`.
6. It is passed to a function whose full call graph is unavailable: dynamic macro/name calls, an external block's `Eval()`, external functions, or direct/mutual recursion.
7. It enters an `IIF` or another expression whose result is used in any of the above ways.

### Decision points

Assignments, RETURN, array/hash literals, block creation, calls and loop entry/exit. The original proposal suggested one-level interprocedural retention analysis, memoized by function: an internal function proved not to retain an argument would not make that argument escape on that path. The current I1 instead conservatively marks owned moves into calls, using the existing checker's move/borrow decisions; it does not implement that proposed interprocedural inference.

### Forced conservative cases in the proposal

- Any macro `&` in a function makes all its values escape.
- Passing a locally created block onward makes all captures escape.
- Locals crossing recursive calls escape.
- With BEGIN SEQUENCE/RECOVER, values live at RECOVER escape through error flow.

These are requirements for any future allocation consumer, not new admission of unsupported language constructs.

### Risk, size, gate, flag

- **Risk: low while analysis-only.** No codegen change yet. The danger is a false nonescape classification; uncertainty must become escape.
- **Estimated size:** 600-900 checker lines plus positive/negative classification tests for every rule.
- **Proposed gate:** full oracle/regression tests with unchanged behavior, plus adversarial classification tests. No nonescaping value may reach an escape point under rules 1-7, accounting for the implementation's transfer/clone and scope distinctions.
- **Flag:** `--no-escape-analysis` skips the pass. A future allocation consumer must treat an absent proof conservatively; I1 currently has no such consumer.

## Increment 2: per-scope bump-pointer arena

Depends on I1.

### Definition

Allocate values proved not to escape in a per-scope arena: a bump pointer over pages committed on demand. A single rewind at scope exit reclaims them. This takes Goose's data-stack/bulk-free mechanism only where the checker proves safety.

### Activation

- Each function has a function-level arena for nonescaping values.
- Short-lived synthetic scopes, such as loop bodies and IF branches, can use intermediate rewind marks in the same arena.

### Existing deterministic frees

- Nonescaping values omit individual frees; rewind covers them, with no per-value free work.
- Escaping/unknown values retain the current deterministic owner-based free and general allocator. The arena adds a path; it does not replace general allocation.
- `Dyn` tag/layout stay unchanged. Only payload allocation changes, protected by the byte-exact gate.

### Early exit, loops and errors

- **RETURN/EXIT/LOOP:** rewind follows the syntactic scope, not only normal control flow. Every exit goes through the correct arena epilogue.
- **Loops:** function-level allocation alone could grow without bound. Mark and rewind each loop-body iteration. Values created outside the loop stay in the unreclaimed region.
- **Errors:** native error unwinding rewinds abandoned frames' arenas. Keep an active-arena chain with one top/link per frame; error handling walks it. RECOVER retains its recovery scope's arena. Its visible values must have been classified escaping and must not live in rewound storage.
- **Overflow:** grow committed pages up to a configurable ceiling. Beyond that, fall back to the general allocator for that allocation, rather than failing solely because the arena is full.

### Risk, size, gate, flag

- **Risk: medium.** Changes codegen epilogues and error runtime. A wrong rewind on early exit is the main risk; test nested RETURN/EXIT/LOOP with active arenas.
- **Estimated size:** 1,000-1,800 lines across runtime arena/chain/growth and codegen.
- **Gate:** full byte-exact oracle/regression tests; no omitted free belongs to an escaping value; peak memory no worse than the current path; speed equal or better in current benchmarks. A serious slowdown defeats the increment's purpose.
- **Flags:** compile-time `--no-arena`; runtime diagnostic `HB_ARENA=off`.

## Increment 3: array backing in reserved VAS with on-demand commit

Independent of I1/I2. Arrays first, not hashes.

### Definition

Avoid reallocating array backing during ordinary growth. Reserve address space with Linux `mmap(PROT_NONE)` plus range `mprotect`, or Windows `VirtualAlloc(MEM_RESERVE)` plus on-demand `MEM_COMMIT`. Grow in place. This is Goose's nonmoving-value mechanism, intended to keep element references stable.

### Representation impact

- Array header changes from `{ptr,len,cap}` to `{ptr,len,committed,reserved}`. The proposal intends `ptr` to stay fixed for the array's lifetime, subject to the unresolved overflow fallback below.
- Growing AAdd/ASize commits a new range without copying, removing the current O(n) copy on backing growth.
- AIns/ADel still shift elements inside backing. Addresses before the insertion/deletion point stay stable; logical element movement remains.
- Internal element references, where supported, could support I4.
- Shared aliases still see the same backing and preserve Harbour semantics.

### Costs and limits proposed for measurement

- Typical per-array address reservation: 16-64 MB. Physical pages are used only when committed. The original proposal describes this as cheap on 64-bit systems and distinguishes Linux overcommit from Windows MEM_RESERVE. Those costs must be verified on supported systems before publication as performance facts.
- Thousands of simultaneous arrays are the intended target in a 47-bit address space. An array exceeding its reservation needs a policy: reserve/copy as last resort, or grow through a doubled reservation/remap (`mremap` on Linux preserves addresses only when possible; Windows may copy). A 64 MB reservation corresponds to 4 million 16-byte Dyn slots. A moving fallback conflicts with unconditional stable-reference promises and must be resolved before enabling references that depend on them.
- Hashes remain outside this stage: their linked structure and costs differ.

### Risk, size, gate, flag

- **Risk: medium.** Changes internal array layout. Keep all access through the same primitives. Audit assumptions about relocation and measure memory across the battery.
- **Estimated size:** 700-1,200 runtime lines plus codegen changes to array primitives.
- **Gate:** full byte-exact oracle/regressions; physical RSS no worse; speed equal or better. Intensive ASize/AAdd benchmarks should show whether the mechanism pays.
- **Flags:** `--no-vas-arrays`; runtime `HB_VAS_ARRAYS=off`.

## Increment 4: compile-time checked root references

Depends on I1 and makes use of I3.

### Definition

An internal reference to an array element or arena value is valid only if analysis proves a live local root owns it and the reference cannot outlive that root. The checker infers the root without explicit lifetimes and requires the reference to die first. This is a practical use of Goose's rooted-reference idea.

### Useful scope

- Repeated a[i] reads in loops: one stable reference per iteration without repeated Dyn validation.
- Read-only internal calls: checked reference passing instead of copying Dyn.
- I3 array iteration: a reference could survive growth only when backing actually stays put. This requires the I3 overflow/reference policy to be settled.

### Explicit exclusions

References crossing dynamic calls, stored in hashes, or rooted in PUBLIC/PRIVATE escape under I1's rules and keep the existing copy path.

### Risk, size, gate, flag

- **Risk: low-medium.** Enables access optimizations. An unsound validity proof is the risk; the same conservative escape rules apply.
- **Estimated size:** 500-800 checker/codegen lines.
- **Gate:** full byte-exact oracle/regressions and equal-or-better intensive array-access benchmarks.
- **Flag:** `--no-root-refs`.

## Increment 5: explicit exclusions and reasons

1. **The complete Goose model:** banning malloc, allowing one resizable member per struct and banning shared references conflicts with Harbour semantics. That would be another language, not an increment.
2. **Removing general allocation:** escaping/returned/shared-container/captured values still need it. Arenas supplement it.
3. **Removing refcount:** shared persistent roots still need the bounded path while aliasing cannot be decided at compile time. The proposal expects its use might shrink, not disappear.
4. **Ordered arena destructors:** rewind is unordered bulk reclamation. The proposal assumes no observable destructors for these values; if finalizers are added, those values cannot use this path without a separate design.

## Increment summary

| # | Increment | Depends on | Risk | Estimated size | Gate | Flag |
|---|---|---|---|---|---|---|
| 1 | Escape analysis | None | Low while analysis-only | 600-900 lines | Unchanged oracle/regressions; adversarial classification | `--no-escape-analysis` |
| 2 | Per-scope arena | 1 | Medium | 1,000-1,800 lines | Byte-exact; memory no worse; speed at least current | `--no-arena`, `HB_ARENA=off` |
| 3 | VAS arrays | None | Medium | 700-1,200 lines | Byte-exact; RSS no worse; intensive-array improvement | `--no-vas-arrays`, `HB_VAS_ARRAYS=off` |
| 4 | Root references | 1, using 3 | Low-medium | 500-800 lines | Byte-exact; intensive-access improvement | `--no-root-refs` |

Suggested sequence in the original proposal: 1 then 2 first, 3 second as an independent improvement, and 4 optionally after that. This is not an instruction to implement or publish any later stage.

## Original suggested README wording, subject to implementation and measurement

The following are design targets, not current README text. The cautions at the start of this document override any overstatement in the original suggestions.

**Before increments:**
> "No VM, no pcode, no garbage collector. Compile-time checked ownership and deterministic reclamation, without counters or pauses. In the same family of GC-free designs as Rust and Goose."

The unqualified counter claim is not valid with the existing bounded persistent-root refcount path.

**After I1, original suggestion:**
> "The compiler analyzes which values do not leave their scope (escape analysis) and uses that information to decide how each value is allocated."

Only the analysis part applies to classification-only I1. Allocation selection is not implemented by I1.

**After I2:**
> "Temporary values live in per-scope bump-pointer arenas and are reclaimed together on exit without individual frees: Goose's data-stack mechanism, used where the compiler proves it safe."

**After I3, original suggestion:**
> "Arrays never move when growing: backing in reserved address space with on-demand commit. Element references are permanently stable, as in Goose."

This must be limited or changed if any moving overflow fallback remains.

**After I4:**
> "Compile-time checked root references, without explicit lifetimes."

**After I1+I2+I3:**
> "No GC; compile-time checked ownership; bump-pointer arenas with scope-based reclamation and stable growing arrays: mechanisms from Goose's memory model applied to Harbour semantics."

**Claims this design cannot support:**

- "We use Goose's memory model", unqualified. Goose bans general malloc and shared references; HarbourRust needs them for compatibility.
- "No general allocator" or "no malloc". Escaping values still use general allocation.
- "No counters", unqualified. The bounded persistent-root refcount path remains.
