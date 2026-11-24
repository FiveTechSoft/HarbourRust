# ATail of an already shared array

Own MIT increment on 131bb4857d303e84d92e7e98ffb58bb69da04520.
No workflows, push or publication. Original Harbour sources and fresh
outputs are specifications only. No external implementation or supplied
cambio.diff used. Julio Ponce MIT attribution remains on unchanged ASort
specifications; this increment's original arrays/array16 come from Harbour.

ATail accepts an already-selected shared array variable, checks its tag,
returns NIL if empty or the last tagged value otherwise. It uses the
current shared object length/cells, not the old flat local pair layout.
Escaping strings/floats are cloned through the existing ownership helper.
Nested array results preserve identity and are rooted by the existing
shared collector. This does not activate shared identity by itself, add
computed ATail arguments or add other-target shared array support. No new
runtime helper. Legacy flat ATail paths stay unchanged.

Gate36: own fixtures and intact upstream tests/arrays.prg and
tests/array16.prg, four sources x5 Linux modes =20 exact fresh-Harbour
executions, 4 zero final balances, 12 profile rejections. Originals alone
contribute10 exact executions,2 balances,6 profile rejections. Full source
copies, hashes and raw outputs are included. Covers empty NIL, integer,
string, float, cloned payload after source mutation, nested alias result,
received shared parameter, repeated clone/free and both intact originals.
ValType(ATail(b)) was an unsupported exploratory expression and was removed
from a positive fixture, not counted as a pass or enabled here.

Both intact originals now close for the measured Linux modes. Census
56/1041, exactly two new compile admissions: arrays and array16. This
census is not execution evidence; the separate differential gate is.
56 prior suites PASS, Rust104, Linux1177 stdout goldens exact.
PE1912PASS22known0FAIL emission only. Negative622 combined16 unchanged,
Linux7/Windows9. No performance or broader platform compatibility claim.
ASort2 remains PASS58, own42+originals16, with both originals mandatory.

    python tests/shared-atail/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-atail-gate
