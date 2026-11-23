# Package B: PCOUNT, bounded Linux direct-call implementation

Own MIT code, no Harbour sources. Semantics requested by the owner: number of
arguments actually supplied, including explicit NIL. An omitted trailing
argument is not supplied. A positional hole before a supplied argument counts
as a supplied NIL. These expectations are not a new real-Harbour oracle.

The direct caller places args.len() in r11 immediately before CALL. Only a
callee that contains builtin PCOUNT saves it, before any trace/helper call,
in a dedicated 16-byte frame slot beyond locals. Recursion therefore keeps
separate counts. No global runtime count; parameter slots and padding are
unchanged. Main and INIT have zero supplied arguments in this compiler.
Existing ownership, cloning, byref variant labels and epilogues are reused.

Limits: ordinary Linux only, no threads/macros; PCOUNT in methods and blocks
is a named rejection. Extra arguments beyond declared parameters remain the
existing named arity rejection. Thus this is NOT complete Harbour PCOUNT.
PCOUNT itself takes zero arguments. User-defined PCOUNT still overrides the
builtin and is tested on Linux, with emission on other targets.

Run:
python3 tests/pcount/check.py --compiler /path/to/hbc --output /new/directory

Six exact-output executions, each also checked with the post-cleanup
alloc/free DELTA guard: zero/one/two arguments, explicit NIL, positional hole,
recursion, nested calls, byref, string ownership loop, user override. Five
named limits, three target rejections and three user-override target emissions.
No non-Linux runtime claim. Delta=0 is instrumented evidence, not a general
proof of memory safety. No claim about extra-argument side effects: rejected.

The old t1368 negative source is changed to test nonzero PCOUNT arity, with a
matching manifest substring. It remains a negative row on every target;
positive Linux-only cases are separate, not cross-target manifest rows.
