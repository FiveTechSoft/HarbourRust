# Statement AIns and ADel on a formerly shared root

Own MIT increment on1bda0ca150d29d5031820ba9f43760c8dcda9a45.
No workflows,push or publication. Fresh Harbour observations are
specification only. No supplied implementation or cambio.diff used.
Julio Ponce's MIT ASort examples remain credited regression specifications.

AIns/ADel statements now leave a selected shared root unchanged when it
currently holds a non-array scalar. The index expression is still evaluated
once before checking the root tag. A scalar root jumps past both the
mutation and its array-only stack save/restore,so stack state stays paired.
The existing shared array mutation code is unchanged. No expression-form
admission,legacy flat-array behavior or RC-policy change is included.
AFill/ASize/AAdd are deliberately not generalized:fresh Harbour raises
errors for their scalar roots,unlike the measured AIns/ADel no-op.

Gate9:five exact Harbour modes,one strict zero final balance,three profile
rejections.117rounds exercise integer,string,float,logical,NIL roots,
1170index effects and restoration to an actual mixed array. The before
probe reports unchanged17 in Harbour but RECOVER in the old compiler.

88prior suites complete,Rust104,Linux1177stdoutgoldens exact,
PE1912PASS22known0FAIL emission-only. Negative622 same16combined;
census57/1041 and all diagnostic hashes identical. Mandatory ASort2
remains58=42own+16Julio. Original calls gate remains40exact/6zero/
2knownDELTA2;object debt stays open. Original input15exact/3zero.
No new original implementation closure or speed claim.

    python tests/shared-shift-scalar-root/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shift-scalar
