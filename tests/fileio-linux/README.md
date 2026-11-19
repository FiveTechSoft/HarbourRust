# Typed synchronous file I/O, Linux x86-64

Original MIT probes. Harbour is an external oracle, never linked or copied.

Implemented signatures: FCreate(path), FOpen(path), FWrite(fd,string),
FClose(fd), FReadStr(fd,literal_count). Paths and write payloads are typed
strings. Handles are integers or integer-valued Dyn variables, checked at
runtime by the existing integer guard. Other Dyn values/conversions, byref
FRead, optional attributes/modes/write counts and other platforms are outside
this increment. FReadStr count is a literal from 1 through 1048576. Zero was
observed to abort the oracle, so zero, negative and dynamic sizes are rejected.

FCreate opens read-write with create/truncate and 0666 subject to the process
umask. FOpen opens read-only. Descriptor/error values come from the OS, never
from assumed fixed handle numbers. Errors return -1 (open/create), 0 (write),
false (close), or empty string (read). Read consumes the requested bytes or
short read, but the result ends at its first NUL. Paths use first-NUL semantics.
No shell, default-path lookup, text encoding conversion or FError state.

The gate runs every positive from independent fresh directories, compares
stdout/stderr/status and all data-file bytes, sizes and modes, and exercises
internal/external assembler plus an inherited-descriptor variant. It checks
the pinned, unchanged external tests/fileio2.prg source hash. Memory checks
measure candidate allocation growth after warm-up, not Harbour allocation.
Nested ownership negatives and profile/argument limits must fail closed.

Run:

```
python3 tests/fileio-linux/check.py --compiler /absolute/hbc \
  --hbmk2 /absolute/hbmk2 --harbour-core /absolute/core --output /new/output
```
