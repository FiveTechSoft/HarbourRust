# Threads suite (`tests/threads/`)

Public evidence for the threads F1 increment: `hb_threadStart`,
`hb_threadJoin`, `hb_threadWait`, `hb_threadSelf`, `hb_threadDetach`,
`hb_threadWaitForAll` over an own clone(2)+futex runtime (no pthread, no
Harbour code). Same-source differential gate against real Harbour, in the
style of `tests/classes`.

Run it (Linux x86-64, needs GNU binutils and a real Harbour `hbmk2`):

    python3 tests/threads/check_oracle.py \
        --compiler ./hbc \
        --hbmk2 /path/to/real/harbour/bin/hbmk2

Expected result: `threads gate: 10/10 pass (10 differential)`, exit
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

Probes are written so real Harbour is deterministic: a worker printing
while Main prints would interleave nondeterministically in both
implementations (a declared F1 property), so worker-printing probes keep
Main silent until after the join.
