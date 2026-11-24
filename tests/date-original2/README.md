# Original upstream dates2.prg

Own MIT incremental on 903eb03dfd0e69dafa0efbb1ef6c603d5d8bc548.
No workflows, push or publication. Upstream original is a specification
only. No Harbour implementation source or supplied diff was used.

Intact tests/dates2.prg now runs byte-exact against fresh Harbour in five
ordinary Linux modes and strict final balance0. This completes the three
original date examples dates.prg, dates2.prg and dates3.prg on this profile.
It does not claim the entire upstream collection is implemented.

Only these five bounded families and their first-year-run century variants
are newly admitted: yyy/mm/ddd, yyy/m/d/yyy, m/d/y/m/d, mmmm/ddddd, mmmmm/dd.
There are fifteen literal/runtime mask spellings. No arbitrary masks are
accepted. Existing masks retain their behavior. The owned snapshot model
and checked runtime rejection remain: unsupported values terminate with a
named Limit and exit1, not Harbour's error-block recovery behavior.

Measured rendering consumes only the first occurrence of each date field,
uppercases untouched letters and caps output at10 bytes. The right-edge
cap affects field width before rendering. Width1 gives units; widths3/4
repeat month/day tens; a run wider than4 uses only its first position.
Year widths retain the corresponding trailing year digits. Empty dates
blank processed digits, not untouched letters. A century transition
rewrites the first year run or prepends one when absent; unchanged century
keeps case. The internal mask storage is17 bytes for the bounded families.

CToD follows first field occurrence order, not separator positions. The
no-year mmmm/ddddd and mmmmm/dd families use year0 followed by existing
epoch expansion. Generated century variants acquire Y/M/D order. Own
fixtures compare all15 setters literally and through variables, empty
and boundary dates, parse inputs, century changes and151 owned returns.
A CToD-only new helper dependency is included in date-blob closure.

Gate19: original and own fixture each five exact runs, two balances0,
six profile rejections, one nearby-mask rejection. Prior weird-mask
negative is explicitly promoted to an exact fixture, not silently removed;
its gate grows50 to58. Runtime invalid-value test moves to a still-unlisted
nearby mask, retaining empty/1000-byte bounds tests.

Regressions: original1=22,original3=19,runtime12,mask58,century22,epoch41,
inlineDate17,Rust104 PASS. ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,
nested51 PASS. The first concurrent batch was interrupted; ASort12..21,
Linux and Rust were explicitly rerun to completion. Linux1176exact plus
same inherited ctod_order_epoch mismatch. Negative622 with same13.
PE1912PASS22known0FAIL is emission only, not execution. Censo51/1041 is
compile admissions, not51differential programs; only dates2 admission and
diagnostic changes versus903eb03d. No speed claim or new runtime target.

Julio Ponce's MIT programs/outputs remain specifications for ASort
regressions with attribution retained. No cambio.diff or implementation.

    python tests/date-original2/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/original-dates2
