# Original upstream dates.prg

Own MIT incremental on b5774ad664a2f84ebd9cc58bbef2b9c1a7fb6254.
No workflows, push or publication. The upstream Harbour program is used
intact as a specification, not as implementation source.

The original tests/dates.prg now executes byte-exact against freshly built
Harbour in five ordinary Linux modes, with strict final balance 0. Date()
is measured on the same local day, not from a timeless golden output.

Bounded new families, matched case-insensitively without losing mask case:
yy/dd/mm, yyyy/dd/mm, ddd/mmm/yy and ddd/mmm/yyyy. The last family follows
measured triple-width rendering: the tens digit repeats before the normal
two digits. Its rendered year stays two digits even with the yyyy mask.
Empty dates blank the numeric positions. Century changes rebuild the mask
in uppercase; unchanged century leaves original case intact. CToD uses the
measured field order and existing epoch state. No generic mask algorithm
or arbitrary-mask compatibility is claimed. Original dates2.prg stays open.

Bare string locals narrow only when the first mention is an unconditional
literal assignment and there is a direct Set dateformat or CToD input use.
Prior reads, conditional stores and by-reference locals remain rejected.
Later mixed stores still fail the existing string checker. This replaces
only an unobservable initial NIL with the existing owned-string slot.

Gate 22: original plus own masks fixture, each five exact runs, two strict
balances 0, six profile rejections and four named narrowing limits. Own
fixture covers literal and runtime setters, retained snapshots, century
transitions, triple digits, empty dates, parsing and repeated owned returns.

Census 50/1041 means compile admissions, not 50 differential programs. The
only new admission and diagnostic versus b5774ad6 is tests/dates.prg.
ASort 1..21, timestamp 1..9, B1/B2, A1/A2, cycle59, nested51, original3=19,
runtime-mask12, mask50, century22, epoch41, inlineDate17 and Rust104 PASS.
ASort21 matrix independently rerun PASS144 after the concurrent driver was
interrupted. Linux1176 exact with the same inherited ctod_order_epoch
mismatch; negatives622 with the same13; PE1912 PASS22 known0 FAIL is
emission only, not Windows execution. No speed or new target-runtime claim.

Julio Ponce's MIT programs and Harbour outputs remain specifications for
the ASort regression gates, with attribution retained in those suites.
No supplied implementation or cambio.diff was used.

    python tests/date-original1/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/original-dates
