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

## Immutable local concat trees

Follow-up: the recursive immutable borrowed resolver now applies to both
position arguments. No owned/mutable/runtime strings or extra arguments.
Own gate: 9 fresh Harbour/native/LLVM exact rows and 6 named LLVM rejections.
New cases cover overlapping repeated text, empty needle/haystack, NUL,
UTF8 byte positions, false/true matches and numeric/control contexts.
Broad current results are listed in the package summary.

## Selected constant haystack

Rat with constant needle and nested IIf constant haystack projects immutable
leaves to last byte offsets,including overlaps. Structural proof includes
dead leaves. Selected conditions run once,lazily,also with empty needle.
Selected needle and owned dead leaves remain rejected.No string value ABI,
RC or mutable support.Two own MIT sources cover lazy bounds/overflow,
effects,NUL,UTF8,absent/empty/longer needles and overlapping matches against
fresh Harbour in native/traced/untraced modes.Two named limits added.

## Selected haystack ASCII matrix

Own MIT test-only coverage sweeps all128ASCII bytes,including NUL,in selected
haystacks with repeated needle occurrences. Alternating true/false conditions
use a checked increment and print its current count to detect dropped or
duplicated evaluation. Original sources remain unchanged. No compiler change.
