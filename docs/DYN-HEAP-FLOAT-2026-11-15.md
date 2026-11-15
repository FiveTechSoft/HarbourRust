# Dyn heap floats (4.2)

This increment keeps the 16-byte Dyn casilla and numeric kind 5. It does
not add a numeric tower or allow general arithmetic on a Dyn value.

## Representation

A legacy kind-5 casilla without bit 63 contains the double's bits in its
payload. Those casillas remain readable. A new kind-5 casilla with bit 63
set owns a pointer to a 16-byte item: `{ double_bits, f64_metadata }`.
The metadata is the same full value used by the compiler's F64 channel,
including display decimals and width. The heap marker is explicit; a
payload that resembles a pointer is never used to guess its format.

Allocation, cloning and release reuse the string allocator's accounting,
headers and cache. An owned copy gets a separate item. Moving a casilla
moves ownership. Clearing or replacing an owned marked float releases it.
Legacy inline floats own no item and require no release.

## Extend bridge

Bit 32 of the internal argument-count channel advertises heap-float
support for that call. Count readers mask that capability and reject a
remaining count greater than INT_MAX. It is not an extra argument.

The new bridge reads both formats. A caller without the capability gets
inline returns and stores, not pointers. A new caller gets heap items.
This is a per-call contract, not a global mode. The mechanism does not
replace argument cells with proxies and does not do a copy-back pass.
An old generated caller with the new bridge is a supported compatibility
direction. A new heap-producing object with an old bridge is not supported.

Generated external-call thunks save and restore the previous argc,
capability, argv and return channel. hb_evalLaunch also separates nested
scratch items from the outer call's retained items. Nested PRG-to-C-to-PRG-
to-C tests exercise both targets and all outer/inner capability pairs.
Disabling capability writes in new thunks is a protocol control, not a
claim that those test objects were built by an old compiler. Separate
demos exercise objects built by a historical compiler checkpoint.

Win64 bridge adapters must preserve rdi and rsi around hbc-internal
allocation helpers. Tail-jumping into those helpers is not the Win64 C
ABI and broke a real nested callback with heap allocation.

## Ownership boundaries

Heap floats cross F64-to-Dyn arguments, assignments and returns, PValue,
DATA getters/setters, hashes, flat array cells and the existing Dyn thread
and mutex routes. Hash snapshots and defaults, HValues results, array
shrink/drop/fill, scope cleanup and overwritten destinations handle the
marked payload explicitly. Reallocation that moves cells must not free
the moved items. Flat AClone copies and ATail results must own their float
items independently of the source array.

Broadcast float copies are taken while the mutex queue lock is held,
before an older broadcast item may be replaced. The existing mutex/node
lifecycle remains bounded as below; this is not a general thread-runtime
memory reclamation redesign.

## Limits

- Dyn/F64 arithmetic remains rejected where it was outside the admitted
  subset. No implicit numeric coercion is added.
- PValue reads the current function's existing parameter channel. This is
  not unrestricted stack, local-variable or object introspection.
- No new DBF operation or scalar kind is admitted. DBF Empty understands
  the two float layouts; tag validation recognizes the exact heap marker.
- The existing persistent-scalar boundary still rejects float values.
- Float sorting is not added to ASort. Its integer helper rejects kind 5.
- The existing class runtime retains arenas and templates to process exit.
  The class baseline retains two allocations; a heap-float template adds
  one. Class tests must not claim whole-process hb_memcheck=0.
- Threads are Linux-only under the current runtime. Instrumented threads
  remain rejected because allocation-registry state is process-global.
  Mutex blocks and some consumed/flushed queue-node allocations retain
  their existing process-exit lifecycle. Thread tests are not zero-leak
  registry evidence.
- General error-unwind cleanup of all owned temporaries is not solved by
  this representation change. An expected runtime error is not proof of
  zero retained allocations.
- PE execution is tested under Wine, not claimed as a fresh native-Windows
  oracle. MachO checks cover emission only, not execution on a real Mac.

The publication review records exact compiler/source hashes, BASE, gate
counts and raw channels. Results from an earlier checkpoint are not a
substitute for the final integrated-source gates.
