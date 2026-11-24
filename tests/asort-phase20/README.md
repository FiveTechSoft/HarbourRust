# ASort phase20: arithmetic reduction precision boundary

Own MIT incremental on dad7ee0be916a4b87ba99ded5f293325e438e098.
No implementation or cambio.diff. No workflows,push or publication.

The recommended i64 boundary fixture exposed a real discrepancy in the
phase18 reduction: Harbour compares3037000499 squared differently from
an exact integer result,although the mathematical result fits i64.
Therefore multiplication reduction now also requires every product to
have magnitude at most2^53. Checked addition/subtraction still reject
any i64 overflow. An overflow or precision refusal leaves the original
call for existing Eval analysis,not a claim that generic Eval gains
large-integer fidelity here. No change to c02's small integer behavior.

Fresh Harbour fixture tests MAX-1+1,MAX-1 through subtraction,a product
below2^53,and cancellation before multiplication. Exact in5Linux modes,
strict final DELTA0,3profile rejections. Gate9.

Four Rust unit tests cover positive/negative i64 add/sub edges,multiply
precision/overflow,and intermediate overflows even when the mathematical
final result fits. An AST test verifies both the overflowing intermediate
and the large-but-i64 product stay unchanged and the template is retained.
This isolates the reduction guard instead of relying on a later compiler
error or incorrectly claiming the older Eval route matches overflow.

    python tests/asort-phase20/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort20-check
    cargo test optional_block::tests

The rejected exploratory large product's raw output is included separately
as discovery evidence,not a passing fixture. ASort1..19 regressions and
all baselines accompany delivery. e20 caveats from phase19 remain.

Final gates all PASS: ASort1..19,timestamp1..9,B1/B2,A1/A2,cycle59,
nested51,Rust103. Linux1176exact plus unchanged inherited ctod failure,
neg622/13known,PE1912PASS22known0FAIL,censo48/1041. All Linux,negative
and census JSON records equal to phase18,not merely equal counts.
