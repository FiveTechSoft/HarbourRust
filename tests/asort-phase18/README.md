# ASort phase18: bounded static optional-block wrappers

Own MIT incremental on d3f835519687a4d6ddf9c991780d3ed6f6dce916.
Julio Ponce's MIT c02 and Harbour output are specifications only.
No implementation or cambio.diff used. No workflows,push or publication.

The new pass recognizes a pure two-parameter wrapper whose complete body
is IF ValType(second)=="B" RETURN Eval(second,first) ENDIF RETURN first,
and pure forwarding wrappers with exactly the same argument order.
Names are not special. It reduces calls only for scalar literal first
arguments and missing/scalar literal second arguments,or an integer
literal and a capture-free single-expression integer block using +,-,*.
Every arithmetic intermediate must remain in the exact signed64 range.
Only literal arguments can be substituted or duplicated,so side effects
and argument evaluation order cannot change. No new Eval ABI or dynamic
block type. Source-owned ValType/Eval disables the pass. Duplicate source
function names disable it. Main and INIT functions are never templates.

Templates are removed only after at least one reduction and no remaining
external call,function reference or string name refers to any template.
Otherwise ordinary analysis still checks the retained functions. Captures,
extra arguments,string block arguments,user ValType override remain named
rejections in this gate. Nonliteral/effectful/multi-expression calls are
NOT reduced and are checked/executed by existing Eval support where valid.
No new admission on non-Linux,thread or macro profiles.

Gate58 includes c02 and renamed/deeper own wrappers plus four fallback
fixtures exact against fresh Harbour in5modes; final DELTA0 on each and
profile rejections. c02 is now an exact fresh-Harbour pass in these modes.
The scope is static literal reduction,not general optional dynamic blocks.
Also renames phase17's call-prefix negative helper to FreshArray: its
rejection is now the nested counter guard,not a reserved-name error.

Run:
    python tests/asort-phase18/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort18-check

Full ASort1..17,timestamp1..9,B1/B2,A1/A2,cycle59,nested51 regression
results and raw logs accompany the package. e20 is still only an original
internal-assertion/final-balance pass,not a fresh Harbour differential.
The collection must not be presented as wholly differential-closed.

Final regressions: all above gates PASS,Rust99,Linux1176exact plus the
same inherited ctod_order_epoch failure.622negatives retain13known
mismatches. PE emission1912PASS,22known,0FAIL,no PE runtime claim.
Censo48/1041 unchanged. All Linux/negative/census JSON records compare
equal to phase17,not just equal counts. Final compiler SHA accompanies
all current raw results; no binary is distributed.
