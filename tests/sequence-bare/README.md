# Bare BEGIN SEQUENCE without RECOVER

Own MIT increment on2569f74c75a7cf1af78c412a19ade61520d57292.
No push,publication or workflows. Harbour source/output is specification
only. No supplied implementation or cambio.diff. Julio Ponce's MIT ASort
examples remain credited regression specifications.

Only bare BEGIN SEQUENCE without RECOVER is newly admitted. It lowers to
the existing Try with an empty catch: BREAK is consumed and execution
continues after END SEQUENCE. An enclosing RECOVER does not receive the
inner discarded value. Normal execution continues unchanged. Existing
exception-value cleanup is reused,no new helper or ownership policy.
WITH without RECOVER remains rejected. Existing WITH+RECOVER behavior
is untouched. RETURN/EXIT restrictions remain. This does not add Error
object/default-handler equivalence or destructor support.

Gate20:2 own sources x5Linux modes=10 exact fresh Harbour executions,
2strict final zero balances,2negative checks(WITH and RETURN),6other-
target emission checks only.117nested/control rounds and513owned-string
rounds exceed the exception stack capacity and verify discarded values
are popped/released. Both normal completion and cross-function BREAK,
bare BREAK,NIL replacement,outer catch and skipped statements are covered.

93prior native suites all complete(35+30+28),ASort2mandatory58,
LLVMfresh gate21,Rust104,Linux1177stdoutgoldens exact,
PE1912PASS22known0FAIL emission-only,negative622same16combined.
Census57/1041,no admissions. begin.prg advances39->72(M-> expression),
destruct.prg50->91(class member). contrib/hbmisc/udpds.prg207 and
contrib/hbnf/default.prg49 remain rejected for WITH;only diagnostic text
changes. Neither original newly closes. No speed claim or RC change.

    python tests/sequence-bare/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/sequence-bare-gate
