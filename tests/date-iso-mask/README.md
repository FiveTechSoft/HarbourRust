# ISO-style Y-M-D mask family

Own MIT incremental on 3a76dfb5b6af6fdfe1be82c7d8220d6d886e2e2e.
No workflow, push or publication. Original Harbour syntax and fresh oracle
outputs are specifications only. No implementation or supplied diff used.
Julio Ponce MIT attribution remains on the unchanged ASort regression work.

Adds exactly yyy-mm-dd, yy-mm-dd, yyyy-mm-dd, case-insensitive recognition
with snapshot case preserved, through literal and runtime Set(4,...).
The first is the measured initial-century variant of the yy/yyyy family.
Rendering uses the already measured bounded family algorithm, and CToD
follows Y/M/D order. Century changes retain existing first-year-run rules.
No arbitrary date masks are added. The encoding14 uses the unused final
four-bit family value. Existing family behavior remains unchanged.

Gate28: three fixtures each exact5 Linux modes, three balances0, nine other
target rejections, one nearby-mask rejection. Two own fixtures cover case,
snapshot, epoch parsing, empty/leap dates, century transitions and151 owned
runtime updates. Third is unchanged historical t813: now deliberately
accepted Linux and measured against fresh Harbour rather than silently
changing its stale negative row. Windows retains its old rejection.

This is still partial progress toward original tests/ddate.prg. The intact
original remains rejected because its variable macro context excludes Set
and dates in the measured macro profile. No original is newly closed.
Census54/1041 unchanged, including all diagnostics. No speed claim.

Regressions:49 suites PASS, including date-literal, all earlier date/string
and ASort1..21,timestamp1..9,B1/B2,A1/A2,cycles/nested. Rust104, golden
Linux1177 stdout rows exact. PE1912PASS22known0FAIL is emission only.
Neg622: combined15, only new mismatch is intentional Linux t813 admission.
Separated Linux6 (previous5 plus t813), Windows9 CurDir unchanged. Root
negative manifest is preserved, with the promoted case explicitly covered.

    python tests/date-iso-mask/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/iso-mask-gate
