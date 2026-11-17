# Str(Dyn) in threaded programs

`Str(x)` with a Dyn `x` used to set the MEMVAR/macro context (its
BASE/1099 check is `hrmacro_str_check`), so any program that also used
threads was rejected at compile time with "MEMVAR/macro contexts with
threads are outside this stage".

The checker now only records that Str(Dyn) was seen. `emit_asm` keeps the
macro-context path for single-thread programs (their assembly is
byte-identical to before: 5246/5246 linux+windows outputs of every
tests/ and extend/demo program compared). A threaded program gets an
inline kind check with the same accepted kinds (0/9/5). Any other kind
releases an owned operand and calls `hbc_str_dyn_fail`.

`hbc_str_dyn_fail` writes Harbour's terminal text, byte-for-byte what the
macro path prints: "Error BASE/1099  Argument error: STR", then "Called
from STR(0)" and then the language frames. It writes these on stderr
through a relabelled copy of `hrm_fail`. Its exit empties the trace and
takes the ordinary panic tail:

- in a worker, only that worker ends and its join yields NIL, like other
  runtime errors in threads;
- on the main thread, the process exits 1.

`programs/str_dyn.prg` (manifest `posx2`, rc 1) covers integer and float
renders in workers, a failing worker, and a failing main thread.
