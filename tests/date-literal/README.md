# Bounded 0d date literals

Own MIT incremental on 1b99cd7eac9a6dea26a1e2327f6c100ab59c914b.
No workflow, push or publication. No Harbour implementation source or
supplied diff was used. Upstream syntax and fresh outputs are specifications.
Julio Ponce's MIT programs and outputs remain specifications for the ASort
regressions, with their existing attribution retained.

Ordinary Linux accepts 0dYYYYMMDD and uppercase 0D, empty 00000000 and
Gregorian years 0001..9999. Malformed widths, impossible dates and suffixes
reject at lexing. Nonempty year0000 is explicitly outside this profile,
although fresh Harbour accepts it. Windows and both Mach targets reject.
Existing threads/macros restrictions remain. This is syntax progress only:
intact tests/ddate.prg still rejects its unlisted yyyy-mm-dd Set mask, and
variable macros remain outside the measured macro profile. No new intact
original is claimed, and no performance claim is made.

The parsed value uses an unspellable compiler identity routed through the
existing SToD date construction, not a source-level function name. ValType
recognizes the literal as D. Existing source-defined SToD remains reserved;
Harbour accepts the corresponding test, recorded as a known scope limit.

Gate21: five exact Harbour executions, balance0, three target rejections,
six named compiler limits, four Harbour-invalid-literal checks, and two
Harbour-valid outside-profile checks. Valid fixture covers both prefixes,
empty/leap/boundary dates, local assignment, date arithmetic/difference,
DToS, ValType and Year/Month/Day. This does not generalize new user-function
parameter inference or all possible literal contexts.

Latest compiler: Rust104; Linux1177 exact stdout golden rows; ASort1..21,
timestamp1..9, B1/B2,A1/A2,cycle59,nested51 and all prior date/string gates
PASS. PE1912PASS22known0FAIL is emission only, not execution. Census54/1041
is compile admission, not54 differential executions. Admission unchanged;
only diagnostics for tests/ddate.prg and src/rtl/hbdoc.prg change.

Negatives were independently separated by target after published main
corrected an earlier combined framing. Of622 rows, Linux has5 mismatches
(the published stale4 plus intentional longstr2 t1043 admission); Windows
has9 CurDir diagnostic mismatches. Combined14 is unchanged from base, but
must never be described as14 Linux failures. Raw per-target logs included.

    python tests/date-literal/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/date-literal-gate
