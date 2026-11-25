# LLVM At on immutable borrowed constant strings

Own MIT bounded backend increment. The existing two-argument At accepts two
immutable borrowed constant locals or literal/concat/ASCII Chr trees. First
matching 1-based byte offset, zero if absent or the needle is empty. Embedded
NUL is a byte; UTF-8 positions count bytes, not codepoints. No string value ABI,
frontend admission, ownership, mutable or owned string support added.

Fresh Harbour differential: two sources, native + traced/untraced LLVM = 6
exact executions, plus 4 named rejection checks. 128 ASCII/NUL needle cases,
overlap, case, empty, missing/longer needle and UTF-8 offsets included.
Existing 206-source corpus: 618 backend comparisons, not fresh Harbour.
A preliminary attempt to run that corpus via Harbour stopped at t28's LOCAL
after executable statement; this is NOT counted as a Harbour corpus pass.
Linux manifest 1185 exact. 618 negative inputs on Linux/PE and upstream census
1041/60 admission unchanged against prior Asc compiler. Mandatory 57 intact
originals: 285 exact + 55 strict zero, two known DELTA2 debts separate.
Rust 106; Python 66 = 64 pass + 2 skip. PE emission suite, native Mac runtime,
all historical suites and performance not repeated for this increment.
Compiler SHA256: 9e071556cc1fa7ea3eca7f9d2ee5c9fcb8f4d4c662e40500093ca9e58f6f5030

Julio Ponce MIT examples remain specifications only. No supplied implementation
or cambio.diff copied. ASort, numeric division, RC/object policy unchanged.
No workflow, push, publication or rebase. New commits only.

## Immutable local concat trees

Follow-up: the recursive immutable borrowed resolver now applies to both
position arguments. No owned/mutable/runtime strings or extra arguments.
Own gate: 9 fresh Harbour/native/LLVM exact rows and 6 named LLVM rejections.
New cases cover overlapping repeated text, empty needle/haystack, NUL,
UTF8 byte positions, false/true matches and numeric/control contexts.
Broad current results are listed in the package summary.
