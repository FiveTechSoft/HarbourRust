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

## F2: mutexes

`hb_mutexCreate()` returns a Dyn PTR handle (tag 14, Harbour ValType
"P"), the same representation as a thread handle. The runtime is a
MutexBlock in the same clone(2)+futex family as F1 (own design;
Harbour's GPL implementation never consulted): a lock-word (cmpxchg +
futex), the owner ThreadBlock pointer, a recursion count, a FIFO notify
queue, an event word, a broadcast generation+value and an internal
spinlock.

- `hb_mutexLock(m [, timeoutSecs])` -> logical: .T. acquired, .F.
  timeout (mt09). Recursive per thread (mt03).
- `hb_mutexUnlock(m)` -> logical .T. (mt02). Unlocking a mutex the
  calling thread does not own is a runtime error: stderr message and
  the offending thread dies (main survives) via the F1 panic route.
- `hb_mutexEval(m, {|| ...})`: lock, evaluate, unlock; the result is
  the codeblock's return (mt10/mt11).
- `hb_mutexNotify(m [, v])` -> NIL: the value is ENQUEUED even with
  zero subscribers; a later subscribe consumes it FIFO, exactly once
  (mt06/mt12/mt14); notify wakes exactly ONE waiting subscriber (mt07).
- `hb_mutexNotifyAll(m [, v])` -> NIL: broadcast - every subscriber
  waiting RIGHT NOW wakes and EACH receives the value (mt08); nothing
  is queued for later subscribers (mt13).
- `hb_mutexSubscribe(m, timeoutSecs, @val)` -> logical: on success @val
  receives the delivered value; on timeout @val is untouched
  (mt13/mt14).

Declared F2 limits:
- `hb_mutexEval` admits only zero-argument codeblocks with an integer
  return (Harbour accepts any arguments and any return type).
- `hb_mutexSubscribe` requires an explicit numeric timeout: Harbour's
  omitted-argument form `hb_mutexSubscribe(m, , @val)` is not in the
  grammar. `@val` must be a dynamic variable (same rule as
  hb_threadJoin's `@result`).
- Notify values are scalars, strings or objects (no floats, dates,
  arrays, hashes or codeblocks), marshaled like hb_threadStart
  arguments (strings deep-copied, objects retained).
- MutexBlocks, unconsumed notify nodes and the stored broadcast value
  are reclaimed at process exit only (same allocator contract as F1
  thread handles).
- A thread that dies holding a mutex leaves it locked (no robust
  mutexes; Harbour's mutexes are not robust either).
- A failed `hb_mutexLock`/`hb_mutexSubscribe` timeout restarts on a
  spurious wake instead of recomputing the remaining time.
- `hb_mutexQueueInfo` and `hb_mutexSubscribeNow` are not in F2.

## Not yet (later increments)

`hb_threadOnce`, per-thread MEMVARs and Set(_SET_*) (Harbour copies
Set from the creator at start), per-thread workareas for DBF,
`hb_threadID`, `hb_threadIsMain`, `hb_mutexQueueInfo`,
`hb_mutexSubscribeNow`.

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

`tests/threads/` runs the 24-probe same-source differential gate against
real Harbour (`hbmk2 -mt`): every probe compiles under both, runs under
both, and stdout+stderr compare byte for byte (10 F1 thread probes +
14 F2 mutex probes).
