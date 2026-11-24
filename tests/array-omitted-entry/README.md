# Original arrindex and omitted array elements

Own MIT incremental on eb57f245c8f8736de4b4971af9ef559755a25f02.
No workflows, push or publication. Original upstream tests/arrindex.prg
is used intact as a specification, not implementation source.

Missing entries in array literals now parse as NIL, including leading,
interior and trailing omissions. Empty {} keeps its existing meaning.
Existing nested tagged-array shared entry also recognizes assignment of
a constant nested literal, not only LOCAL initialization, when a direct
two-index store selects this existing representation. The A2 collector,
ownership, limitations and ordinary-Linux profile remain unchanged.

A pure Val of a decimal integer string may normalize to that integer
only in read-index position, on ordinary Linux without macros/threads.
Optional ASCII spaces/sign are accepted, but decimal points, computed
strings and i64 overflow are not folded. This adds no generic numeric
index coercion. Source function names are excluded; source-owned VAL
already has a named reservation in both compilers. The override fixture
asserts hbc's rejection, not a Harbour runtime differential.

Original arrindex is byte-exact against fresh Harbour in five Linux modes
and strict balance0. Own fixture covers omitted NIL cells, strings,
repeated owned overwrite, alias retention and rebinding, Len, comma and
chained indexing and literal Val indexes. Gate20:10exact,2balance,
6profile rejections,1decimal-index limit and1override rejection.
Exploration found ValType at this nested depth remains rejected; no claim
that arbitrary deep consumers or generic arrays are supported.

Census52/1041 is compile admission, not52differential programs. Only new
admission is arrindex; speed.prg progresses to a later named rejection,
not closure. ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51 all PASS.
Original dates1=22,dates2=19,dates3=19,ctodgolden6,runtime12,mask58,
century22,epoch41,inlineDate17,Rust104 PASS. Linux1177/1177 exact.
Negatives622 retain same13; PE1912PASS22known0FAIL is emission only.
No speed or Windows/Mac execution claim. A mistakenly reused output path
blocked one date-regression attempt before execution; all were rerun in
fresh output paths and passed.

Julio Ponce's MIT programs/outputs remain ASort regression specifications,
with attribution retained. No supplied implementation or cambio.diff.

    python tests/array-omitted-entry/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/omitted
