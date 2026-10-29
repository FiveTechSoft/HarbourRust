# Isolated reverse diagnostic control

Opt-in only. Normal product tracing remains unchanged. This is the wrapping
inverse recurrence from perfextra.hb, NOT the masked/bounded Harbour full-process
case and NOT a full Harbour language speed claim.

The same Rust host links LLVM and equivalent hand-written Rust recurrence:
i64 wrapping arithmetic, checked FOR decrement/exit, final counter contribution,
same dynamic trace updates in traced mode. Analysis-untraced disables those
updates on BOTH sides, using the existing explicit LLVM analysis flag and no-op
Rust Frame methods. It does not remove bounds/overflow rules or alter production.
Correctness checks1013 inputs(-12..1000), validates each timed batch result and
checks null trace restoration. The trace-restoration check in untraced mode only
checks unchanged state; it is not proof of diagnostic equivalence.

3 series,31 rotating samples after3 warmups,100 calls/sample,n=1M,fixedCPU0,
x86-64 O3 target, same host. Fresh measured median LLVM/Rust ratios:

| Mode | Series1 | Series2 | Series3 |
|---|---:|---:|---:|
| traced |1.196231|1.194319|1.195665|
| analysis-untraced |0.999057|0.999682|0.999610|

The isolated fresh traced result is slower here. Earlier traced binaries varied
~1.00 to1.20 on this host. No cause is established: instruction scheduling/layout
and diagnostic interaction remain hypotheses. No padding optimization is applied.
Near1.0 untraced is not a product parity result. Measurements are environment
observations, not stable guarantees. Whole-runtime byte sizes are not comparable.

Run after building the desired compiler (no network/install step):

```
python3 experiments/llvm-scalar/reverse-control/run.py --compiler ./hbc \
  --compiler-sha YOUR_SHA --output-dir /tmp/reverse-control --series 3 --cpu 0
```

Requires the same LLVM23 environment, rustc, GNU as and taskset as the opt-in
LLVM suite. The SHA is caller-declared; the executable SHA256 is also recorded.
Generated sources/IR/object/assembly/executables remain in the explicit output
directory. Versioned CSV/result hashes preserve this observation only.
