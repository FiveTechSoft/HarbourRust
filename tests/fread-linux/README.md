# Bounded FRead into an owned string slot

Original MIT implementation/probes. Harbour is an external oracle only.

`FRead(fd,@buffer,literal_count)` is supported on ordinary Linux x86-64.
The buffer is an owned typed string slot. The existing byref prescan makes a
literal-initialized local owned from its declaration. Borrowed/byref slots,
module statics, Dyn buffers and aliases in the handle expression are rejected.
Handles are integers, or integer-valued Dyn variables checked by the existing
runtime integer guard. Count is a literal from 0 through 1048576.

FRead modifies the buffer's prefix, preserving its logical length and unread
suffix, including NUL bytes. Count equal to logical length + 1 consumes that many bytes but only copies
logical-length bytes back. Larger requests return zero without consuming input. Count zero, EOF and read
errors return zero without changing the buffer. Short reads modify only the
bytes received. The length+1 case uses one temporary counted allocation so a single read can
consume the extra byte without writing past owned storage. No resize,
implicit encoding conversion, FError,
optional count, generic Dyn buffer or other backend is implemented here.

The gate runs five MIT probes and the pinned unchanged external
`tests/fileio.prg`, checking its source hash. Internal/external assembler and
an inherited-descriptor variant compare stdout/stderr/rc and independent
filesystem results. Allocation-growth checks are candidate-only, after warm-up.
Named limits and nested consumption negatives must fail closed.

```
python3 tests/fread-linux/check.py --compiler /absolute/hbc \
  --hbmk2 /absolute/hbmk2 --harbour-core /absolute/core --output /new/output
```
