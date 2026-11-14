# Threads (F1)

HarbourRust compiles Harbour thread creation and join to native x86-64
assembly on Linux over an own clone(2)+futex runtime: no pthread, no
Harbour VM or RTL code is copied or translated. Real Harbour serves as
the test oracle only (`tests/threads/`). Tag kind 14 is officially in
use for pointer handles (Harbour ValType "P"), joining tags 11 (Date),
12 (wide numeric) and 13 (Object).

## Admitted subset (F1)

Linux x86-64 ordinary assembly backend.

```harbour
th := hb_threadStart(@Worker(), 41)   // PTR handle (ValType "P"), or NIL
ok := hb_threadJoin(th, @ret)         // .T. + the worker's return value
n  := hb_threadWait(th [, nSecs])     // 1 finished / 0 timeout
me := hb_threadSelf()                 // this thread's own handle
ok := hb_threadDetach(th)             // fire-and-forget
hb_threadWaitForAll()                 // block until every worker finishes
```

- `hb_threadStart`'s first argument is a compile-time-known function
  reference `@f()`. Harbour also accepts codeblocks and name strings:
  both are a named compile-time rejection in this increment.
- Arguments marshal BY VALUE: strings are deep-copied, objects are
  retained (atomic reference count). Admitted argument values: integers,
  logicals, strings, objects and dynamic values holding those. Floats,
  dates, arrays, hashes and codeblocks are a named rejection.
- Target parameters are integers, objects or dynamic. Target returns are
  integer, logical, string (crosses as an owned copy), object or dynamic.
- Lax arity, as Harbour: missing arguments arrive as NIL; extra arguments
  are dropped (the calling convention carries no argument count, so the
  drop is unobservable — `PCount()` is already a named rejection).
- A successful `hb_threadJoin` CONSUMES the handle: a second join on the
  same handle returns .F. and leaves `@r` NIL (Harbour semantics).
- Handles compare with `==` / `!=` (identity of the pointer), and print
  as `0x` followed by 16 uppercase hex digits.
- `Main` exiting does not wait for running threads; workers keep their
  own per-thread console state, pending counters, small-string cache and
  callstack trace (TLS via %fs).

## Declared F1 limits

- **Error inside a thread (divergence from Harbour).** Harbour opens an
  interactive error box (which hangs headless). HarbourRust instead
  prints the error and callstack to stderr, ends only that thread with a
  NIL result, lets the join return .T. with `@r` NIL, and keeps Main
  alive. Confirmed against the captured probe.
- **Interleaved console output is nondeterministic** when several threads
  print concurrently (same as Harbour). The public gate's probes avoid
  the race on purpose.
- A joined or detached handle's control block stays mapped until process
  exit (80 + 16 bytes per argument per thread): the second-join .F.
  reads the consumed state instead of faulting. Harbour reclaims through
  its GC; HarbourRust's raw-mmap allocator reclaims at exit.
- Windows is a named rejection (the runtime is Linux clone+futex only).
- `--instrument` with threads is a named rejection (the allocation
  registry is process-global).
- `hb_memcheck` counters are approximate while threads run.

## Not yet (later increments)

Mutexes (`hb_mutex*`), notify/subscribe, `hb_threadOnce`, per-thread
MEMVARs and Set(_SET_*) (Harbour copies Set from the creator at start),
per-thread workareas for DBF, `hb_threadID`, `hb_threadIsMain`.

## Object runtime under threads

When a program uses both classes and threads, the object blob switches
to an MT-safe variant: atomic reference counts (`lock add/sub`) and a
per-descriptor spinlock around the freelist, chunk bump and the lazy
INIT template build, so INIT still runs exactly once even under a race.
Programs that use classes WITHOUT threads keep byte-identical assembly
(verified: the full non-thread corpus and the four class benchmarks
generate the same bytes as the previous release, so the single-thread
performance cost of the thread support is a structural 0.0%).

## Evidence

`tests/threads/` runs the 10-probe same-source differential gate against
real Harbour (`hbmk2 -mt`): every probe compiles under both, runs under
both, and stdout+stderr compare byte for byte.
