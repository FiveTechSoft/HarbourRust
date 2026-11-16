# Windows object separator regression

The `p_sep`, `matrix` and `mixed` expected Windows streams are raw captures
from official Harbour 3.2.1dev r2610242111, source revision
694428e1c12f726675b19324d62167fa77d68185, built with
`hbmk2 -plat=win -comp=mingw64 -gtstd`, executed with Wine 11.22 and
LC_ALL=C.UTF-8. Every oracle run exited 0. stderr is empty except for the
intentional `!` from mixed's OutErr. These are Wine measurements, not
execution on real Windows. No newline or whitespace normalization is used.

From the repository root:

    python3 tests/classes/windows-separators/check.py --compiler ./hbc --wine /path/to/wine

Omit `--wine` on Windows. Optional `--cc`, `--ld`, `--libdir` run a second
assembly route using clang's x86_64-w64-mingw32 target and a MinGW linker.
Compilation, assembly, linking and execution have 30-second timeouts. Keep
the printed evidence directory on failure. Initialize Wine separately;
a cold-prefix setup timeout is a failure, not a passing test.

The matrix covers live/NIL objects, interior/final separators, preceding
string spaces, multiple objects, function returns, `??`, empty output,
OutStd, OutErr and EOF. The compiler does not admit object/integer mixed
function returns; no generic dynamic-return coverage is claimed here.

## Correction and remaining console-profile debt

The claim in commit f31d99dc's message that p_sep's final space was an
established GTCGI platform difference was not supported by a Windows
oracle. Fresh GTSTD oracle evidence disproves it: the space is a bug.
The historical commit is not rewritten. This regression records the
correction and fixes the invisible-object hold, without claiming a new
full differential Harbour class gate or native-Windows verification.

The fix reserves bit 63 of hbc_pending as an invisible-object annotation
in Windows programs with classes. A visible formatted output clears the
annotation and emits the held interior spaces. A newline, a nonempty
OutStd write, or normal Main return discards an annotated hold; an empty
OutStd leaves it untouched. The existing TLS retargeting also moves this
bit with the counter, rather than adding process-global state. No helper
or annotation is emitted for class-free programs. Raw writes and OutErr
do not mark invisible objects.

`controls.prg` is a diagnostic probe, NOT a passing GTSTD regression:
fresh GTSTD trims string-only trailing holds at newline/OutStd, whereas
the existing hbc Windows profile preserves them (historically labelled
GTCGI). That broader GTSTD/GTCGI profile mismatch remains OPEN compatibility
debt. Harbour compatibility is the goal; preserving current unrelated
fixtures here does not settle or excuse that debt. Resolving it requires
a separate oracle/profile change and review, not relabelling mismatches
as legitimate differences. Embedded newlines, explicit QUIT/error exits
and broader mixed-value output are outside this focused gate.
