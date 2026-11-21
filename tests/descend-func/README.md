# Descend() - inverted ordering value for strings, dates, numbers, logicals

`Descend(x)` on one argument, Harbour 3.2 rtl/descend.c: a string maps
every byte to 256-b into an owned copy (the length is preserved; a
single NUL byte maps to NUL through the formula); a date returns the
integer `5231808 - julian day` (the packed civil date goes through
hbc_date_days plus the 1970-01-01 anchor JDN 2440588); a number returns
`-value` as a double (default 10.2 metadata); a logical flips. Dyn and
NumLocal values keep their named rejections.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11) over date-independent
assertions (the numeric rows plus `Descend(Date()+1) == Descend(Date())
- 1`); the Linux file is the same bytes with LF line ends.
