# Short empty date literal 0d0

Own MIT increment on 1c30ba6711aef5ddb89f3935ba34432259de19e4.
No workflows, push or publication. Fresh Harbour syntax and outputs only;
no Harbour implementation or supplied diff used. Julio Ponce MIT credit
remains on the unchanged ASort regression specifications.

Adds only 0d0 / 0D0 as aliases of empty 0d00000000 on ordinary Linux.
Exactly two/seven/nine zero digits still reject, matching fresh Harbour.
Nonempty year0000 remains outside this increment. A black-box exploratory
probe found boundary arithmetic disagreement there, so that wider change
was deliberately NOT admitted. No new original or performance claim.

Gate23: exact5, balance0, profiles3, seven compiler limits, six matching
Harbour invalid literals, one Harbour-valid outside-profile year0000.
Covers direct/local DToS, ValType, Empty and empty literal equality.
Census54/1041 unchanged; hbdoc diagnostic advances past former 0d0 lexer
failure but file remains rejected. ddate original is still not closed.

All50 previous suites PASS, including original date/string gates and
ASort1..21,timestamp1..9,B1/B2,A1/A2,cycles/nested. Rust104, Linux1177
stdout golden rows exact, PE1912PASS22known0FAIL emission only. Neg622
combined15 unchanged (Linux6, Windows9). No negative rows re-pinned.

    python tests/date-zero-literal/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/zero-date-gate
