# Module STATIC float statement assignment

Original MIT. Ordinary Linux only. Canonical module storage now receives both
IEEE value and packed width/decimal metadata on statement assignment. +=, -=
and *= lower to this route. Literal float, self-reference, function return,
recursive/cross-function writes, INIT/Main/EXIT, branches and copies are measured.
No type-changing stores: integer/string/NIL/logical replacement stays rejected.
Inline :=, ++/--, @, counters, local STATIC float and block captures remain
rejected. /= remains a parser rejection. A block reading n+1.0 has its own
fixture and remains rejected by the generic capture guard.

Width fix: positive float literal tokens use at least 10 integer columns,
or their written integer-token width; negative literals use value width.
Measured at 999999999,9999999999,1e10,-999999999,-1e9 and leading zeros,
through module initialization, assignment, LOCAL, parameters and returns.
The formula was checked against local oracle common/hbstr.c piWidth handling;
no runtime array-float support is claimed. Module/local float-array attempts
were rejected by existing guards and retained as failed scope probes.

Final: 65 new exact stdout/stderr/rc triples,13 sources x5 modes, plus40
read-only regression triples.14 named limits. Strict-zero3,GTSTD88,Rust118.
Negatives618 Linux/Windows: four expected changes (generic initializer text
for date/effectful/hash and float negative fixture changed from float store
which is now supported to integer retag rejection). Census1041 retains65
admissions; four diagnostics change, no runtime claim for rejected originals.
Full Linux manifest, performance, FullLLVM and independent rebuild not run.
Original initexit.prg and fatal divergence remain OPEN.

Failed attempts retained: initial build interrupted with incomplete logs;
attempt2/4 compile timeouts; attempt3 wrote only frame and failed50/55;
attempt5 canonical store fixed50/55 but large literal width differed;
attempt6 width fixed55/55; reserved Step fixture parser rejection corrected
to Recur; local/module float-array scope attempts rejected. Final build uses
codegen-units64 instead of previous16 after timeouts. Earlier logs separate.
