# LLVM Rat on immutable borrowed constant strings

Own MIT bounded backend increment. Existing two-argument Rat lowers two
immutable borrowed constant locals or literal/concat/ASCII Chr trees to the
last matching 1-based byte offset. Matches may overlap. Empty needle or no
match gives zero. NUL participates, UTF-8 offsets count bytes, not codepoints.
No string value ABI, mutable/owned strings, frontend or ownership changes.

Fresh Harbour: two sources x native/traced/untraced = 6 exact, plus 4 named
limits. 128 ASCII/NUL cases, empty, overlap, absent/longer needles and UTF-8.
An exploratory user-defined Rat fixture was rejected by the existing frontend
reserved-name rule. It was removed from this gate, not counted as a pass.
The raw failed attempt is included separately; no shadowing admission claim.
Existing 206 sources = 618 backend comparisons against native, NOT Harbour.
Linux 1185 exact; 618 negative cases x Linux/PE unchanged against prior At;
upstream census 1041/60 unchanged. 57 intact originals 285 exact + 55 zero;
2 known DELTA2 debts separate. Rust106;Python66=64pass2skip.
PE full emission/Mac runtime/performance/all historical suites not repeated.
Compiler SHA256: 8889f726006492cb008be05d83619d7e24394197eb0b6ee93c95b58310f978b5

Julio Ponce MIT sources are specifications only, no supplied implementation
or cambio.diff copied. ASort/numeric division/RC-object policy unchanged.
No workflow, push, publication or rebase.
