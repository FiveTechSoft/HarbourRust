# Threads suite (`tests/threads/`)

Public evidence for the threads F1 increment (`hb_threadStart`,
`hb_threadJoin`, `hb_threadWait`, `hb_threadSelf`, `hb_threadDetach`,
`hb_threadWaitForAll`) and the F2 mutex increment (`hb_mutexCreate`,
`hb_mutexLock`, `hb_mutexUnlock`, `hb_mutexEval`, `hb_mutexNotify`,
`hb_mutexNotifyAll`, `hb_mutexSubscribe`) over an own clone(2)+futex
runtime (no pthread, no Harbour code). Same-source differential gate
against real Harbour, in the style of `tests/classes`.

Run it (Linux x86-64, needs GNU binutils and a real Harbour `hbmk2`):

    python3 tests/threads/check_oracle.py \
        --compiler ./hbc \
        --hbmk2 /path/to/real/harbour/bin/hbmk2

Expected result: `threads gate: 24/24 pass (24 differential)`, exit
status 0. Per-probe evidence (both build logs, both run outputs) is
written to the evidence directory the gate prints.

## What the probes prove

- **th01b_start_join**: start with an integer argument, join returns .T.
  and the worker's return value through `@r`; the handle's ValType is "P".
- **th03b_args**: several arguments marshal by value (lax arity: missing
  arguments arrive as NIL).
- **th04b_wait**: `hb_threadWait(th)` returns numeric 1 once finished,
  and a later wait with a timeout returns 1 immediately.
- **th05b_join_ret**: a string return crosses the join as an owned value.
- **th11b_wait_to**: `hb_threadWait(th, 0.1)` on a busy worker returns 0
  on timeout; the later join still returns the finished thread.
- **th12b_detach**: `hb_threadDetach(th)` returns .T.; a join on a
  detached handle returns .F.
- **th18b_exitwait**: Main exiting does not wait for running threads.
- **th25b_objreturn**: an object crosses the join (ValType "O") and stays
  usable in another thread.
- **th27b_ptrcmp**: pointer handles compare with == and != ;
  `hb_threadSelf()` differs from another thread's handle and is not NIL.
- **th28b_join2**: a successful join CONSUMES the handle: a second join
  returns .F. and leaves @r NIL.
- **mt01_type / mt02_lockret**: a mutex is a "P" value, not NIL;
  lock/unlock return .T. .
- **mt03_recursive**: the same thread re-locks recursively.
- **mt04_race_fixed**: two threads incrementing a shared static under a
  mutex land exactly on 200000.
- **mt05_notify_val**: notify delivers its value to a waiting subscribe.
- **mt06_notify_none**: notify with no subscribers ENQUEUES the value: a
  later subscribe consumes it.
- **mt07_notify_one**: notify wakes exactly ONE subscriber.
- **mt08_notifyall**: notifyAll wakes ALL current subscribers and each
  receives the value.
- **mt09_lock_to**: `hb_mutexLock(m, 0.1)` on a held mutex returns .F. .
- **mt10_muteval / mt11_evalret**: `hb_mutexEval` serializes the block
  and returns its value.
- **mt12_notify_fifo**: queued notify values deliver FIFO.
- **mt13_notifyall_late**: notifyAll queues NOTHING: a later subscribe
  times out with @val untouched.
- **mt14_notify_consumed_once**: a queued value is consumed exactly once.

Probes are written so real Harbour is deterministic: a worker printing
while Main prints would interleave nondeterministically in both
implementations (a declared F1 property), so worker-printing probes keep
Main silent until after the join.
