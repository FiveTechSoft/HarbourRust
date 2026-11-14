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
- `hb_mutexSubscribeNow` is not in F2 (F3 measured it for F4, see
  below).

## F3: literals in hb_threadStart, hb_threadID/hb_threadIsMain, hb_mutexQueueInfo

- `hb_threadStart(@f(), ...)` accepts compile-time constant arguments:
  integer, string and logical literals and NIL (oracle th29b; Harbour
  passes them by value). The worker's parameter infers from the literal
  like the multiarg call-site trail: an integer literal pins an integer
  parameter, a string/logical literal pins the tagged union (Harbour's
  parameter is a variant). Float, Date, array, hash and codeblock
  arguments stay rejected with the F1 limit.
- `hb_threadID([th])` -> numeric (Harbour ValType "N", oracle th30b):
  the kernel tid, unique per thread. With a handle, the tid the worker
  stored at boot; a join-consumed handle still maps (F1 blocks live
  until process exit) and keeps returning the id - F3 convention, not
  a Harbour oracle.
- `hb_threadIsMain()` -> logical: .T. on the main thread, .F. on a
  worker (oracle th30b).
- `hb_mutexQueueInfo(m [, @nSubscribers, @nQueueLength])` -> logical
  (oracle mt18): .T. for a valid mutex; the 3-arg form fills the
  waiting-subscriber and queued-value counts, read under the queue
  spinlock. nSub>0 is a race window and is not oracled.
- Regression oracles mt15-mt19 pin the measured hb_mutexSubscribe
  contract: no interaction with the lock (a subscribe consumes a queued
  value even while ANOTHER thread holds the mutex, mt19), @val
  UNTOUCHED on timeout (mt15), the mutex is left unlocked after a
  successful subscribe (mt17).
- SubscribeNow measured for F4 (f08/f10): it DISCARDS the currently
  queued values and waits only for FUTURE notifications ("from now").
  In this Harbour build the mutex destructor raises BASE/1302 after
  SubscribeNow was used - the declared interactive-error family.
- hb_threadOnce parked: five API shapes probed (f01, f01b-f01e), all
  rejected by Harbour with BASE/3012; the control item becomes a
  ValType "B" after hb_threadOnceInit. Needs more API research.

## F4: hb_mutexSubscribeNow, hb_threadOnce

- `hb_mutexSubscribeNow(m, timeoutSecs, @val)` -> logical (oracles
  mt20-mt22, support probes sn_a..sn_g): FLUSHES the currently queued
  notifications, then waits only for FUTURE ones ("from now"). A
  future `hb_mutexNotify` delivers (mt21) and a future
  `hb_mutexNotifyAll` delivers (mt22). On timeout `@val` is UNTOUCHED
  and the subscription is disarmed - a later notify queues normally
  (sn_d). The wait path is hb_mutexSubscribe's: same event word, same
  broadcast generations, no interaction with the lock.
- `hb_threadOnce(@control [, bBlock])` -> logical (oracles
  ton01-ton03): the control starts NIL; the first caller runs the
  zero-argument block IN ITS OWN THREAD and gets .T.; concurrent
  callers BLOCK until the block finishes and get .F.; later callers
  get .F. immediately. The block's return is discarded and the
  control becomes logical .T. (ValType "U" -> "L", ton01). The 1-arg
  form CLAIMS the slot without running anything: winner gets .T., the
  control becomes logical .T., and a later 2-arg call returns .F.
  without executing its block (ton03). Share the control between
  threads through a function-local NIL STATIC (a persistent Dyn
  casilla; ton02) - file-scope STATICs stay the existing named
  rejection.
- Correction to the F3 note above: further probing (to_a..to_g)
  showed the 1-arg form is NOT an error; the BASE/3012 seen earlier
  came from combining `hb_threadOnceInit(@once, 42)` (a different
  initializer that stores a plain value) with a later
  `hb_threadOnce(@once)` on that NUMERIC control. The true semantics
  are implemented as described in this section.
- Harbour destructor artifact, declared divergence: if a
  SubscribeNow flush discards a queued value, or a SubscribeNow wait
  expires unsatisfied, THIS Harbour build raises BASE/1302 "Object
  destructor failure: Reference to freed block" when the mutex is
  destroyed at process exit (an interactive error box that hangs
  headless; sn_a/sn_d/sn_e/sn_f/sn_g/mt20). HarbourRust exits
  cleanly. mt20 therefore gates as a prefix oracle: Harbour runs
  under `timeout` and its stdout must START with HarbourRust's
  complete output.

## Declared F4 limits

- `hb_threadOnceInit` is NOT implemented: it is a different
  initializer (`hb_threadOnceInit(@ctl, value)` stores the plain
  value, ValType follows it). A control that starts non-NIL
  non-logical is undefined in this increment (Harbour raises
  BASE/3012 when such a control reaches hb_threadOnce).
- An error raised by the once-block mid-run belongs to the declared
  thread-error family (stderr + call stack; the process reports the
  error). A recursive hb_threadOnce on the same control from the
  same thread deadlocks (same class as Harbour). Both declared, not
  oracled.
- Nodes dropped by a SubscribeNow flush leak with their payloads -
  the same lifecycle class as consumed nodes (MutexBlocks live until
  process exit, the declared F2 limit).

## Declared F3 limits

- hk-memvar: MEMVARs are not in the subset (their declarations are
  no-ops; hbc.rs documents this). Measured Harbour semantics for the
  future dedicated phase (th08): MEMVARs are NOT inherited - a PUBLIC
  created by main reads Type()="U" in the worker; each thread starts
  with an empty table.
- hk-set: Set(_SET_*) is not in the subset (no Set builtin). Measured
  Harbour semantics (th09): the worker's settings are COPIED from the
  creator at start (the worker sees main's _SET_DECIMALS) and then
  diverge per thread.
- Both are compiler-wide subsystems (each comparable to F1+F2), kept
  out of the threads increments by design decision (2026-11-14).

## Not yet (later increments)

per-thread MEMVARs (hk-memvar) and Set(_SET_*)
(hk-set), per-thread workareas for DBF, `hb_threadOnceInit`.

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

`tests/threads/` runs the 37-probe same-source differential gate against
real Harbour (`hbmk2 -mt`): every probe compiles under both, runs under
both, and stdout+stderr compare byte for byte (10 F1 thread probes +
14 F2 mutex probes + 7 F3 probes + 6 F4 probes). One F4 probe
(mt20_subnow_flush) gates as a prefix oracle because Harbour hits its
declared BASE/1302 destructor artifact after a flushed SubscribeNow;
the other 36 compare byte for byte.
