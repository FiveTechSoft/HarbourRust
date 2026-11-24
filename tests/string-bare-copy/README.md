# Original longstr2 string copies

Own MIT incremental on a4b7fe7f73017fe5b4af7afd84218d9d9fe71543.
No workflows, push or publication. Original upstream tests/longstr2.prg
is used intact as a specification, not implementation source.

Plain assignments from known strings into bare locals lower to the existing
owned SubStr(source,1) path on ordinary Linux without threads/macros.
Knowledge starts at direct literal LOCAL initialization and propagates
through these copies. A simple loop containing only known-string self
concatenations preserves it, provided bounds do not reference those strings.
Other statements touching a known source invalidate that knowledge.
By-reference names and source-owned SubStr exclude the transformation.
This is a bounded copy admission, not a global ownership-policy change.

Intact longstr2 stdout1351762bytes and stderr32bytes match fresh Harbour
in five modes. Because this original uses OutErr, the strict balance probe
requires its full exact stderr followed by an unconditional DELTA=0 marker,
exact stdout and deliberate rc99. Missing marker is never a successful
balance. The small own fixture uses the usual empty-stderr/rc0 guard.
Gate19:10exact,2strict balance0,6profile rejections,1byref limit.

The historical negative t1043_original_longstr2_move_neg.prg contains this
same original. It now intentionally admits Linux while Windows retains
its old moved-value rejection. The separate exact gate is its promotion;
the historical cross-target negative manifest is retained unchanged as
an audit trail, so its mismatch count is14 rather than13. The only new
mismatch is t1043; no other negative outcome changes. Do not label that
historical negative-manifest result entirely green.

Census53/1041 is compile admissions, not53differential programs. Only new
admission/diagnostic is tests/longstr2.prg. Linux1177/1177exact,Rust104,
ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51 PASS. Omitted20,
dates1=22,2=19,3=19,ctodgolden6,runtime12,mask58,century22,epoch41,
inlineDate17 PASS. PE1912PASS22known0FAIL is emission only, not execution.
No speed or Windows/Mac execution claim. Raw stdout/stderr are retained
in compressed evidence, without normalizing or reducing to hashes only.

Julio Ponce's MIT programs/outputs remain ASort regression specifications
with attribution retained. No supplied implementation or cambio.diff.

    python tests/string-bare-copy/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/string-copy
