# hb_MilliSeconds, bounded Linux no-argument profile

Own MIT helper fitted to fresh external Harbour executable observations.
Result is integer absolute UTC milliseconds plus210866803200000, not a
monotonic interval clock. Five-zone live oracle observations give the same
UTC base. Only ordinary Linux no-argument calls admitted. Extra arguments,
threads/macros/LLVM/Mach-O/Windows and reserved-name override stay rejected.
This differs from Harbour's accepted ignored args, deliberately named.

check.py:180controlled-clock exact triples,12instants x3TZ x5Linuxmodes.
Harbour libc time functions are interposed; only the native helper's realtime
syscall is replaced with the same fixed timespec writer. Output bytes,
metadata, integer shape and zero delta compare. Not unmodified live-clock
byte parity. Includes epoch, ns truncation edges, leap/date and future times.

live.py:30own rows bracketed against real UTC host milliseconds plus offset,
and intact ticktime.prg native/freshHarbour each10seconds. Shapes/duration
checked, not equal rates/ticks/loops. limits.py9named boundaries.
Syscall-error fallback is0 like the existing helper family, but Harbour
failure-path semantics are unverified. Negative-time and arithmetic overflow
outside these measured instants remain unverified, no broad portability claim.
