# Unwinder increments: trace restoration before owned cleanup

Status: design recorded before code, 14 November 2026, on 76d027c.
Increment 1 is implemented and validated below. Owned cleanup remains design
work, not an implemented capability. No allocation sweep is proposed.

## Increment 1: trace-chain restoration

Observed on pre-SubStr compiler source 15eb6b2, identical to 2136a36:
Main calls Fail inside TRY, catches its bounds error, then reads ProcName.
The sequence unwinder restores rsp/rbp/callee-saved registers but leaves
hbc_trace_top pointing into Fail's abandoned frame. Output becomes corrupt
and the minimal case segfaults. Equivalent Harbour BEGIN SEQUENCE returns
to MAIN and exits 0. This is independent of owned allocations.

Make the runtime sequence pad 80 bytes instead of 64, still 256 pads.
Existing offsets 0..56 remain unchanged; offset 64 stores hbc_trace_top at
hbc_seq_push. Offset 72 stays unused/reserved. During hbc_seq_unwind restore
that pointer before jumping to the saved handler. Update both Linux and
Windows runtime copies, both pad strides and backing sizes together. The
pending-exception stack, caught-value representation, FINALLY sequencing,
error descriptions and ordinary function trace links remain unchanged.

This is a scalar checkpoint, not walking stale frames. It restores the
chain captured by the receiving TRY frame, including its ancestor, before
CATCH/FINALLY run. Nested rethrows then restore the next enclosing snapshot.
No new heap memory and no destructor or temporary ownership effects.
Storage grows from 16,384 to 20,480 bytes for the process-global pad array.

Validation: minimal oracle pair; direct and multi-level calls; nested
TRY/FINALLY/rethrow; ProcName(0..ancestors) and ProcLine after catch;
subsequent normal calls and a second catch; Linux and PE Wine normal and
instrumented; depth/capacity boundary; existing full instrumented manifest.
Expected output must remain exact against the real Harbour semantic form.
Do not claim native Windows/Mac or owned-unwinding safety.

## Later owned cleanup, not part of increment 1

Harbour FMSTAT oracle: recompile original VM with HB_FM_STATISTICS, warm up,
force hb_gcAll(.T.), record Memory(HB_MEM_USED/BLOCKS), run 2000 caught
bounds errors while an owned string argument is retained, collect again.
Measured bytes 54501 -> 54501 and blocks 569 -> 569, both delta 0. Baseline
runtime without statistics returning 0 is NOT evidence of leak freedom.

A sound cleanup design must distinguish:

- Expression temporaries retained while later arguments execute.
- Owned local slots in completely abandoned functions versus still-live
  locals in the receiving CATCH function. Do not free receiving-frame data
  merely because it was allocated after TRY began.
- Aggregate roots and recursively owned children. Free through the root's
  existing destructor exactly once, not through a raw allocation list.
- Persistent STATIC roots, which survive unwinding and process activations.
- Ownership transferred to caller/container/return slots. A stale cleanup
  registration must be removed at the exact transfer, not when convenient.
- BREAK payloads, which must remain alive until their CATCH takes ownership,
  including an owned string thrown from a fully abandoned function.
- Borrowed values and byref aliases, which never get a second destructor.
- Nested FINALLY, rethrow and errors during cleanup. A cleanup must not
  corrupt the exception that is already in flight.
- Thread-local state. The current sequence engine is process-global and
  already has thread restrictions; new ownership machinery must not inject
  process-global races into string functions used without TRY in threads.

Candidate next stage: explicit LIFO cleanup records for owned temporaries
and frame-owned slots, with a checkpoint in each receiving pad. Records
must be activated only once ownership is established and disarmed on free
or transfer. The unwinder runs only records that truly belong to abandoned
expression/frame regions, preserving surviving local roots. This requires
a typed cleanup policy, not a sweep of allocations since TRY. A generic
registry based on allocator time cannot distinguish STATIC, escaped data,
children or surviving locals and is rejected.

Before selecting an implementation, map existing destruction code and
prove transfer points. Start with a precisely admitted temporary kind and
publish measured limits instead of calling a partial repair general
exception safety. Add memory-oracle loops, double-free checks, borrowed/
STATIC/aggregate/BREAK negative controls, nested errors and thread limits.

## Increment 1 validation record

Seven source/oracle pairs in `tests/try-trace/` preserve line numbering:
the oracle form replaces TRY/CATCH/FINALLY with Harbour BEGIN SEQUENCE WITH
Break/RECOVER/ALWAYS. It is not claimed to be identical syntax. Both forms
have the same number of source lines, including the exact ProcLine probe.
Fresh Harbour output matches all seven fixed programs on Linux and PE Wine,
normal and instrumented: 28 exact stdout/stderr/exit comparisons. The cases
cover the original crash, multi-frame ancestry and subsequent calls, nested
FINALLY/rethrow, repeated catches, no-error normal flow, ProcLine and the
256-pad capacity. The existing Linux instrumented manifest passes 1729/1729.
The SubStr differential gate also remains exact, with its caught-owned error
path still separately reported as a leak, not silently reclassified as fixed.

This checkpoint fix does not release owned locals or expression temporaries,
change exception payload ownership, or expand the current process-global
sequence/thread, 256-depth, native ARM/LLVM or platform admission boundaries.
Wine is not native Windows validation; no native Mac execution is claimed.
No tracked compiler snapshot, tag or released binary is rebuilt by the patch.
