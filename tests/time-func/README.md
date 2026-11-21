# Time() - the local wall clock as an 8-character string

`Time()` with no arguments returns the local time of day as "HH:MM:SS"
(zero-padded, 24 hours, ':' separators). The helpers mirror the verified
Seconds() clocks: clock_gettime plus the hbc_tz_off local zone on Linux
(wrapped into 0..86399), GetLocalTime on Windows and gettimeofday on
Darwin (UTC, compiled-only like the Darwin seconds helper). A failed
clock read formats 00:00:00 instead of crashing.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11) over time-independent
assertions: the length, the ':' positions, the 00-23/00-59 field ranges
and ValType; the Linux file is the same bytes with LF line ends.
